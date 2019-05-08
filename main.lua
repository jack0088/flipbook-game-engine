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
    self.renderer = {}
    self.timer = {}
    self:preload()
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

function Chapter:preload()
    local index = self.setup.setting.frame repeat
        for t, trigger in ipairs(self.setup.scene[index].trigger) do
            if trigger.frame then
                local INSTANT = not trigger.delay and not trigger.audio and not trigger.contact
                local FORWARD = trigger.delay or trigger.audio
                local SLEEP = not trigger.delay and not trigger.audio and trigger.contact
                
                

                self:queue(self.timer, nil)
                index = trigger.frame
                if SLEEP then break end
                if FORWARD then remainder = remainder - earliest end
            end
        end

        local context = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
        love.graphics.setCanvas(context)
        for l, layer in ipairs(self.setup.scene[index].layer) do
            love.graphics.draw(love.graphics.newImage(self.setup.setting.folder..layer))
        end
        love.graphics.setCanvas()
        self:queue(self.renderer, love.graphics.drawFrame, self, context:newImageData(), duration)
    until not index

    for _, a in ipairs(self.playlist) do
        for b, c in pairs(a) do
            print(_, b, c)
        end
    end
end

function Chapter:queue(thread, action, ...)
    local arguments = {...}
    local process = function(reference) action(reference, unpack(arguments)) end
    table.insert(thread, coroutine.create(process))
end

function Chapter:drawFrame(image, duration)
    while love.timer.getTime() <= love.timer.getTime() + duration do
        love.graphics.draw(image)
        if type(self) == "thread" then coroutine.yield() end
    end
end

function Chapter:draw()
    --[[
    --self:preload(self.buffer) -- TODO dynamically
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
    if #self.pipeline > 0 then
        if coroutine.status(self.pipeline[1]) == "dead" then table.remove(self.pipeline, 1)
        else coroutine.resume(self.pipeline[1], self.pipeline[1]) end
    end
    --]]
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
end

function love.draw()
    bouncing_ball:draw()
end
