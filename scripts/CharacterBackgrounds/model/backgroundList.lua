local vfs = require("openmw.vfs")

local Background = require("scripts.CharacterBackgrounds.model.background")
local bgPath = "scripts/CharacterBackgrounds/backgrounds"

---@type table<number, Background>
local backgroundList = {}

local function sortByName(tbl)
    table.sort(tbl, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
end

for fileName in vfs.pathsWithPrefix(bgPath) do
    for _ = 1, 15 do
        local modName = fileName:gsub(".lua", "")
        local bg = Background:new(require(modName))
        backgroundList[#backgroundList + 1] = bg
        print(string.format("Loaded background '%s'", bg.id))
    end
end

sortByName(backgroundList)

return backgroundList
