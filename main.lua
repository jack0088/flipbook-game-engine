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

function Chapter:open(script, buffer)
    self.setup = json.decode(love.filesystem.read(script))
    self.buffer = buffer or 30 -- length in seconds
    love.window.setTitle(self.setup.camera.title)
    love.window.setMode(self.setup.camera.width, self.setup.camera.height, {
        fullscreen = self.setup.camera.fullscreen,
        resizable = true
    })
    for _, a in ipairs(self.playlist) do
        for b, c in pairs(a) do
            print(_, b, c)
        end
    end
    -- TODO play visual transition effect
    return self
end

function Chapter:close()
    -- TODO play visual transition effect
    -- unload/ destroy current chapter if needed
end

function Chapter:preload(seconds)
    local remainder, index = seconds
    if self.playlist and self.playhead then index = self.playlist[self.playhead].index
    else index = self.setup.setting.frame end
    self.playlist = {}
    self.playhead = 1
    repeat
        self:cache(index)
        local earliest
        for k, trigger in ipairs(self.setup.scene[index].trigger) do
            local delay = (self.playlist[#self.playlist].audio and self.playlist[#self.playlist].audio:getDuration() or trigger.delay) or 0
            if not earliest or earliest > delay then
                earliest = delay
                index = trigger.frame
            end
        end
        remainder = remainder - earliest
    until remainder <= 0 or not index
end

function Chapter:cache(frame)
    if type(frame) == "number" then
        local context = love.graphics.newCanvas(self.setup.setting.width, self.setup.setting.height)
        love.graphics.setCanvas(context)
        for i, layer in ipairs(self.setup.scene[frame].layer) do
            love.graphics.draw(love.graphics.newImage(self.setup.setting.folder..layer))
        end
        love.graphics.setCanvas()
        table.insert(self.playlist, {render = context:newImageData(), index = frame})
        for j, trigger in ipairs(self.setup.scene[frame].trigger) do
            if type(trigger.audio) == "string" then
                assert(not self.playlist[#self.playlist].audio, "found audio trigger duplicate in scene frame "..frame)
                self.playlist[#self.playlist].audio = love.audio.newSource(self.setup.setting.folder..trigger.audio, "static")
            end
        end
    end
end

function Chapter:draw()
    self:preload(self.buffer) -- TODO dynamically
    love.graphics.setBackgroundColor(self.setup.camera.chroma)
end




function love.load()
    bouncing_ball = Chapter():open("demo/bouncing-ball.json")
    --for k, v in pairs(bouncing_ball) do print(k, v) end
end

function love.draw()
    bouncing_ball:draw()
end
