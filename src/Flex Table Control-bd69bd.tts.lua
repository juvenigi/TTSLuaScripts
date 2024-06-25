function onLoad()
    loadUI()
end

function loadUI()
    -- Define the base position for the first button
    local basePosition = { -2.3, 0.12, 0.9 }
    local buttonGap = 0.6  -- Distance between buttons
    local groupGap = 0.14  -- Extra gap between groups of two buttons

    -- Create an array of button configurations
    local buttons = {
        { click_function = "onclick_draw", label = "Draw", tooltip = "Draw cards." },
        { click_function = "onclick_refill", label = "Refill", tooltip = "Refill draw deck." },
        { click_function = "onclick_discard", label = "Discard", tooltip = "Discard cards." },
        { click_function = "onclick_vacuum", label = "Vacuum", tooltip = "Vacuum cards." },
        { click_function = "onclick_reset", label = "Reset", tooltip = "Reset deck." },
        { click_function = "onclick_reset", label = "Reset", tooltip = "Reset deck." },
        { click_function = "onclick_bind", label = "Bind", tooltip = "Bind cards to current Deck." },
        { click_function = "onclick_unbind", label = "Unbind", tooltip = "Unbind cards." },
    }

    -- Create buttons in a row
    for i, button in ipairs(buttons) do
        -- Calculate the position for each button
        local extraGap = math.floor((i - 1) / 2) * groupGap
        local position = {
            basePosition[1] + (i - 1) * buttonGap + extraGap,
            basePosition[2],
            basePosition[3]
        }

        createButton({
            click_function = button.click_function,
            label = button.label,
            tooltip = button.tooltip,
            position = position
        })
    end
end

function click_func()
    local selfcrd = self.getPosition()
    local areas = {
        draw = { -4 + selfcrd.x, 0 + selfcrd.y, 0 + selfcrd.z },
        discard = { -1 + selfcrd.x, 0 + selfcrd.y, 0 + selfcrd.z },
        burn = { 1 + selfcrd.x, 0 + selfcrd.y, 0 + selfcrd.z },
        set = { 4 + selfcrd.x, 0 + selfcrd.y, 0 + selfcrd.z }
    }

    local result = {
        draw = {},
        discard = {},
        burn = {},
        set = {}
    }

    for area, pos in pairs(areas) do
        local hitObjects = findHitsInArea(pos, { x = 0.1, y = 1, z = 0.1 })
        for _, hit in pairs(hitObjects) do
            local obj = hit.hit_object
            if obj then
                -- print(obj.type)

                if obj.type == "Deck" then
                    local deckObjects = getDeckObjects(--[[---@type tts__Deck]]obj)
                    for _, deckObj in ipairs(deckObjects) do
                        table.insert(result[area], deckObj)
                    end
                elseif obj.type == "Card" then
                    table.insert(result[area], obj.getGUID())
                end
            end
        end
    end

    return result
end

---@param deck tts__Deck
function getDeckObjects(deck)
    local result = {}
    local objects = deck.getObjects()
    for _, contained in ipairs(objects) do
        table.insert(result, contained.guid)
    end
    return result
end

function moveObjects(source, guid_mask, orig_destination)
    local dest = orig_dest -- will become a different thing

end

function findHitsInArea(pos, size)
    local hitList = Physics.cast({
        origin = pos,
        direction = { 0, 0, 1 },
        type = 3,
        size = size,
        max_distance = 0,
        debug = true,
    })

    return hitList
end

function createButton(params)
    local buttonParams = {
        click_function = params.click_function,
        function_owner = self,
        label = params.label,
        position = params.position,
        rotation = { 0, 0, 0 },
        width = 250,
        height = 60,
        font_size = 60,
        color = { 1, 1, 1 },
        font_color = { 0, 0, 0 },
        tooltip = params.tooltip
    }
    self.createButton(buttonParams)
end

-- Placeholder click handler functions
function onclick_draw()
    print("onclick_draw")
end

function onclick_refill()
    print("onclick_refill")
end

function onclick_discard()
    print("onclick_discard")
end

function onclick_vacuum()
    print("onclick_vacuum")
end

function onclick_reset()
    print("onclick_reset")
end

function onclick_unbind()
    print("onclick_unbind")
end

function onclick_bind()
    print("onclick_bind")
    local result = click_func()
    for key, entries in pairs(result) do
        print(key)
        for _, entry in ipairs(entries) do
            print(entry)
        end
    end
end