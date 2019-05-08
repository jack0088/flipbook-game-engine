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

function Chapter:load(script)
    self.setup = json.decode(love.filesystem.read(script))
    self.asset = {}
    self.frame = self.setup.setting.frame

    for i, frame in ipairs(self.setup.scene) do
        local context = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
        love.graphics.setCanvas(context)
        for j, layer in ipairs(frame.layer) do
            love.graphics.draw(love.graphics.newImage(self.setup.setting.folder..layer))
        end
        love.graphics.setCanvas()
        self.asset[i] = {render = context:newImageData()}
        for k, trigger in ipairs(frame.trigger) do
            if type(trigger.audio) == "string" then
                assert(not self.asset[i].audio, "found audio trigger duplicate in scene frame "..i)
                self.asset[i].audio = love.audio.newSource(self.setup.setting.folder..trigger.audio, "static")
            end
        end
    end

    love.window.setTitle(self.setup.camera.title)
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })

    return self
end

function Chapter:preload(length)
end

function Chapter:open()
    -- visual transition effect
end

function Chapter:close()
    -- visual transition effect
end

function Chapter:draw()
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
end




function love.load()
    bouncing_ball = Chapter():load("demo/bouncing-ball.json")
    --for k, v in pairs(bouncing_ball) do print(k, v) end
end

function love.draw()
    bouncing_ball:draw()
end
