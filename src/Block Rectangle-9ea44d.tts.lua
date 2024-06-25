-- test code
function onLoad()
    flag = false
end


function onRotate(spin, flip, player_color, old_spin, old_flip)
    print(flag)
    flag = not flag
end