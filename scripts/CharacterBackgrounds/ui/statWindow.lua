local I = require("openmw.interfaces")

local API = I.StatsWindow
local C = API.Constants

---@param bg Background
function UpdateBgLine(bg)
    API.modifyLine("Background", {
        value = function()
            return { string = bg.name }
        end,
        tooltip = function()
            return API.TooltipBuilders.HEADER(bg.name, bg.description)
        end
    })
end

---@param bg Background
function InitBgLine(bg)
    API.addLineToSection("Background", C.DefaultSections.LEVEL_STATS, {
        label = "Background",
        labelColor = C.Colors.DEFAULT_LIGHT,
        value = function()
            return { string = bg.name }
        end,
        tooltip = function()
            return API.TooltipBuilders.HEADER(bg.name, bg.description)
        end
    })
end
