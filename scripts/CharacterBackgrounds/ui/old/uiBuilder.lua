local ui = require('openmw.ui')
local util = require('openmw.util')
local v2 = util.vector2
local I = require("openmw.interfaces")

local bgList = require("scripts.CharacterBackgrounds.model.backgroundList")
local makeBorder = require("scripts.CharacterBackgrounds.ui.templates.border")
local makeButton = require("scripts.CharacterBackgrounds.ui.old.makeButton")
local selectedButton = nil
local listSize = 14
local currentIndex = 1
local borderThickness = 4
local borderFile = "thick"
local morrowindGold = util.color.rgb(0.792157, 0.647059, 0.376471)
local morrowindLight = util.color.rgb(0.87451, 0.788235, 0.623529)
local rootWidth = 800
local rootHeight = 450

local template = makeBorder(
    borderFile,
    util.color.rgb(1, 1, 1),
    borderThickness,
    {
        type = ui.TYPE.Image,
        props = {
            resource = ui.texture { path = 'black' },
            relativeSize = v2(1, 1),
            alpha = 0.8,
        }
    }
).borders

--container / window
local root = ui.create {
    type = ui.TYPE.Container,
    layer = 'Modal',
    name = "root",
    template = template,
    props = {
        relativePosition = v2(0.5, 0.5),
        anchor = v2(0.5, 0.5),
        autoSize = true,
        size = v2(rootWidth, rootHeight)
    },
    content = ui.content {},
}

-- add vertical flex for header/footer etc
local flex_V = {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        arrange = ui.ALIGNMENT.Center,
        horizontal = false,
    },
    content = ui.content {},
}
root.layout.content:add(flex_V)

-- Header
flex_V.content:add {
    name = 'text',
    type = ui.TYPE.Text,
    props = {
        -- relativePosition = v2(0.5,0),
        -- anchor = v2(0.5,0),
        text = "Select your background",
        textColor = morrowindGold,
        textShadow = true,
        textShadowColor = util.color.rgb(0, 0, 0),
        textSize = 16,
        textAlignH = ui.ALIGNMENT.Center,
        textAlignV = ui.ALIGNMENT.Center,
    },
}
flex_V.content:add {
    props = {
        size = v2(1, 1) * 5
    }
}


-- add horizontal flex for 2 column layout
local flex_V_H1 = {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        horizontal = true,
    },
    content = ui.content {},
}
flex_V.content:add(flex_V_H1)

flex_V.content:add {
    props = {
        size = v2(1, 1) * 5
    }
}

-- add vertical flex for list
local flex_V_H1_V1 = ui.create {
    type = ui.TYPE.Flex,
    name = "list",
    props = {
        horizontal = false,
        size = v2(300, rootHeight),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H1.content:add(flex_V_H1_V1)

-- add vertical flex for scrollbar
local flex_V_H1_V2 = ui.create {
    type = ui.TYPE.Flex,
    name = "scrollbar",
    props = {
        horizontal = false,
        size = v2(20, rootHeight),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H1.content:add(flex_V_H1_V2)

-- add vertical flex for right column (descriptions, etc)
local flex_V_H1_V3 = ui.create {
    type = ui.TYPE.Flex,
    name = "descriptionBox",
    props = {
        horizontal = false,
        size = v2(480, rootHeight),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H1.content:add(flex_V_H1_V3)

local description = ui.create {
    type = ui.TYPE.Text,
    name = "description",
    props = {
        multiline = true,
        wordWrap = true,
        relativeSize = v2(1, 1),
        autoSize = false,
    },
    template = I.MWUI.templates.textNormal
}
flex_V_H1_V3.layout.content:add(description)

local bottomButtonsHeight = 25
-- add horizontal flex for 2 column layout
local flex_V_H2 = {
    type = ui.TYPE.Flex,
    name = "footer",
    props = {
        horizontal = true,
        size = v2(rootWidth, bottomButtonsHeight),
        align = ui.ALIGNMENT.End,
    },
    content = ui.content {},
}
flex_V.content:add(flex_V_H2)

flex_V.content:add {
    props = {
        size = v2(1, 1) * 5
    }
}

local button_V_H2_V1 = makeButton(
    "Random",
    {
        size = v2(80, bottomButtonsHeight)
    },
    function()
        -- TODO add randomization
        ui.showMessage("Randomizing the background...")
    end,
    morrowindGold,
    root
)
flex_V_H2.content:add(button_V_H2_V1.box)

local button_V_H2_V2 = makeButton(
    "OK",
    {
        size = v2(50, bottomButtonsHeight)
    },
    function()
        -- TODO add picking
        root:destroy()
    end,
    morrowindGold,
    root
)
flex_V_H2.content:add(button_V_H2_V2.box)

local function generateButtonByIndex(i)
    local button
    return makeButton(
        bgList[i].name,
        {
            size = v2(300, 30)
        },
        function()
            description.layout.props.text = bgList[i].description
            description:update()

            if selectedButton then
                selectedButton.clickbox.userData.selected = false
                selectedButton.applyColor()
            end
            selectedButton = button
            button.clickbox.userData.selected = true
        end,
        morrowindGold,
        root
    )
end

for i = currentIndex, math.min(#bgList, currentIndex + listSize) do
    local button = generateButtonByIndex(i)
    flex_V_H1_V1.layout.content:add(button.box)
end

function OnMouseWheel(direction)
    direction = direction * 2
    local newIndex = math.max(1, math.min(#bgList - listSize, currentIndex - direction))
    if newIndex < currentIndex then
        -- upwards
        for i = currentIndex - 1, newIndex, -1 do
            local tempDestroy = flex_V_H1_V1.layout.content[#flex_V_H1_V1.layout.content]
            flex_V_H1_V1.layout.content[#flex_V_H1_V1.layout.content] = nil
            tempDestroy:destroy()

            local button = generateButtonByIndex(i)
            flex_V_H1_V1.layout.content:insert(1, button.box)
        end
        flex_V_H1_V1:update()
    elseif newIndex > currentIndex then
        -- downwards
        for i = currentIndex + 1, newIndex, 1 do
            local tempDestroy = flex_V_H1_V1.layout.content[1]
            table.remove(flex_V_H1_V1.layout.content, 1)

            local button = generateButtonByIndex(#bgList - i + 2)
            flex_V_H1_V1.layout.content:add(button.box)
            tempDestroy:destroy()
        end
        flex_V_H1_V1:update()
    end
    currentIndex = newIndex
end
