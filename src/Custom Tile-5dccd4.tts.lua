-- Deck playmat
-- contains zones for main deck, graveyard, burned cards, and initialization zones for binding/unbinding cards
-- attached snap points (positions)
--"AttachedSnapPoints": [
--        {
--          "Position": {
--            "x": 2.0,
--            "y": 0.100000188,
--            "z": 0.0
--          }
--        },
--        {
--          "Position": {
--            "x": 0.6440823,
--            "y": 0.100000188,
--            "z": 0.0
--          }
--        },
--        {
--          "Position": {
--            "x": -0.6440823,
--            "y": 0.100000188,
--            "z": 0.0447075181
--          }
--        },
--        {
--          "Position": {
--            "x": -2.0,
--            "y": 0.100000188,
--            "z": 0.0
--          }
--        }

function onLoad(saved_data)
    ---@type table<string,string>

    if saved_data then
        cardRegistry = JSON.decode(saved_data)[1]
        print(type(cardRegistry))
    end
    if cardRegistry == nil then
        cardRegistry = {}
    end

    loadUI()
end

function updateSave()
    self.script_state = JSON.encode({ cardRegistry })
end

---@param guids string[]
---@param set table<string,string>
function applyUnion(set, guids)
    print("applyUnion")
    for _, guid in ipairs(guids) do
        set[guid] = guid
    end
    updateSave()
end

---@param guids string[]
---@param set table<string,string>
function applySubtract(set, guids)
    for _, guid in ipairs(guids) do
        set[guid] = nil
    end
    updateSave()
end
---@param array string[]
function toSet(array)
    ---@type table<string,string>
    local res = {}
    for _, guid in ipairs(array) do
        res[guid] = guid
    end
    return res
end

function loadUI()
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
    -- Define the base position for the first button
    local basePosition = { -2.3, 0.12, 0.9 }
    local buttonGap = 0.6  -- Distance between buttons
    local groupGap = 0.14  -- Extra gap between groups of two buttons
    -- Create buttons in a row (this is peak jank, but it works)
    for i, button in ipairs(buttons) do
        -- Calculate the position for each button
        local buttonCount = (i - 1) * buttonGap
        local groupCount = math.floor((i - 1) / 2) * groupGap
        local position = {
            basePosition[1] + buttonCount + groupCount,
            basePosition[2],
            basePosition[3]
        }

        initButton({
            click_function = button.click_function,
            label = button.label,
            tooltip = button.tooltip,
            position = position
        })
    end
end

function initButton(params)
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

function scanZones()
    local selfVecAbs = self.getPosition()
    -- absolute position of deck areas to scan
    local areas = {
        draw = { -4 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        discard = { -1 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        burn = { 1 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        set = { 4 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z }
    }
    ---@type table<string,string[]>
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
                if obj.type == "Deck" then
                    local finalDeck = --[[---@type tts__Deck]] obj
                    local contents = finalDeck.getObjects()
                    for _, card in ipairs(contents) do
                        table.insert(result[area], card.guid)
                    end
                elseif obj.type == "Card" then
                    table.insert(result[area], obj.getGUID())
                end
            end -- other object names are ignored
        end
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
---@param location "draw" | "discard" | "burn" | "set"
---@param guids table<string,string>
function moveGuidsToLocation(location, guids)
    local coords = self.getPosition()
    local scaleX = self.getScale().x
    if location == "draw" then
        coords = Vector.add(coords, Vector.new(-2 * scaleX, 0.1, 0))
        --coords = Vector.add(coords, Vector.new(4.0, 0.100000188, 0.0))
    elseif location == "discard" then
        coords = Vector.add(coords, Vector.new(0.6440823 * scaleX, 0.100000188, 0.0))
    elseif location == "burn" then
        coords = Vector.add(coords, Vector.new(-0.6440823 * scaleX, 0.100000188, 0.0))
    else
        coords = Vector.add(coords, Vector.new(-2 * scaleX, 0.100000188, 0.0))
    end

    for _, v in pairs(guids) do
        print(v)
        local obj = --[[---@type tts__Object]] getObjectFromGUID(v)
        if not (obj == nil) then
            obj.setPositionSmooth(coords, false, true)
        else
            print("obj is nil")
            print(v)
        end
    end
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
    moveGuidsToLocation("burn", cardRegistry)

end

function onclick_vacuum()
    print("onclick_vacuum")
    moveGuidsToLocation("discard", cardRegistry)
end

function onclick_reset()
    print("onclick_reset")

    moveGuidsToLocation("draw", cardRegistry)
end

function onclick_unbind()
    print("onclick_unbind")
    local setZone = scanZones().set
    applySubtract(cardRegistry, setZone)
end

function onclick_bind()
    print("onclick_bind")
    local setZone = scanZones().set
    for _, v in pairs(setZone) do
        print(v)
    end
    applyUnion(cardRegistry, setZone)
end