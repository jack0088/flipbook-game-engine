-- This module is free software; you can redistribute it and/or modify it under the terms of the MIT license.
-- Copyright (c) 2014, rxi https://github.com/rxi/classic
-- modified 2019 by kontakt@herrsch.de

local Object = {}
Object.__index = Object

function Object:__call(...)
    local obj = setmetatable({}, self)
    if obj.new then obj:new(...) end
    return obj
end

function Object:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then cls[k] = v end
    end
    cls.__index = cls
    cls.super = self
    return setmetatable(cls, self)
end

function Object:implement(...) -- mixins
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if not self[k] and type(v) == "function" then self[k] = v end
        end
    end
end

function Object:is(cls)
    local meta = getmetatable(self)
    while meta do
        if meta == cls then return true end
        meta = getmetatable(meta)
    end
    return false
end

--return Object.__call --function() return Object:extend() end
return Object