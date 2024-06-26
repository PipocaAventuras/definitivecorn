function onCreate()
	    makeLuaSprite('bars','bars',0,0)
		setLuaSpriteScrollFactor('bars',160,90)
		addLuaSprite('bars',true)
		setObjectCamera('bars','camOther')
		setProperty('bars.antialiasing',false)
        scaleObject('bars',4,4)
end
local squish= 80

function onUpdate( elapsed )
	if not middlescroll then
		noteTweenX('0',0,defaultOpponentStrumX0+squish,0.01,'linear')
		noteTweenX('1',1,defaultOpponentStrumX1+squish,0.01,'linear')
		noteTweenX('2',2,defaultOpponentStrumX2+squish,0.01,'linear')
		noteTweenX('3',3,defaultOpponentStrumX3+squish,0.01,'linear')
		noteTweenX('4',4,defaultPlayerStrumX0-squish,0.01,'linear')
		noteTweenX('5',5,defaultPlayerStrumX1-squish,0.01,'linear')
		noteTweenX('6',6,defaultPlayerStrumX2-squish,0.01,'linear')
		noteTweenX('7',7,defaultPlayerStrumX3-squish,0.01,'linear')
	end
end