function descendent(klass, super)
    local meta repeat
        meta = getmetatable(meta or klass)
        if meta and meta.__index == super then return true end
    until not meta
    return false
end

function replica(klass)
    if type(klass) ~= "table" then return {} end
    if not getmetatable(klass) then return klass end
    local copy = replica(getmetatable(klass).__index)
    for k, v in pairs(klass) do copy[k] = v end
    return copy
end

function class(base)
    return setmetatable({}, {__index = base, __call = replica})
end




local json = require "json"
local Chapter = class()

function Chapter:open(script)
    self.script = script
    self.setup = json.decode(love.filesystem.read(self.script))
    love.window.setTitle(self.setup.camera.title or self.setup.setting.title)
    love.window.setIcon(love.image.newImageData(self.setup.setting.folder..self.setup.setting.icon))
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        minwidth = self.setup.setting.width,
        minheight = self.setup.setting.height,
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })
    love.filesystem.setIdentity(love.window.getTitle():lower():gsub("[%s_]", "%-"))
    self:preload(self.setup.setting.frame)
    return self
end

function Chapter:preload(frame)
    -- queue up all trigger handler
    self.frame = frame
    self.trigger = {}
    for t, trigger in ipairs(self.setup.scene[self.frame].trigger) do
        if trigger.frame then
            local SKIP = not trigger.delay and not trigger.audio and not trigger.contact
            local FORWARD = trigger.delay or trigger.audio
            local DELAY = trigger.delay and trigger.audio
            local SLEEP = not trigger.delay and not trigger.audio and trigger.contact
            local SAVE = trigger.save
            local audio = trigger.audio and love.audio.newSource(self.setup.setting.folder..trigger.audio, "static") or nil

            -- play audio after delay or immediately
            if audio then
                local timeout = love.timer.getTime() + (trigger.delay or 0)
                local reference = #self.trigger + 1
                table.insert(self.trigger, function()
                    if love.timer.getTime() > timeout and not audio:isPlaying() then
                        audio:play()
                        table.remove(self.trigger, reference)
                    end
                end)
            end
            
            -- forward immediately
            if SKIP then
                table.insert(self.trigger, function()
                    self:preload(trigger.frame)
                end)
            end

            -- forward after delay, audio or both
            if FORWARD then
                local timeout = love.timer.getTime()
                if DELAY then timeout = timeout + trigger.delay + audio:getDuration()
                elseif audio then timeout = timeout + audio:getDuration()
                else timeout = timeout + trigger.delay end
                table.insert(self.trigger, function()
                    if love.timer.getTime() > timeout then
                        self:preload(trigger.frame)
                    end
                end)
            end

            -- forward after click or touch
            if SLEEP then
                table.insert(self.trigger, function()
                    if love.mouse.isDown(1)
                    and love.mouse.getX() > trigger.contact[1] and love.mouse.getX() < trigger.contact[3]
                    and love.mouse.getY() > trigger.contact[2] and love.mouse.getY() < trigger.contact[4]
                    then
                        self:preload(trigger.frame)
                    end
                end)
            end

            -- store game progress
            if SAVE then
                self.setup.setting.frame = self.frame
                -- TODO re-save self.script file or use löve's savefiles?
            end
        end
    end

    -- bake all layer images into a single texture
    self.render = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
    self.render:setFilter("nearest", "nearest")
    self.render:renderTo(function()
        for l, layer in ipairs(self.setup.scene[self.frame].layer) do
            local image = love.graphics.newImage(self.setup.setting.folder..layer)
            image:setFilter("nearest", "nearest")
            love.graphics.draw(image)
        end
    end)
end

function Chapter:draw()
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.render)
    for t, trigger in ipairs(self.trigger) do trigger() end
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
end

function love.draw()
    bouncing_ball:draw()
end
