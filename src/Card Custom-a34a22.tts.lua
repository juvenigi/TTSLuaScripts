function onLoad(saved_data)
    --Loads the tracking for if the game has started yet
    print("onLoad")
    valueData = ""
    if saved_data then
        valueData = JSON.decode(saved_data)[1]
    end

    -- this is very funky, and it's theoretically better done using modulo arithmetic, but rotation values are purely wack
    local rotZ = self.getRotation().z
    if rotZ > 270 then rotZ = rotZ - 360 end
    if (rotZ < 180) then
        isFlipped = true
        self.createInput {
            input_function = "onInput",
            function_owner = self,
            label = "Write here",
            alignment = 3,
            position = { 0, 0.4, 0 },
            rotation = { 180, 90, 0 },
            scale = { -1, -1, 1 },
            width = 1300,
            height = 860,
            value = valueData,
            font_size = 60,
        }
    else
        isFlipped = false
        self.createInput {
            input_function = "onInput",
            function_owner = self,
            label = "Write here",
            alignment = 3,
            position = { 0, 0.4, 0 },
            rotation = { 0, 90, 0 },
            scale = { 1, 1, 1 },
            width = 1300,
            height = 860,
            value = valueData,
            font_size = 60,
        }
    end
end

function onInput(self, ply, text, selected)
    if not selected then
        valueData = text
        updateSave()
    end
end

function onRotate(spin, flip, player_color, old_spin, old_flip)
    -- track if the card is flipped
    if flip ~= old_flip then
        print(player_color .. " flipped " .. tostring(self) .. " from " .. old_flip .. " degrees to " .. flip .. " degrees")
        setInputReadonly()
    end
end

function setInputReadonly()
    if isFlipped then
        self.editInput({ index = 0, rotation = { 0, 90, 0 }, scale = { 1, 1, 1 } })
    else
        self.editInput({ index = 0, rotation = { 180, 90, 0 }, scale = { -1, -1, 1 } })
    end
    isFlipped = not isFlipped
end

function updateSave()
    saved_data = JSON.encode({ valueData })
    self.script_state = saved_data
end