function onload(saved_data)
    copied_state = { height = 0.5, scale = 1, fields = {} }
    savedPos = nil

    self.createButton({
        click_function = "click_func",
        function_owner = self,
        label = "Translocate",
        position = { 0, 1.35, 0 },
        rotation = { 0, 180, 0 },
        width = 600,
        height = 600,
        font_size = 150,
        color = { 0.2, 0.2, 0.2 },
        font_color = { 1, 1, 1 },
        tooltip = "Click to translocate",
    })
end

function click_func(obj, color, alt_click)
    local pos = { x = self.getPosition().x, y = self.getPosition().y - 1.2, z = self.getPosition().z }
    local size = { x = 0.5, y = 1, z = 0.5 }
    for k, v in pairs(findHitsInArea(pos, size)) do
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
function patch(target)
    if not savedPos then
        savedPos = self.getPosition()
        return
    else
        target.setPositionSmooth(savedPos, false, true)
        savedPos = nil
    end
end
