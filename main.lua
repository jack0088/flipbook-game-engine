local json = require "json"
local scene = {}

function scene:new(descriptor)
    local scn = json.decode(love.filesystem.read(descriptor))
    love.window.setTitle(scn.window.title)
    love.window.setMode(scn.window.width, scn.window.height)
    self.background = scn.scene.background
    return self
end

function scene:draw()
    love.graphics.setBackgroundColor(self.background)
end


function love.load()
    bouncing_ball = scene:new("demo/bouncing-ball.json")
end


function love.draw()
    bouncing_ball:draw()
end
