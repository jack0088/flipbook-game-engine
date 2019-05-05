function descendent(klass, super)
    local meta repeat
        meta = getmetatable(meta or klass)
        if meta and meta.__index == super then return true end
    until not meta
    return false
end

function replica(klass)
    if type(klass) ~= "table" then return {} end
    local copy = replica(getmetatable(klass).__index)
    for k, v in pairs(klass) do copy[k] = v end
    return copy
end

function class(base)
    return setmetatable({}, {__index = base, __call = replica})
end




local json = require "json"
local Scene = class()

function Scene:init(descriptor)
    local scn = json.decode(love.filesystem.read(descriptor))
    love.window.setTitle(scn.window.title)
    love.window.setMode(scn.window.width, scn.window.height)
    self.background = scn.scene.background
    return self
end

function Scene:draw()
    love.graphics.setBackgroundColor(self.background)
end




function love.load()
    bouncing_ball = Scene():init("demo/bouncing-ball.json")
end

function love.draw()
    bouncing_ball:draw()
end
