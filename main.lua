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

function Chapter:open(script, frame)
    self.url = script
    self.setup = json.decode(love.filesystem.read(self.url))
    love.window.setTitle(self.setup.camera.title or self.setup.setting.title)
    love.window.setIcon(love.image.newImageData(self.setup.setting.asset..self.setup.setting.icon))
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        minwidth = self.setup.setting.width,
        minheight = self.setup.setting.height,
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })
    love.filesystem.setIdentity(love.window.getTitle():lower():gsub("[%s_]", "%-"))
    self:preload(frame or self.setup.setting.frame)
    return self
end

function Chapter:preload(frame)
    self.frame = frame
    if self.setup.scene[self.frame] then
        -- queue up all trigger handler
        self.trigger = {}
        for t, trigger in ipairs(self.setup.scene[self.frame].trigger) do
            if trigger.frame then
                local SKIP = not trigger.delay and not trigger.audio and not trigger.contact
                local FORWARD = trigger.delay or trigger.audio
                local DELAY = trigger.delay and trigger.audio
                local SLEEP = not trigger.delay and not trigger.audio and trigger.contact
                local SAVE = trigger.save
                local audio = trigger.audio and love.audio.newSource(self.setup.setting.asset..trigger.audio, "static") or nil

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
                        if audio then audio:release() end
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
                            if audio then audio:release() end
                            self:preload(trigger.frame)
                        end
                    end)
                end

                -- forward after user input
                if SLEEP then
                    table.insert(self.trigger, function()
                        local w = love.graphics.getWidth()
                        local h = love.graphics.getHeight()
                        local s = math.min(w / self.setup.setting.width, h / self.setup.setting.height)
                        local x = w/2 - self.setup.setting.width * s / 2
                        local y = h/2 - self.setup.setting.height * s / 2
                        local x1 = x + trigger.contact[1] * s
                        local y1 = y + trigger.contact[2] * s
                        local x2 = x1 + trigger.contact[3] * s
                        local y2 = y1 + trigger.contact[4] * s
                        if love.mouse.isDown(1)
                        and love.mouse.getX() > x1 and love.mouse.getX() < x2
                        and love.mouse.getY() > y1 and love.mouse.getY() < y2
                        then
                            self:preload(trigger.frame)
                        end
                    end)
                end

                -- capture game progress
                if SAVE then save_game() end
            end
        end

        -- bake all layer images into a single texture
        self.render = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
        self.render:setFilter("linear", "linear")
        if self.setup.camera.pixelated then self.render:setFilter("nearest", "nearest") end
        self.render:renderTo(function()
            love.graphics.clear(self.setup.setting.chroma)
            for l, layer in ipairs(self.setup.scene[self.frame].layer) do
                local image = love.graphics.newImage(self.setup.setting.asset..layer)
                image:setFilter("linear", "linear")
                if self.setup.camera.pixelated then image:setFilter("nearest", "nearest") end
                love.graphics.draw(image)
            end
        end)
    end
end

function Chapter:draw()
    if self.render then
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        local s = math.min(w / self.setup.setting.width, h / self.setup.setting.height)
        love.graphics.setBackgroundColor(self.setup.camera.chroma)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(self.render, w/2, h/2, 0, s, s, self.setup.setting.width/2, self.setup.setting.height/2)
        for t, trigger in ipairs(self.trigger) do trigger() end
    end
end




function load_game()
    local script, frame = (love.filesystem.load("progress.txt") or ""):gsub("(.+)\n(.+)", function(file, frame) return tostring(file), tonumber(frame) end)
    if #script > 0 and frame > 0 then game = Chapter():open(script, frame) end
end

function save_game()
    if game then love.filesystem.write("savegame.txt", game.script.."\n"..game.frame) end
end

function reset_game()
    love.filesystem.remove("progress.txt")
end




function love.load()
    -- TODO rethink how we could save diffenrent chapters progresses and load them
    -- because as of now its only possible to track the overall progress over chapters
    load_game()
    if not game then game = Chapter():open("tutorial/instructions.json") end
end

function love.draw()
    if game then game:draw() end
end
