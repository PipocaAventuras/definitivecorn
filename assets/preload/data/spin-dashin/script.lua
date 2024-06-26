function onCreate()
	    makeLuaSprite('bars','bars',0,0)
		setLuaSpriteScrollFactor('bars',160,90)
		addLuaSprite('bars',true)
		setObjectCamera('bars','camOther')
		setProperty('bars.antialiasing',false)
        scaleObject('bars',4,4)

		makeLuaSprite('blackFuck', 'black', 0, 0);
	    scaleObject('blackFuck', 6.0, 6.0);
	    setObjectCamera('blackFuck', 'other');
	    addLuaSprite('blackFuck', true);
        
        makeLuaSprite('startCircle', 'CircleSpinDashin', 777, 0);
        setObjectCamera('startCircle', 'other');
        addLuaSprite('startCircle', true);
    
        makeLuaSprite('startText', 'TextSpinDashin', -1200, 0);
        setObjectCamera('startText', 'other');
        addLuaSprite('startText', true);
end
    
function onStartCountdown()
	runTimer('textmove', 0.6)
	runTimer('textfade', 1.9)
end

function onTimerCompleted(tag)
    if tag == 'textmove' then
		doTweenX('circleTween', 'startCircle', 0, 0.5, 'linear');
		doTweenX('textTween', 'startText', 0, 0.5, 'linear');
	end
	
    if tag == 'textfade' then
		doTweenAlpha('graphicAlpha', 'blackFuck', 0, 1, 'linear');
		doTweenAlpha('circleAlpha', 'startCircle', 0, 1, 'linear');
		doTweenAlpha('textAlpha', 'startText', 0, 1, 'linear');
	end
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