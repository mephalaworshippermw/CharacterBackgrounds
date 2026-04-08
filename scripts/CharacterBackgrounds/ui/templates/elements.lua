---@diagnostic disable: missing-fields
local I = require("openmw.interfaces")
local util = require("openmw.util")
local async = require("openmw.async")
local ambient = require("openmw.ambient")
local ui = require("openmw.ui")
local auxUi = require("openmw_aux.ui")

local omwConstants = require('scripts.omw.mwui.constants')
local C = require("scripts.CharacterBackgrounds.utils.consts")
local helpers = require("scripts.CharacterBackgrounds.utils.helpers")

local SCROLL_BAR_OUTER_WIDTH = 16
local SCROLL_BAR_INNER_WIDTH = 14
local BORDER_THICKNESS = omwConstants.border

local Templates = {}

Templates.TEXTURES = {}
Templates.createTexture = function(path)
    if Templates.TEXTURES[path] then
        return Templates.TEXTURES[path]
    else
        local tex = ui.texture { path = path }
        Templates.TEXTURES[path] = tex
        return tex
    end
end

Templates.padding = function(size)
    size = util.vector2(1, 1) * size
    return {
        type = ui.TYPE.Container,
        content = ui.content {
            {
                props = {
                    size = size,
                },
            },
            {
                ---@diagnostic disable-next-line: missing-fields
                external = { slot = true },
                props = {
                    position = size,
                    relativeSize = util.vector2(1, 1),
                },
            },
            {
                props = {
                    position = size,
                    relativePosition = util.vector2(1, 1),
                    size = size,
                },
            },
        }
    }
end

Templates.intervalH = function(size)
    return {
        props = {
            size = util.vector2(size, 0),
        },
    }
end

Templates.intervalV = function(size)
    return {
        props = {
            size = util.vector2(0, size),
        },
    }
end

Templates.textNormal = helpers.deepCopy(I.MWUI.templates.textNormal)
Templates.textHeader = helpers.deepCopy(I.MWUI.templates.textHeader)
Templates.textParagraph = helpers.deepCopy(I.MWUI.templates.textParagraph)
Templates.textEditLine = helpers.deepCopy(I.MWUI.templates.textEditLine)
Templates.textNormal.props.textColor = C.Colors.DEFAULT
Templates.textHeader.props.textColor = C.Colors.DEFAULT_LIGHT
Templates.textParagraph.props.textColor = C.Colors.DEFAULT
Templates.textEditLine.props.textColor = C.Colors.DEFAULT
Templates.textNormal.props.textSize = Templates.TEXT_SIZE
Templates.textHeader.props.textSize = Templates.TEXT_SIZE
Templates.textParagraph.props.textSize = Templates.TEXT_SIZE
Templates.textEditLine.props.textSize = Templates.TEXT_SIZE
Templates.textEditLine.props.size = util.vector2(0, 0)

local v2 = util.vector2
local buttonBorderSize = 4
local borderSideParts = {
    left = v2(0, 0),
    right = v2(1, 0),
    top = v2(0, 0),
    bottom = v2(0, 1),
}
local borderCornerParts = {
    top_left_corner = v2(0, 0),
    top_right_corner = v2(1, 0),
    bottom_left_corner = v2(0, 1),
    bottom_right_corner = v2(1, 1),
}
local buttonBorderPattern = 'textures/menu_button_frame_%s.dds'

local buttonBorderResources = {}
local buttonBorderPieces = {}

for k in pairs(borderSideParts) do
    buttonBorderResources[k] = Templates.createTexture(buttonBorderPattern:format(k))
    local horizontal = (k == 'top' or k == 'bottom')
    buttonBorderPieces[k] = {
        type = ui.TYPE.Image,
        props = {
            resource = buttonBorderResources[k],
            tileH = horizontal,
            tileV = not horizontal,
        }
    }
end

