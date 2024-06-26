function onEvent(name, value1, value2)
    if name == "CharacterPlayAnimation" then
        doIdle = false
        addAnimationByPrefix(value2, value1, value1, 24, false)
        objectPlayAnimation(value2, value1, true);
    end
end