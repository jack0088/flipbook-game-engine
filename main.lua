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
    love.window.setTitle(self.setup.camera.title)
    love.window.setMode(self.setup.camera.width, self.setup.camera.height)
    return self
end

function Chapter:draw()
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
    for k, v in pairs(bouncing_ball) do
        print(k, v)
    end
end

function love.draw()
    bouncing_ball:draw()
end
