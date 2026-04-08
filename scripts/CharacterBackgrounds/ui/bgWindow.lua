---@diagnostic disable: missing-fields
local ui = require('openmw.ui')
local util = require('openmw.util')
local v2 = util.vector2
local I = require("openmw.interfaces")
local async = require("openmw.async")
local ambient = require("openmw.ambient")

local elements = require("scripts.CharacterBackgrounds.ui.templates.elements")
local C = require("scripts.CharacterBackgrounds.utils.consts")
local bgList = require("scripts.CharacterBackgrounds.model.backgroundList")

local textSize = 16
local contentWidth = 300
local contentHeight = 350
local topPadding = 8
local contentOuterPadding = 4
local contentCenterPadding = 6
local rootWidth = contentWidth * 2 + contentOuterPadding * 2 + contentCenterPadding
local scrollbarWidth = 21

local selectedBgIdx = 1

local root

local function padding(x, y)
    return {
        props = {
            size = util.vector2(x, y)
        }
    }
end

local function borderPadding(content)
    return {
        name = "wrapper",
        template = I.MWUI.templates.borders,
        props = {
            size = v2(contentWidth, contentHeight)
        },
        content = ui.content {
            {
                name = "padding",
                template = I.MWUI.templates.padding,
                content = ui.content { content }
            }
        }
    }
end




local descWrapper = borderPadding {
    name = "descFlex",
    type = ui.TYPE.Flex,
    props = {
        horizontal = false,
        autoSize = false,
        size = v2(contentWidth, contentHeight),
    },
    content = ui.content {
        ui.create {
            name = "header",
            template = I.MWUI.templates.textHeader,
            props = {
                text = "Header",
            }
        },
        padding(0, 5),
        ui.create {
            name = "description",
            template = I.MWUI.templates.textParagraph,
            props = {
                text =
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            },
            external = {
                stretch = .975,
                grow = 1,
            }
        },
    }
}


---@type table<number, Element>
local bgOptions = {}
for i, bg in ipairs(bgList) do
    local bgOption = ui.create {
        template = I.MWUI.templates.textNormal,
        props = {
            -- I know, I'm a genius
            text = bg.name .. "                                    "
        },
        userData = {
            idx = i,
            name = bg.name,
            desc = bg.description,
            selected = false,
        },
        events = {}
    }

    local events = bgOption.layout.events
    local props = bgOption.layout.props
    local userData = bgOption.layout.userData
    events.focusLoss = async:callback(function()
        props.textColor = userData.selected
            and C.Colors.ACTIVE
            or C.Colors.DEFAULT
        bgOption:update()
    end)
    events.focusGain = async:callback(function()
        props.textColor = userData.selected
            and C.Colors.ACTIVE_LIGHT
            or C.Colors.DEFAULT_LIGHT
        bgOption:update()
    end)
    events.mousePress = async:callback(function()
        ambient.playSound('menu click')
        props.textColor = userData.selected
            and C.Colors.ACTIVE_PRESSED
            or C.Colors.DEFAULT_PRESSED
        bgOption:update()
    end)
    events.mouseRelease = async:callback(function()
        if userData.selected then return end

        local prevActiveOption = bgOptions[selectedBgIdx * 2 - 1]
        prevActiveOption.layout.userData.selected = false
        prevActiveOption.layout.props.textColor = C.Colors.DEFAULT
        prevActiveOption:update()

        props.textColor = C.Colors.ACTIVE
        userData.selected = true
        selectedBgIdx = userData.idx
        bgOption:update()

        local descFlex = descWrapper.content["padding"].content[1]
        local descHeader = descFlex.content[1]
        local descDescription = descFlex.content[3]
        descHeader.layout.props.text = userData.name
        descDescription.layout.props.text = userData.desc
        descHeader:update()
        descDescription:update()
    end)

    bgOptions[#bgOptions + 1] = bgOption
    bgOptions[#bgOptions + 1] = padding(0, 2)
end
bgOptions[1].layout.events.mouseRelease()

local bgOptionsWrapper = elements.scrollable(
    v2(contentWidth - scrollbarWidth, contentHeight - 7),
    ui.content(bgOptions),
    v2(contentWidth - scrollbarWidth, contentHeight - 7),
    0,
    0,
    2,
    false,
    function() end,
    function() end,
    1,
    "scrollable"
)

local selectFlex = borderPadding {
    name = "selectFlex",
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        size = v2(contentWidth, contentHeight),
    },
    content = ui.content {
        bgOptionsWrapper,
        elements.scrollBar(bgOptionsWrapper),
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
        descWrapper,
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

local footer = ui.create {
    name = "footer",
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
                local idx = math.random(#bgOptions / 2)
                bgOptions[idx * 2 - 1].layout.events.mouseRelease()
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

root = ui.create {
    name = "root",
    layer = "Windows",
    template = I.MWUI.templates.boxTransparentThick,
    props = {
        relativePosition = v2(0.5, 0.5),
        anchor = v2(0.5, 0.5),
    },
    content = ui.content { {
        name = "rootPadding",
        template = I.MWUI.templates.padding,
        content = ui.content { {
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
                padding(0, contentOuterPadding),
                footer,
                padding(0, topPadding),
            }
        } }
    } }
}

root:update()
