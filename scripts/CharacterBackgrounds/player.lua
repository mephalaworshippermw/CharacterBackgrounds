-- require("scripts.CharacterBackgrounds.ui.old.uiBuilder")
require("scripts.CharacterBackgrounds.ui.statWindow")
local mouseWheelHandler = require("scripts.CharacterBackgrounds.ui.bgWindow")
local bgList = require("scripts.CharacterBackgrounds.model.backgroundList")
local currbgIdx = 1
local currBg = bgList[currbgIdx]

local function bgSelected(bgIdx)
    print(bgIdx)
end

local function onLoad(data)
    if not data then return end
    currBg = bgList[data.currBgIdx] or currBg
end

local function onSave()
    return {
        currBgIdx = currbgIdx,
    }
end

InitBgLine(currBg)

if currBg.onLoad then
    currBg:onLoad()
end

return {
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
        onMouseWheel = function(vertical, horizontal)
            mouseWheelHandler(vertical, horizontal)
        end,
    },
    eventHandlers = {
        CharacterBackgrounds_bgSelected = bgSelected,
    }
}
