function onLoad(saved_data)
    --Loads the tracking for if the game has started yet
    print("onLoad")
    valueData = ""
    if saved_data then
        valueData = JSON.decode(saved_data)[1]
    end
    local rotZ = self.getRotation().z
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
end

function onInput(self, ply, text, selected)
    self.reload()
end

function updateSave()
    saved_data = JSON.encode({ valueData })
    self.script_state = saved_data
end