for k in pairs(borderCornerParts) do
    buttonBorderResources[k] = Templates.createTexture(buttonBorderPattern:format(k))
    buttonBorderPieces[k] = {
        type = ui.TYPE.Image,
        props = {
            resource = buttonBorderResources[k],
        }
    }
end

Templates.buttonBorders = function(borderSize)
    local buttonBorderSize = borderSize or buttonBorderSize
    local template = {
        content = ui.content {},
    }
    for k, v in pairs(borderSideParts) do
        local horizontal = (k == 'top' or k == 'bottom')
        local direction = horizontal and v2(1, 0) or v2(0, 1)
        template.content:add {
            template = buttonBorderPieces[k],
            props = {
                position = (direction - v) * buttonBorderSize,
                relativePosition = v,
                size = (v2(1, 1) - direction * 3) * buttonBorderSize,
                relativeSize = direction,
            }
        }
    end
    for k, v in pairs(borderCornerParts) do
        template.content:add {
            template = buttonBorderPieces[k],
            props = {
                position = -v * buttonBorderSize,
                relativePosition = v,
                size = v2(buttonBorderSize, buttonBorderSize),
            }
        }
    end
    template.content:add {
        external = { slot = true },
        props = {
            position = v2(buttonBorderSize, buttonBorderSize),
            size = v2(buttonBorderSize * -2, buttonBorderSize * -2),
            relativeSize = v2(1, 1),
        }
    }
    return template
end

Templates.buttonBox = function()
    local template = {
        type = ui.TYPE.Container,
        content = ui.content {},
    }
    for k, v in pairs(borderSideParts) do
        local horizontal = (k == 'top' or k == 'bottom')
        local direction = horizontal and v2(1, 0) or v2(0, 1)
        template.content:add {
            template = buttonBorderPieces[k] and not intRe and buttonBorderPieces[k] or nil,
            props = {
                position = (direction + v) * buttonBorderSize,
                relativePosition = v,
                size = (v2(1, 1) - direction) * buttonBorderSize,
                relativeSize = direction,
            }
        }
    end
    for k, v in pairs(borderCornerParts) do
        template.content:add {
            template = buttonBorderPieces[k] and not intRe and buttonBorderPieces[k] or nil,
            props = {
                position = v * buttonBorderSize,
                relativePosition = v,
                size = v2(buttonBorderSize, buttonBorderSize),
            }
        }
    end
    template.content:add {
        external = { slot = true },
        props = {
            position = v2(buttonBorderSize, buttonBorderSize),
            relativeSize = v2(1, 1),
        }
    }
    return template
end

Templates.buttonBoxBgr = function(bgrAlpha)
    local template = auxUi.deepLayoutCopy(Templates.buttonBox())
    template.content:insert(1, {
        type = ui.TYPE.Image,
        props = {
            resource = Templates.createTexture('white'),
            color = C.Colors.BLACK,
            alpha = bgrAlpha or 0,
            relativeSize = v2(1, 1),
            size = v2(buttonBorderSize * 2, buttonBorderSize * 2),
        }
    })
    return template
end

Templates.button = function(text, textSize, onClick, name, bgrAlpha)
    local element = ui.create {
        name = name,
        template = Templates.buttonBoxBgr(bgrAlpha),
        props = {},
        content = ui.content {
            {
                type = ui.TYPE.Flex,
                props = {
                    horizontal = true,
                    arrange = ui.ALIGNMENT.Center,
                    textAlignV = ui.ALIGNMENT.Center,
                },
                content = ui.content {
                    Templates.intervalH(8),
                    {
                        name = "btnText",
                        template = Templates.textNormal,
                        props = {
                            text = text,
                            textSize = textSize,
                            textColor = C.Colors.DEFAULT,
                        },
                        userData = { colorable = true },
                    },
                    Templates.intervalH(8),
                }
            }
        },
        events = {},
        userData = {
            inFocus = false
        },
    }
    local btnText = element.layout.content[1].content[2]
    element.layout.events.focusLoss = async:callback(function()
        btnText.props.textColor = C.Colors.DEFAULT
        element:update()
    end)
    element.layout.events.focusGain = async:callback(function()
        btnText.props.textColor = C.Colors.DEFAULT_LIGHT
        element:update()
    end)
    element.layout.events.mousePress = async:callback(function()
        ambient.playSound('menu click')
        btnText.props.textColor = C.Colors.DEFAULT_PRESSED
        element:update()
    end)
    element.layout.events.mouseRelease = async:callback(function()
        if onClick then
            onClick()
        end
        btnText.props.textColor = C.Colors.DEFAULT_LIGHT
        element:update()
    end)
    return element
