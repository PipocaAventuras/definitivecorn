-- script by ItsCapp credit to him

idleoffsets = {'0', '0'}
leftoffsets = {'61', '28'}
downoffsets = {'22', '-37'}
upoffsets = {'117', '68'}
rightoffsets = {'-77', '39'}

idle_xml_name = 'Idle'
left_xml_name = 'Left'
down_xml_name = 'Down'
up_xml_name = 'Up'
right_xml_name = 'Right'

x_position = -130
y_position = 700

xScale = 0.8
yScale = 0.8

invisible = true

name_of_character_xml = 'niles'
name_of_character = 'niles'
name_of_notetype = 'niles'

foreground = true
playablecharacter = false

doIdle = true

function onCreate()
	makeAnimatedLuaSprite(name_of_character, 'characters/' .. name_of_character_xml, x_position, y_position);

	addAnimationByPrefix(name_of_character, 'idle', idle_xml_name, 24, false);
	addAnimationByPrefix(name_of_character, 'singLEFT', left_xml_name, 24, false);
	addAnimationByPrefix(name_of_character, 'singDOWN', down_xml_name, 24, false);
	addAnimationByPrefix(name_of_character, 'singUP', up_xml_name, 24, false);
	addAnimationByPrefix(name_of_character, 'singRIGHT', right_xml_name, 24, false);

	if playablecharacter == true then
		setPropertyLuaSprite(name_of_character, 'flipX', true);
	else
		setPropertyLuaSprite(name_of_character, 'flipX', false);
	end

	scaleObject(name_of_character, xScale, yScale);


	objectPlayAnimation(name_of_character, 'idle');
	addLuaSprite(name_of_character, foreground);

	if invisible == true then
		setPropertyLuaSprite(name_of_character, 'alpha', 0)
	end
end

function onUpdate()
    if getProperty(name_of_character .. '.animation.curAnim.finished') then
        doIdle = true
    end
end

function onEvent(name, value1, value2)
    if name == "CharacterPlayAnimation" then
        doIdle = false
        addAnimationByPrefix(value2, value1, value1, 24, false)
        objectPlayAnimation(value2, value1, true);
    end
end

local singAnims = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}
function opponentNoteHit(id, direction, noteType, isSustainNote)
	if isSustainNote then
		noAnimation(true);
	end
	if noteType == name_of_notetype or noteType == name_of_notetype2 then
		doIdle = false

		objectPlayAnimation(name_of_character, singAnims[direction + 1], true);

		if direction == 0 then
			setProperty(name_of_character .. '.offset.x', leftoffsets[1]);
			setProperty(name_of_character .. '.offset.y', leftoffsets[2]);
		elseif direction == 1 then
			setProperty(name_of_character .. '.offset.x', downoffsets[1]);
			setProperty(name_of_character .. '.offset.y', downoffsets[2]);
		elseif direction == 2 then
			setProperty(name_of_character .. '.offset.x', upoffsets[1]);
			setProperty(name_of_character .. '.offset.y', upoffsets[2]);
		elseif direction == 3 then
			setProperty(name_of_character .. '.offset.x', rightoffsets[1]);
			setProperty(name_of_character .. '.offset.y', rightoffsets[2]);
		end
	end
end

function onBeatHit()
	-- triggered 4 times per section
	if curBeat % 2 == 0  and doIdle then
		objectPlayAnimation(name_of_character, 'idle', false);
		setProperty(name_of_character .. '.offset.x', idleoffsets[1]);
		setProperty(name_of_character .. '.offset.y', idleoffsets[2]);
	end
end