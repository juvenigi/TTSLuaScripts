-- Deck Playmat
-- contains zones for main deck, graveyard, burned cards, and initialization zones for binding/unbinding cards
-- attached snap points (positions): Vec{x, 0.1, 0} where x in {-2,-0,6,0,6,2} (*2 obj scale)
function onLoad(saved_data)
    drawUI()
end

--- convert a 1-indexed array to a self-keyed set
function toSet(array)
    ---@type table<string,string>
    local res = {}
    for _, guid in ipairs(array) do
        res[guid] = guid
    end
    return res
end

function drawUI()
    -- Create an array of button configurations
    local buttons = {
        { click_function = "onclick_draw", label = "Draw", tooltip = "Draw cards." },
        { click_function = "onclick_refill", label = "Refill", tooltip = "Refill draw deck." },
        { click_function = "onclick_discard", label = "Hand", tooltip = "Discard cards." },
        { click_function = "onclick_vacuum", label = "Board", tooltip = "Vacuum cards." },
        { click_function = "onclick_reset", label = "Reset D", tooltip = "Reset deck." },
        { click_function = "onclick_reset", label = "Reset D", tooltip = "Reset deck (same button)." },
        { click_function = "onclick_bind", label = "Bind", tooltip = "Register cards to the current deck." },
        { click_function = "onclick_unbind", label = "Unbind", tooltip = "Unbind all cards." },
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

        setupButtonParams({
            click_function = button.click_function,
            label = button.label,
            tooltip = button.tooltip,
            position = position
        })
    end
end

function setupButtonParams(params)
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

---@return table<string,tts__Object[]> objects of 4 respective zones (draw, discard, burn, set)
function scanZones()
    local selfVecAbs = self.getPosition()
    -- absolute position of deck areas to scan
    local areas = {
        draw = { -4 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        discard = { -1 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        burn = { 1 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z },
        set = { 4 + selfVecAbs.x, 0 + selfVecAbs.y, 0 + selfVecAbs.z }
    }
    ---@type table<string,tts__Object[]>
    local result = {
        draw = {},
        discard = {},
        burn = {},
        set = {}
    }
    for area, pos in pairs(areas) do
        local hitObjects = scanForObjects(pos, { x = 0.1, y = 1, z = 0.1 })
        for _, hit in pairs(hitObjects) do
            local obj = hit.hit_object
            if obj then
                if obj.type == "Deck" then
                    table.insert(result[area], obj)
                elseif obj.type == "Card" then
                    table.insert(result[area], obj)
                end
            end -- other object names are ignored
        end
    end
    return result
end

function scanForObjects(pos, size)
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
---@param location "draw" | "discard" | "burn" | "set"
---@param objects tts__Object[] objects to move
---@param teleport boolean will not smoothly move if true
---@param flip boolean flip card if true (backside up)
function moveToPile(location, objects, teleport, flip)
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

    for _, v in ipairs(objects) do
        if not (v == nil) then
            if flip then
                v.setRotation(Vector.new(0, 180, 180))
            else
                v.setRotation(Vector.new(0, 180, 0))
            end
            if teleport then
                v.setPosition(coords)
            else
                v.setPositionSmooth(coords, false, true)
            end
        else
            print("obj is nil")
            print(v)
        end
    end
end

---@param playerColor string of player
---@return tts__Object[] array of objects
function findPlayerOwnedObjects(playerColor, excludePlayerHand)
    ---@type tts__Object[]
    local playerCards = {}
    local handSet = toSet(Player[playerColor].getHandObjects())
    for _, obj in ipairs(getAllObjects()) do
        if obj.tag == "Deck" then
            local cards = obj.getObjects()
            local addThisDeck = false
            if cards ~= nil then
                for _, card in ipairs(cards) do
                    if card.gm_notes == playerColor then
                        addThisDeck = true
                        break
                    end
                end
            end
            if addThisDeck then
                table.insert(playerCards, obj)
            end
        elseif (obj.tag == "Card") then
            if obj.getGMNotes() == playerColor then
                if (not excludePlayerHand) or (handSet[obj] == nil) then
                    table.insert(playerCards, obj)
                end
            end
        end
    end
    return playerCards
end


-- Placeholder click handler functions
function onclick_draw(_, player_click_color, _)
    broadcastToColor("onclick_draw", player_click_color)
    local drawDeck = --[[---@type tts__Object]] scanZones().draw[1]
    drawDeck.deal(1, player_click_color)
end

-- refill draw pile with cards from discard pile
function onclick_refill(_, player_click_color, _)
    broadcastToColor("onclick_refill", player_click_color)
    local discardPile = scanZones().discard
    for _, v in ipairs(discardPile) do
        v.shuffle()
    end
    moveToPile("draw", discardPile, false, true)
end

---@param _ tts__Object object the button attached to
---@param player_click_color string
---@param _ boolean true if not left click
function onclick_discard(_, player_click_color, _)
    broadcastToColor("onclick_discard", player_click_color)
    local playerCards = {}
    for _, item in ipairs(Player[player_click_color].getHandObjects()) do
        if item.type == "Card" then
            item.setRotation(Vector.new(0, 180, 0))
            table.insert(playerCards, item)
        end
    end
    if next(playerCards) then
        moveToPile("discard", playerCards, true, false)
    end
end

function onclick_vacuum(_, player_click_color, _)
    broadcastToColor("onclick_vacuum", player_click_color)
    local zones = scanZones()
    local allZoneArray = concatTables(zones.draw, zones.discard, zones.burn, zones.set)
    local allZoneObjects = toSet(allZoneArray)
    local vacuumList = {}
    for _, obj in ipairs(findPlayerOwnedObjects(player_click_color, true)) do
        if allZoneObjects[obj] == nil then
            table.insert(vacuumList, obj)
        end
    end
    if next(vacuumList) then
        moveToPile("discard", vacuumList, true, false)
    end
end

function onclick_reset(_, player_click_color, _)
    broadcastToColor("onclick_reset", player_click_color)
    moveToPile("draw", findPlayerOwnedObjects(player_click_color, false), true, true)
end

function onclick_unbind(_, player_click_color, _)
    broadcastToColor("onclick_unbind", player_click_color)

    for _, deck in ipairs(scanZones().set) do
        if deck.type == "Deck" then
            if #deck.getObjects() == 2 then
                twoCardCallback(deck, "")
            else
                cardCallback(#deck.getObjects() - 1, deck, "")
            end
        elseif deck.type == "Card" then
            deck.setGMNotes("")
        end
    end
end

function concatTables(t1, t2, t3, t4)
    local result = {}
    for i = 1, #t1 do
        result[#result + 1] = t1[i]
    end
    for i = 1, #t2 do
        result[#result + 1] = t2[i]
    end
    for i = 1, #t3 do
        result[#result + 1] = t3[i]
    end
    for i = 1, #t4 do
        result[#result + 1] = t4[i]
    end

    return result
end

---@param cardIndex number
---@param deckObject tts__Object
---@param gmNote string
function cardCallback(cardIndex, deckObject, gmNote)
    local deckPos = deckObject.getPosition()
    if cardIndex == -1 then
        return
    end
    deckObject.takeObject({
        index = #deckObject.getObjects() - 1,
        position = Vector.add(deckPos, Vector.new(0, 2, 0)),
        smooth = false,
        callback_function = function(card)
            Wait.frames(function()
                card.setGMNotes(gmNote)
                deckObject.putObject(card)
                if cardIndex - 1 == -1 then
                    return
                end
                cardCallback(cardIndex - 1, deckObject, gmNote)
            end)
        end
    })
end

---@param cardIndex number
---@param deckObject tts__Object
---@param gmNote string
function cardDestroyCallback(cardIndex, deckObject)
    local deckPos = deckObject.getPosition()
    if cardIndex == -1 then
        return
    end
    deckObject.takeObject({
        index = #deckObject.getObjects() - 1,
        position = Vector.add(deckPos, Vector.new(0, 2, 0)),
        smooth = false,
        callback_function = function(card)
            Wait.frames(function()
                destroyObject(card)
                cardDestroyCallback(cardIndex - 1, deckObject, gmNote)
            end)
        end
    })
end

function twoCardCallback(deck, gmNote)
    local deckPos = Vector.add(deck.getPosition(), Vector.new(0, 2, 0))
    local objClone = deck.clone({ position = deckPos })
    deck.putObject(objClone)
    cardCallback(3, deck, gmNote)
    Wait.frames(function()
        cardDestroyCallback(1, deck)
    end, 10)
end

function onclick_bind(_, player_click_color, _)
    broadcastToColor("onclick_bind", player_click_color)
    for _, deck in ipairs(scanZones().set) do
        if deck.type == "Deck" then
            if #deck.getObjects() == 2 then
                twoCardCallback(deck, player_click_color)
            else
                cardCallback(#deck.getObjects() - 1, deck, player_click_color)
            end
        elseif deck.type == "Card" then
            deck.setGMNotes(player_click_color)
        end
    end
end
