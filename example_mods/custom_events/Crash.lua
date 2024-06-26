function onEvent(n,v1,v2)
	if n == "Crash" then
		if not lowQuality then
			makeLuaSprite('black','crash',-280,-160)
			setScrollFactor('black', 0, 0);
			scaleObject('black', 0.75, 0.75);
			addLuaSprite('black', true);
		end
	end
end

