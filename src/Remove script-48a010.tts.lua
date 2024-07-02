function onload(saved_data)
    copied_state = { height = 0.5, scale = 1, fields = {} }
    savedPos = nil
    cardData = [[function onload(saved_data)
    --Loads the tracking for if the game has started yet
    valueData = ""
    if saved_data then

        valueData = JSON.decode(saved_data)[1]

    end
    self.createInput {
        input_function = "onInput",
        function_owner = self,
        label          = "Write here",
        alignment      = 3,
        position       = {0,0.4,0},
        rotation       = {0,90,0},

        width          = 1300,
        height         = 860,

        value          = valueData,
        font_size      = 60,
    }
end

function onInput(self, ply, text, selected)
    if not selected then
        valueData = text
        updateSave()
    end
end

function updateSave()
    saved_data = JSON.encode({valueData})
    self.script_state = saved_data
end]]

    self.createButton({
        click_function = "click_func",
        function_owner = self,
        label = "Unpatch Cards",
        position = { 0, 1.35, 0 },
        rotation = { 0, 180, 0 },
        width = 600,
        height = 600,
        font_size = 150,
        color = { 0.2, 0.2, 0.2 },
        font_color = { 1, 1, 1 },
        tooltip = "Click to change the script of a card / deck",
    })
end

function click_func(obj, color, alt_click)
    local pos = { x = self.getPosition().x, y = self.getPosition().y - 1.2, z = self.getPosition().z }
    local size = { x = 0.5, y = 1, z = 0.5 }
    for k, v in pairs(scanForObjects(pos, size)) do
        if (v.hit_object ~= self) then
            if (v.hit_object.type ~= "Surface") then
                local name = v.hit_object.getName()
                if (name == "") then
                    name = v.hit_object.type
                end
                translocate(v.hit_object)
                return
            end
        end
    end
    broadcastToColor("Place on top of an object to remove the script", color)
end

function findHitsInArea(pos, size)
    local hitList = Physics.cast({
        origin = pos,
        direction = { 0, 1, 0 },
        type = 3,
        size = size,
        max_distance = 0,
        debug = true,
    })

    return hitList
end

---@param target tts__Object
function translocate(target)
    if target.type == "Card" then
        target.script_code = cardData
        target.reload()
    elseif target.type == "Deck" then
        patchDeck(target)
    end
end

---@param deck tts__Deck
function patchDeck(deck)
    local cardCount = #deck.getObjects()
    if cardCount == 2 then
        twoCardCallback(deck)
    else
        cardCallback(cardCount - 1, deck)
    end
end

function twoCardCallback(deck)
    local deckPos = Vector.add(deck.getPosition(), Vector.new(0, 10, 0))
    local objClone = deck.clone({ position = deckPos })
    deck.putObject(objClone)
    cardCallback(3, deck)
    Wait.frames(function()
        cardDestroyCallback(1, deck)
    end, 10)
end

---@param cardIndex number
---@param deckObject tts__Object
function cardCallback(cardIndex, deckObject)
    local deckPos = deckObject.getPosition()
    if cardIndex < 0 then
        return
    end
    deckObject.takeObject({
        index = #deckObject.getObjects() - 1,
        position = Vector.add(deckPos, Vector.new(0, 10, 0)),
        smooth = false,
        callback_function = function(card)
            Wait.frames(function()
                card.script_code = cardData
                local reloaded = card.reload()
                Wait.frames(function()
                    deckObject.putObject(reloaded)
                end)
                if cardIndex - 1 < 0 then
                    return
                end
                print("calling callback")
                print(cardIndex-1)
                cardCallback(cardIndex - 1, deckObject)
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
        position = Vector.add(deckPos, Vector.new(0, 10, 0)),
        smooth = false,
        callback_function = function(card)
            Wait.frames(function()
                destroyObject(card)
                cardDestroyCallback(cardIndex - 1, deckObject)
            end)
        end
    })
end
