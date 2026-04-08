---@diagnostic disable: missing-fields
local ui = require('openmw.ui')
local util = require('openmw.util')
local v2 = util.vector2
local I = require("openmw.interfaces")

local elements = require("scripts.CharacterBackgrounds.ui.templates.elements")
local makeBorder = require("scripts.CharacterBackgrounds.ui.templates.border")
local C = require("scripts.CharacterBackgrounds.utils.consts")
local bgList = require("scripts.CharacterBackgrounds.model.backgroundList")

local textSize = 16
local contentWidth = 300
local contentHeight = 350
local topPadding = 8
local contentOuterPadding = 4
local contentCenterPadding = 6
local rootWidth = contentWidth * 2 + contentOuterPadding * 2 + contentCenterPadding

local function padding(x, y)
    return {
        props = {
            size = util.vector2(x, y)
        }
    }
end

local function borderPadding(content)
    return {
        template = I.MWUI.templates.borders,
        props = {
            size = v2(contentWidth, contentHeight)
        },
        content = ui.content {
            {
                template = I.MWUI.templates.padding,
                content = ui.content { content }
            }
        }
    }
end



local descHeader = {
    template = I.MWUI.templates.textHeader,
    props = {
        text = "Header",
    }
}
local descText = {
    template = I.MWUI.templates.textParagraph,
    props = {
        text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    },
    external = {
        stretch = .975,
        grow = 1,
    }
}

local descFlex = borderPadding {
    name = "descFlex",
    type = ui.TYPE.Flex,
    props = {
        horizontal = false,
        autoSize = false,
        size = v2(contentWidth, contentHeight),
    },
    content = ui.content {
        descHeader,
        padding(0, 5),
        descText
    }
}

local selectFlex = borderPadding {
    name = "selectFlex",
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        size = v2(contentWidth, contentHeight),
    },
    content = ui.content {

    }
}

local content = {
    name = "content",
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        align = ui.ALIGNMENT.Center,
    },
    content = ui.content {
        padding(contentOuterPadding, 0),
        selectFlex,
        padding(contentCenterPadding, 0),
        descFlex,
        padding(contentOuterPadding, 0),
    }
}

local header = {
    name = "header",
    type = ui.TYPE.Text,
    template = I.MWUI.templates.textNormal,
    props = {
        text = "Select your background"
    }
}

local flex_V1 = {
    name = "flex_V1",
    type = ui.TYPE.Flex,
    props = {
        horizontal = false,
        arrange = ui.ALIGNMENT.Center,
    },
    content = ui.content {
        padding(0, topPadding),
        header,
        padding(0, contentOuterPadding),
        content,
        padding(0, contentOuterPadding)
    }
}

local root = ui.create {
    name = "root",
    layer = "Windows",
    template = I.MWUI.templates.boxTransparentThick,
    props = {
        relativePosition = v2(0.5, 0.5),
        anchor = v2(0.5, 0.5),
    },
    content = ui.content { {
        template = I.MWUI.templates.padding,
        content = ui.content {
            flex_V1
        }
    } }
}



local footer = ui.create {
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        size = v2(rootWidth, 0),
        align = ui.ALIGNMENT.End
    },
    content = ui.content {
        elements.button(
            "Random",
            textSize,
            function()
                ui.showMessage("Picking random background...")
            end,
            "buttonRandom",
            1
        ),
        padding(contentOuterPadding, 0),
        elements.button(
            "OK",
            textSize,
            function()
                root:destroy()
            end,
            "buttonOk",
            1
        ),
        padding(contentCenterPadding, 0),
    }
}
flex_V1.content:add(footer)
flex_V1.content:add(padding(0, topPadding))



root:update()
