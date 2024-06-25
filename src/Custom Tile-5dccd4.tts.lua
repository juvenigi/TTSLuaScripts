-- Deck playmat
-- contains zones for main deck, graveyard, burned cards, and initialization zones for binding/unbinding cards
-- attached snap points (positions): Vec{x, 0.1, 0} where x in {-2,-0,6,0,6,2} (*2 obj scale)
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

function scanZones(deckIds)
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
                    if deckIds then
                        table.insert(result[area], obj.getGUID())
                    else
                        local finalDeck = --[[---@type tts__Deck]] obj
                        local contents = finalDeck.getObjects()
                        for _, card in ipairs(contents) do
                            table.insert(result[area], card.guid)
                        end
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
--- Moves Cards or Decks to one of the predetermined locations
--- TODO: rotate / flip cards before making them land into the deckzone
---@param location "draw" | "discard" | "burn" | "set"
---@param guids table<string,string>
---@param teleport boolean set position instantaneously?
function moveGuidsToLocation(location, guids, teleport)
    local coords = self.getPosition()
    local scaleX = self.getScale().x
    if location == "draw" then
        coords = Vector.add(coords, Vector.new(-2 * scaleX, 0.1, 0))
    elseif location == "discard" then
        coords = Vector.add(coords, Vector.new(-0.6440823 * scaleX, 0.100000188, 0.0))
    elseif location == "burn" then
        coords = Vector.add(coords, Vector.new(0.6440823 * scaleX, 0.100000188, 0.0))
    else
        coords = Vector.add(coords, Vector.new(2 * scaleX, 0.100000188, 0.0))
    end

    for _, v in pairs(guids) do
        print(v)
        local obj = --[[---@type tts__Object]] getObjectFromGUID(v)
        if not (obj == nil) then
            if teleport then
                obj.setPosition(coords)
            else
                obj.setPositionSmooth(coords, false, true)
            end
        else
            print("obj is nil")
            print(v)
        end
    end
end


-- Placeholder click handler functions
function onclick_draw(_, player_click_color, _)
    print("onclick_draw")
    local playerCards = {}
    for _, item in ipairs(Player[player_click_color].getHandObjects()) do
        if item.type == "Card" then
            item.setRotation(Vector.new(0, 180, 180))
            playerCards[item.guid] = item.guid
        end
    end
    if next(playerCards) then
        moveGuidsToLocation("discard", playerCards, true)
    end
end

-- refill draw pile with cards from discard pile
function onclick_refill(_, player_click_color, _)
    print("onclick_refill")
    local discarded = toSet(scanZones(true).discard)
    for _, v in pairs(discarded) do
        getObjectFromGUID(v).setRotation(Vector.new(0, 180, 180))
    end
    moveGuidsToLocation("draw", discarded, false)
end

---@param _ tts__Object object the button attached to
---@param player_click_color string
---@param _ boolean true if not left click
function onclick_discard(_, player_click_color, _)
    print("onclick_discard")
    local playerCards = {}
    for _, item in ipairs(Player[player_click_color].getHandObjects()) do
        if item.type == "Card" then
            item.setRotation(Vector.new(0, 180, 0))
            playerCards[item.guid] = item.guid
        end
    end
    if next(playerCards) then
        moveGuidsToLocation("discard", playerCards, true)
    end
end

function onclick_vacuum(_, player_click_color, _)
    print("onclick_vacuum")
    moveGuidsToLocation("discard", cardRegistry, true)
end

---@param guidMask table<string,string>
function getDecksForHiddenObjects(guidMask)
    --for _, v in pairs(guidMask) do print(v) end
    ---@type table<string,string>
    local result = {}
    for _, obj in ipairs(getAllObjects()) do
        local objGUID = obj.getGUID()
        if obj.tag == "Deck" then
            print("found deck")
            local cards = obj.getObjects()
            if cards ~= nil then
                for _, card in ipairs(cards) do
                    print(card.guid)
                    if card.guid ~= nil and guidMask[card.guid] then
                        result[objGUID] = objGUID
                        break
                    end
                end
            end
        elseif (obj.tag == "Card") then
            print("found card")
            if (guidMask[objGUID]) then
                result[objGUID] = objGUID
            end
        end
    end

    print("found ids")
    for _, v in pairs(result) do
        print(v)
    end

    return result
end

function onclick_reset(_, player_click_color, _)
    print("onclick_reset")
    -- find out deck ids in case when cards got combined into decks
    local reachableIds = getDecksForHiddenObjects(cardRegistry)
    for _,id in pairs(reachableIds) do getObjectFromGUID(id).setRotation(Vector.new(0,180,180)) end
    moveGuidsToLocation("draw", reachableIds, true)
end

function onclick_unbind(_, player_click_color, _)
    print("onclick_unbind")
    local setZone = scanZones(false).set
    applySubtract(cardRegistry, setZone)
end

function onclick_bind(_, player_click_color, _)
    print("onclick_bind")
    local setZone = scanZones(false).set
    for _, v in pairs(setZone) do
        print(v)
    end
    applyUnion(cardRegistry, setZone)
end
