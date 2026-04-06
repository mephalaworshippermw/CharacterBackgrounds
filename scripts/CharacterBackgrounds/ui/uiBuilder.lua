local ui = require('openmw.ui')
local util = require('openmw.util')
local v2 = util.vector2

local onFrameFunctions = {}
local makeBorder = require("scripts.CharacterBackgrounds.ui.makeBorder")
local makeButton = require("scripts.CharacterBackgrounds.ui.makeButton")
local selectedButton = nil
local listSize = 19
local currentIndex = 20

local morrowindGold = util.color.rgb(0.792157, 0.647059, 0.376471)
local morrowindLight = util.color.rgb(0.87451, 0.788235, 0.623529)

local exampleData = {}
for _ = 1, 100 do
    table.insert(exampleData, "" .. math.floor(math.random() * 100000))
end



-- creating the demo ui onload
-- local template = {
--     content = ui.content { {
--         type = ui.TYPE.Image,
--         name = "timeHudBackground",
--         props = {
--             resource = ui.texture { path = 'black' },
--             relativeSize = v2(1, 1), -- Fill entire container
--             alpha = BACKGROUND_ALPHA
--         }
--     } }
-- }
local borderOffset = 3
local borderFile = "thick"
local template = makeBorder(borderFile, util.color.rgb(0.5, 0.5, 0.5), borderOffset, {
    type = ui.TYPE.Image,
    props = {
        resource = ui.texture { path = 'black' },
        relativeSize = v2(1, 1),
        alpha = 0.8,
    }
}).borders

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
        size = v2(800, 600)
    },
    content = ui.content {},
}

-- add vertical flex for header/footer etc
local flex_V = {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
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
        --relativePosition = v2(0.5,0.5),
        --anchor = v2(0.5,0.5),
        text = "Select your background",
        textColor = util.color.rgb(0.792157, 0.647059, 0.376471),
        textShadow = true,
        textShadowColor = util.color.rgb(0, 0, 0),
        textSize = 24,
        textAlignH = ui.ALIGNMENT.Center,
        textAlignV = ui.ALIGNMENT.Center,
    },
}
flex_V.content:add { props = { size = v2(1, 1) * 5 } }


-- add horizontal flex for 2 column layout
local flex_V_H = {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        horizontal = true,
    },
    content = ui.content {},
}
flex_V.content:add(flex_V_H)

flex_V.content:add { props = { size = v2(1, 1) * 5 } }

-- add vertical flex for scrollbar
local flex_V_H_V1 = ui.create {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        horizontal = false,
        size = v2(20, 600),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H.content:add(flex_V_H_V1)

-- add vertical flex for list
local flex_V_H_V2 = ui.create {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        horizontal = false,
        size = v2(300, 600),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H.content:add(flex_V_H_V2)

-- add vertical flex for right column (descriptions, etc)
local flex_V_H_V3 = ui.create {
    type = ui.TYPE.Flex,
    name = "foobar",
    props = {
        horizontal = false,
        size = v2(480, 600),
        autoSize = false,
    },
    content = ui.content {},
}
flex_V_H.content:add(flex_V_H_V3)



for i = currentIndex, math.min(#exampleData, currentIndex + listSize) do
    local button
    button = makeButton("Confirm" .. i, { size = v2(300, 30) }, function()
        ui.showMessage("Confirm" .. i .. "clicked")
        if selectedButton then
            selectedButton.clickbox.userData.selected = false
            selectedButton.applyColor()
        end
        selectedButton = button
        button.clickbox.userData.selected = true
    end, morrowindGold, root)
    flex_V_H_V2.layout.content:add(button.box)
end

-- required onFrame function to allow for cancelling a button click
function OnFrame(dt)
    for _, onFrameFunction in pairs(onFrameFunctions) do
        onFrameFunction(dt)
    end
end


function OnMouseWheel(direction)
    direction = direction * 2
    local newIndex = math.max(1, math.min(#exampleData - listSize + 1, currentIndex - direction))
    if newIndex < currentIndex then
        for i = currentIndex - 1, newIndex, -1 do
            local tempDestroy = flex_V_H_V2.layout.content[#flex_V_H_V2.layout.content]
            flex_V_H_V2.layout.content[#flex_V_H_V2.layout.content] = nil
            tempDestroy:destroy()

            local button
            button = makeButton("Confirm" .. i, { size = v2(300, 30) }, function()
                ui.showMessage("Confirm" .. i .. "clicked")
                if selectedButton then
                    selectedButton.clickbox.userData.selected = false
                    selectedButton.applyColor()
                end
                selectedButton = button
                button.clickbox.userData.selected = true
            end, morrowindGold, root)
            flex_V_H_V2.layout.content:insert(1, button.box)
        end
        flex_V_H_V2:update()
    elseif newIndex > currentIndex then
        for i = currentIndex + 1, newIndex, 1 do
            local tempDestroy = flex_V_H_V2.layout.content[1]
            table.remove(flex_V_H_V2.layout.content, 1)

            local button
            button = makeButton("Confirm" .. i, { size = v2(300, 30) }, function()
                ui.showMessage("Confirm" .. i .. "clicked")
                if selectedButton then
                    selectedButton.clickbox.userData.selected = false
                    selectedButton.applyColor()
                end
                selectedButton = button
                button.clickbox.userData.selected = true
            end, morrowindGold, root)
            flex_V_H_V2.layout.content:add(button.box)
            tempDestroy:destroy()
        end
        flex_V_H_V2:update()
    end
    currentIndex = newIndex
end
