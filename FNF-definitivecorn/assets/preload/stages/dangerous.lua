function onCreate()
	makeAnimatedLuaSprite('fire','dangerous/fire',-1250, -750)
	addAnimationByPrefix('fire','fire','fire',24,true)
	objectPlayAnimation('fire','fire',true)
	scaleObject('fire', 1.8, 1.8);
	addLuaSprite('fire', false)

	makeLuaSprite('car', 'dangerous/car', 1300, -300)
	scaleObject('car', 1.3, 1.3);
	addLuaSprite('car', false)

	makeLuaSprite('floor', 'dangerous/floor', -1500, 0)
	scaleObject('floor', 1.7, 1.7);
	addLuaSprite('floor', false)

	makeLuaSprite('blood', 'dangerous/blood', 1300, 500)
	addLuaSprite('blood', false)
    
	makeLuaSprite('carfront', 'dangerous/car_front', -1350, 400)
	scaleObject('carfront', 1.8, 1.8);
	addLuaSprite('carfront', false)
end