end

Templates.scrollBar = function(scrollable)
    local upButton = {
        template = I.MWUI.templates.borders,
        props = {
            size = util.vector2(SCROLL_BAR_INNER_WIDTH, SCROLL_BAR_INNER_WIDTH),
        },
        content = ui.content {
            {
                type = ui.TYPE.Image,
                props = {
                    resource = Templates.createTexture('textures/omw_menu_scroll_up.dds'),
                    size = util.vector2(SCROLL_BAR_INNER_WIDTH - 4, SCROLL_BAR_INNER_WIDTH - 4),
                }
            }
        },
        events = {
            mousePress = async:callback(function(e)
                if e.button ~= 1 then return end
                ambient.playSound('menu click')
                scrollable.layout.content[1].props.position = scrollable.layout.content[1].props.position +
                    util.vector2(0, scrollable.layout.userData.scrollStep)
                scrollable.layout.content[1].props.position = util.vector2(0,
                    util.clamp(scrollable.layout.content[1].props.position.y, -scrollable.layout.userData.scrollLimit, 0))
                scrollable.layout.userData.onScroll()
            end),
        }
    }

    local downButton = {
        template = I.MWUI.templates.borders,
        props = {
            size = util.vector2(SCROLL_BAR_INNER_WIDTH, SCROLL_BAR_INNER_WIDTH),
        },
        content = ui.content {
            {
                type = ui.TYPE.Image,
                props = {
                    resource = Templates.createTexture('textures/omw_menu_scroll_down.dds'),
                    size = util.vector2(SCROLL_BAR_INNER_WIDTH - 4, SCROLL_BAR_INNER_WIDTH - 4),
                }
            }
        },
        events = {
            mousePress = async:callback(function(e)
                if e.button ~= 1 then return end
                ambient.playSound('menu click')
                scrollable.layout.content[1].props.position = scrollable.layout.content[1].props.position -
                    util.vector2(0, scrollable.layout.userData.scrollStep)
                scrollable.layout.content[1].props.position = util.vector2(0,
                    util.clamp(scrollable.layout.content[1].props.position.y, -scrollable.layout.userData.scrollLimit, 0))
                scrollable.layout.userData.onScroll()
            end),
        }
    }

    local function calcScrollBarSize()
        return util.vector2(SCROLL_BAR_INNER_WIDTH,
            scrollable.layout.props.size.y - ((SCROLL_BAR_INNER_WIDTH + omwConstants.padding) * 2))
    end
    local function calcHandleSize()
        return math.max(
            (scrollable.layout.props.size.y / (scrollable.layout.userData.scrollLimit + scrollable.layout.props.size.y)) *
            (scrollable.layout.props.size.y - (SCROLL_BAR_INNER_WIDTH * 2)), SCROLL_BAR_INNER_WIDTH)
    end

    local function handlePosToScrollPos(y)
        local scrollBarSize = calcScrollBarSize()
        local handleSize = calcHandleSize()

        y = util.clamp(y - (handleSize / 2), 0, scrollBarSize.y - handleSize)
        local progress = y / (scrollBarSize.y - handleSize)
        return -progress * scrollable.layout.userData.scrollLimit
    end

    local scrollBar = {
        template = I.MWUI.templates.borders,
        name = 'scrollBar',
        props = {
            size = calcScrollBarSize(),
        },
        content = ui.content {
            {
                type = ui.TYPE.Image,
                name = 'handle',
                props = {
                    resource = Templates.createTexture('textures/omw_menu_scroll_center_v.dds'),
                    size = util.vector2(SCROLL_BAR_INNER_WIDTH - 4, calcHandleSize()),
                    --relativeSize = util.vector2(1, 0),
                    tileV = true,
                    propagateEvents = true,
                },
                events = {
                    mousePress = async:callback(function(e, layout)
                        ambient.playSound('menu click')
                        layout.userData.dragOffset = e.offset.y
                        return false
                    end),
                    mouseRelease = async:callback(function(e, layout)
                        layout.userData.dragOffset = nil
                        return false
                    end),
                },
                userData = {
                    dragOffset = nil,
                }
            }
        },
        events = {
            mouseMove = async:callback(function(e, layout)
                if e.button == 1 then
                    local adjustedY = e.offset.y - (layout.content[1].userData.dragOffset or (calcHandleSize() / 2)) +
                        (calcHandleSize() / 2)
                    scrollable.layout.content[1].props.position = util.vector2(0, handlePosToScrollPos(adjustedY))
                    scrollable.layout.content[1].props.position = util.vector2(0,
                        util.clamp(scrollable.layout.content[1].props.position.y, -scrollable.layout.userData
                            .scrollLimit, 0))
                    scrollable.layout.userData.onScroll()
                end
            end),
            mousePress = async:callback(function(e)
                if e.button == 1 then
                    ambient.playSound('menu click')
                    scrollable.layout.content[1].props.position = util.vector2(0, handlePosToScrollPos(e.offset.y))
                    scrollable.layout.content[1].props.position = util.vector2(0,
                        util.clamp(scrollable.layout.content[1].props.position.y, -scrollable.layout.userData
                            .scrollLimit, 0))
                    scrollable.layout.userData.onScroll()
                end
            end),
        }
    }

    local barWrapper = {
        type = ui.TYPE.Flex,
        name = 'scrollBarWrapper',
        props = {
            position = util.vector2(-SCROLL_BAR_OUTER_WIDTH + (SCROLL_BAR_OUTER_WIDTH - SCROLL_BAR_INNER_WIDTH) / 2, 0),
            relativePosition = util.vector2(1, 0),
        },
        content = ui.content {
            upButton,
            Templates.intervalV(omwConstants.padding),
            scrollBar,
            Templates.intervalV(omwConstants.padding),
            downButton,
        }
    }

    return barWrapper
