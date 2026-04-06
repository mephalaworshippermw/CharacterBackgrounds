---@class Background
---@field id string id of the background
---@field name string The name of the background
---@field description string A description of the background
---@field checkDisabled? fun():boolean  *(Optional)* Returns true if this background is disabled
---@field doOnce? fun(self: Background) *(Optional)* Called once when background is selected.
---@field onLoad? fun(self: Background) *(Optional)* Called on load and when background is selected.
local Background = {}
Background.__index = Background

function Background:new(data)
    assert(
        data.id ~= nil,
        "Background must have an id."
    )
    assert(
        data.name ~= nil,
        string.format("Background '%s' must have a name.", data.id)
    )
    assert(
        data.description ~= nil,
        string.format("Background '%s' must have a description.", data.id)
    )

    local obj = setmetatable({}, Background)
    for k, v in pairs(data) do
        obj[k] = v
    end

    return obj
end

return Background
