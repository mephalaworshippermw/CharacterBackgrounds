---@diagnostic disable: missing-fields
local ui = require('openmw.ui')
local auxUi = require("openmw_aux.ui")
local util = require('openmw.util')
local v2 = util.vector2
local I = require("openmw.interfaces")
local self = require("openmw.self")

local buttonTemplate = require("scripts.CharacterBackgrounds.ui.templates.button")
local VirtualList = require("scripts.CharacterBackgrounds.ui.templates.virtual_list.extras").VirtualListExt
local bgList = require("scripts.CharacterBackgrounds.model.backgroundList")

local textSize = 16
local contentWidth = 300
local contentHeight = 350
local topPadding = 8
local contentOuterPadding = 4
local contentCenterPadding = 6
local rootWidth = contentWidth * 2 + contentOuterPadding * 2 + contentCenterPadding
local startIndex = 1

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
                text = bgList[startIndex].name,
            }
        },
        padding(0, 5),
        ui.create {
            name = "description",
            template = I.MWUI.templates.textParagraph,
            props = {
                text = bgList[startIndex].description
            },
            external = {
                stretch = .975,
                grow = 1,
            }
        },
    }
}
local descFlex = descWrapper.content["padding"].content["descFlex"]
local descHeader = descFlex.content[1]
local descDesc = descFlex.content[3]



local virtualBgList = VirtualList.create {
    viewportSize = v2(contentWidth - 3, contentHeight - 3),
    itemSize = v2(contentWidth, 16),
    itemCount = #bgList,
    itemLayout = function(i, list)
        return list:createItemLayout {
            index = i,
            props = {
                text = bgList[i].name,
            },
            onMousePress = function ()
                descHeader.layout.props.text = bgList[i].name
                descDesc.layout.props.text = bgList[i].description
                descHeader:update()
                descDesc:update()

                list:changeSelection(i)
            end
        }
    end,
}

virtualBgList:setKeyPressHandler({
    setSelectedIndex = function(i)
        virtualBgList:changeSelection(i)
    end,
})

local content = {
    name = "content",
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        align = ui.ALIGNMENT.Center,
    },
    content = ui.content {
        padding(contentOuterPadding, 0),
        borderPadding(virtualBgList:getElement()),
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
        buttonTemplate.button(
            "Random",
            textSize,
            function()
                local idx = math.random(#bgList)
                virtualBgList:changeSelection(idx)
                virtualBgList:scrollToIndex(idx, "center")
            end,
            "buttonRandom",
            1
        ),
        padding(contentOuterPadding, 0),
        buttonTemplate.button(
            "OK",
            textSize,
            function()
                self:sendEvent("CharacterBackgrounds_bgSelected", virtualBgList:getSelectedIndex())
                auxUi.deepDestroy(root)
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

virtualBgList:changeSelection(startIndex)
root:update()
return VirtualList.getMouseWheelHandler()
