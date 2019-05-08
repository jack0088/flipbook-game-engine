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
    self.setup = json.decode(love.filesystem.read(script))
    self:preload(self.setup.setting.frame)
    love.window.setTitle(self.setup.camera.title)
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })
    -- TODO play visual transition effect
    return self
end

function Chapter:close()
    -- TODO play visual transition effect
    -- unload/ destroy current chapter if needed
end

function Chapter:preload(frame)
    -- queue up all trigger callbacks
    self.setup.setting.frame = frame
    self.trigger = {}
    for t, trigger in ipairs(self.setup.scene[self.setup.setting.frame].trigger) do
        if trigger.frame then
            local SKIP = not trigger.delay and not trigger.audio and not trigger.contact
            local FORWARD = trigger.delay or trigger.audio
            local DELAY = trigger.delay and trigger.audio
            local SLEEP = not trigger.delay and not trigger.audio and trigger.contact
            local SAVE = trigger.autosave
            local audio = trigger.audio and love.audio.newSource(self.setup.setting.folder..trigger.audio, "static") or nil

            -- play audio after delay or immediately
            if audio then
                local timeout = love.timer.getTime() + (trigger.delay or 0)
                table.insert(self.trigger, function()
                    if love.timer.getTime > timeout and not audio:isPlaying() then
                        audio:play()
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
                local aabb = trigger.contact
                table.insert(self.trigger, function()
                    if love.mouse.isDown(1)
                    and love.mouse.getX() > aabb[1] and love.mouse.getX() < aabb[3]
                    and love.mouse.getY() > aabb[2] and love.mouse.getY() < aabb[4]
                    then
                        self:preload(trigger.frame)
                    end
                end)
            end

            -- store game progress
            if SAVE then
                -- TODO
            end
        end
    end

    -- bake all layer images into a single texture
    self.render = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
    love.graphics.setCanvas(self.render)
    for l, layer in ipairs(self.setup.scene[self.setup.setting.frame].layer) do
        love.graphics.draw(love.graphics.newImage(self.setup.setting.folder..layer))
    end
    love.graphics.setCanvas()
end

function Chapter:draw()
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
    love.graphics.draw(self.render)
    for t, trigger in ipairs(self.trigger) do trigger() end
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
end

function love.draw()
    bouncing_ball:draw()
end
