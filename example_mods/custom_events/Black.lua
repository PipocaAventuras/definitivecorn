function onEvent(n,v1,v2)
	if n == "Black" then
		if not lowQuality then
			makeLuaSprite('black','the',-280,-160)
			setScrollFactor('black', 0, 0);
			scaleObject('black', 9.9, 9.9);
			addLuaSprite('black', true);
		end
	end
end

