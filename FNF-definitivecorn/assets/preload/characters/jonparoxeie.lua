function onCreate()

	makeAnimatedLuaSprite('icon-animatejnopadieor', 'icons/icon-animatejonparoxeie', getProperty('iconP2.x'), getProperty('iconP2.y'))
	addAnimationByPrefix('icon-animatejnopadieor', 'idle', 'icon-animatejnopadieor', 24, false)
	setObjectCamera('icon-animatejnopadieor', 'hud')
	addLuaSprite('icon-animatejnopadieor', true)

end

function onUpdate(elapsed)

	setObjectOrder('icon-animatejnopadieor', getObjectOrder('iconP1') + 10)

	setProperty('icon-animatejnopadieor.flipX', false)
	setProperty('icon-animatejnopadieor.visible', true)
	setProperty('icon-animatejnopadieor.x', getProperty('iconP2.x') - 0)
	setProperty('icon-animatejnopadieor.angle', getProperty('iconP2.angle'))
	setProperty('icon-animatejnopadieor.y', getProperty('iconP2.y') - 0)
	setProperty('icon-animatejnopadieor.scale.x', getProperty('iconP2.scale.x') - 0)
	setProperty('icon-animatejnopadieor.scale.y', getProperty('iconP2.scale.y') - 0)
	setProperty('icon-animatejnopadieor.antialiasing',true)

	setProperty('iconP2.alpha', 0) 

        objectPlayAnimation('icon-animatejnopadieor','idle');	

end