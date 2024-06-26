function onEvent(n,v1,v2)
	if n == 'jumpscarexe' then

	    makeLuaSprite('flash', 'speedu_jumpscare', 0, 0);
	    addLuaSprite('flash', true);
	    setLuaSpriteScrollFactor('flash',0,0)
	    setProperty('flash.scale.x',1.3)
	    setProperty('flash.scale.y',1.3)
	    setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,v1,'linear')
	end
end