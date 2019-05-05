function typeof(self, super)
    local meta repeat
        meta = getmetatable(meta or self)
        if meta and meta.__index == super then return true end
    until not meta
    return false
end

function class(base)
    return setmetatable({is = typeof}, {__index = base, __call = class})
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
    print(bouncing_ball:is(Scene))
end

function love.draw()
    --bouncing_ball:draw()
end
