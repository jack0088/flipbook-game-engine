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
    self.asset = {}
    self.frame = self.setup.setting.frame
    love.window.setTitle(self.setup.camera.title)
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })
    self:preload(30)
    -- play visual transition effect
    for _, a in ipairs(self.asset) do
        for b, c in pairs(a) do
            print(_, b, c)
        end
    end
    return self
end

function Chapter:close()
    -- play visual transition effect
    -- unload/ destroy things if needed
end

function Chapter:preload(seconds)
    local remainder = seconds
    for index, frame in ipairs(self.setup.scene) do
        local context = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
        love.graphics.setCanvas(context)
        for i, layer in ipairs(frame.layer) do
            love.graphics.draw(love.graphics.newImage(self.setup.setting.folder..layer))
        end
        love.graphics.setCanvas()
        self.asset[index] = {render = context:newImageData()}
        for j, trigger in ipairs(frame.trigger) do
            if type(trigger.audio) == "string" then
                assert(not self.asset[index].audio, "found audio trigger duplicate in scene frame "..index)
                self.asset[index].audio = love.audio.newSource(self.setup.setting.folder..trigger.audio, "static")
            end
            local delay = (self.asset[index].audio and self.asset[index].audio:getDuration() or trigger.delay) or 0
            remainder = remainder - delay
        end
        if remainder <= 0 then break end
    end
end

function Chapter:draw()
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
    --for k, v in pairs(bouncing_ball) do print(k, v) end
end

function love.draw()
    bouncing_ball:draw()
end
