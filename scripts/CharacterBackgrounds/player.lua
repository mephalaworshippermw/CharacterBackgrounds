local vfs = require("openmw.vfs")

-- require("scripts.CharacterBackgrounds.ui.uiBuilder")
require("scripts.CharacterBackgrounds.ui.statWindow")
local Background = require("scripts.CharacterBackgrounds.model.background")
local bgPath = "scripts/CharacterBackgrounds/backgrounds"
local selectedBg = {
    id = "None",
    name = "-None-",
    description = "No background selected.",
}

local bgs = {}

for fileName in vfs.pathsWithPrefix(bgPath) do
    local modName = fileName:gsub(".lua", "")
    local bg = Background:new(require(modName))
    -- print(string.format("Loaded background '%s'", bg.id))
    bgs[bg.id] = bg
end

local function onLoad(data)
    selectedBg = data.selectedBg or selectedBg
end

local function onSave()
    return {
        selectedBg = selectedBg,
    }
end

InitBgLine(Background:new(selectedBg))

return {
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
        onFrame = OnFrame,
        onMouseWheel = OnMouseWheel,
    },
}