end

Templates.scrollable = function(size, content, flexSize, padding, borderThickness, scrollStep, alwaysShowBar, onFocusGain,
                                onFocusLoss, startScrollPos, name)
    ---@diagnostic disable-next-line: missing-fields
    local scrollWidget = ui.create {
        name = name or 'scrollable',
        props = {
            size = size,
            position = util.vector2(padding, padding),
        },
        content = ui.content {
            {
                type = ui.TYPE.Flex,
                props = {
                    horizontal = false,
                    autoSize = false,
                    size = flexSize,
                    relativeSize = util.vector2(1, 0),
                    position = util.vector2(0, 0),
                },
                content = content or ui.content {},
            }
        },
        userData = {
            scrollLimit = math.max(flexSize.y - size.y, 0),
            canScroll = flexSize.y > size.y,
            scrollStep = scrollStep,
        },
    }
    scrollWidget.layout.events = {
        focusGain = async:callback(function() onFocusGain(scrollWidget) end),
        focusLoss = async:callback(function() onFocusLoss(scrollWidget) end),
    }

    local scrollBar = Templates.scrollBar(scrollWidget)
    ---@diagnostic disable-next-line: undefined-field
    scrollBar.content.scrollBar.props.anchor = util.vector2(1, 0)
    scrollWidget.layout.content:add(scrollBar)

    scrollWidget.layout.userData.onScroll = function()
        scrollWidget.layout.content[1].props.position = util.vector2(0,
            util.clamp(scrollWidget.layout.content[1].props.position.y, -scrollWidget.layout.userData.scrollLimit, 0))
        ---@diagnostic disable-next-line: undefined-field
        local handle = scrollBar.content.scrollBar.content.handle
        local scrollProgress = -scrollWidget.layout.content[1].props.position.y /
            scrollWidget.layout.userData.scrollLimit
        local handleProgress = (scrollWidget.layout.props.size.y - ((SCROLL_BAR_INNER_WIDTH + omwConstants.padding) * 2) - handle.props.size.y - 4) *
            scrollProgress
        handle.props.position = util.vector2(0, handleProgress)
        scrollWidget:update()
    end

    if startScrollPos then
        scrollWidget.layout.content[1].props.position = util.vector2(0,
            util.clamp(startScrollPos, -scrollWidget.layout.userData.scrollLimit, 0))
    end

    scrollWidget.layout.userData.update = function(outerSize, innerSize)
        outerSize = (outerSize or scrollWidget.layout.props.size) -
            util.vector2((padding + borderThickness) * 2, (padding + borderThickness) * 2)
        innerSize = innerSize or scrollWidget.layout.content[1].props.size

        local scrollLimit = math.max(innerSize.y - outerSize.y - padding * 2, 0)
        local canScroll = scrollLimit > 0

        scrollWidget.layout.props.size = outerSize
        scrollWidget.layout.content[1].props.size = innerSize
        scrollWidget.layout.userData.scrollLimit = scrollLimit
        scrollWidget.layout.userData.canScroll = canScroll

        ---@diagnostic disable-next-line: undefined-field
        scrollBar.content.scrollBar.props.size = util.vector2(
            SCROLL_BAR_INNER_WIDTH,
            scrollWidget.layout.props.size.y - ((SCROLL_BAR_INNER_WIDTH + omwConstants.padding) * 2)
        )
        if canScroll then
            ---@diagnostic disable-next-line: undefined-field
            scrollBar.content.scrollBar.content.handle.props.size = util.vector2(
                SCROLL_BAR_INNER_WIDTH - BORDER_THICKNESS * 2 - 1,
                math.max(
                    (scrollWidget.layout.props.size.y / (scrollWidget.layout.userData.scrollLimit + scrollWidget.layout.props.size.y)) *
                    ---@diagnostic disable-next-line: undefined-field
                    scrollBar.content.scrollBar.props.size.y, SCROLL_BAR_INNER_WIDTH)
            )
        else
            ---@diagnostic disable-next-line: undefined-field
            scrollBar.content.scrollBar.content.handle.props.size = util.vector2(0, 0)
        end
        if canScroll or alwaysShowBar then
            scrollWidget.layout.content[1].props.size = util.vector2(-SCROLL_BAR_OUTER_WIDTH - BORDER_THICKNESS * 2,
                scrollWidget.layout.content[1].props.size.y)
            scrollBar.props.visible = true
        else
            scrollWidget.layout.content[1].props.size = util.vector2(0, scrollWidget.layout.content[1].props.size.y)
            scrollBar.props.visible = false
        end
        scrollWidget.layout.userData.onScroll()
    end

    scrollWidget.layout.userData.update(size, flexSize)

    return scrollWidget
end

Templates.bordersEmpty = {
    props = {},
    content = ui.content {
        {
            external = { slot = true },
            props = {
                position = v2(0, 0),
                relativeSize = v2(1, 1),
            }
        }
    }
}

Templates.bordersInvisible = auxUi.deepLayoutCopy(I.MWUI.templates.borders)
for _, part in pairs(Templates.bordersInvisible.content) do
    if not part.external then
        part.template = nil
    end
end

return Templates
