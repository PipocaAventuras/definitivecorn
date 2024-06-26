function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'NOTE_phone_bf' then 
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_phone');

                        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
			end
		end
	end
end
local shootAnims = {"singLEFT-alt", "singDOWN-alt", "singUP-alt", "singRIGHT-alt"}
function goodNoteHit(id, direction, noteType)
	if noteType == 'NOTE_phone_bf' then
		if difficulty == 2 then
		end
		characterPlayAnim('boyfriend', shootAnims[direction + 1], false);
		setProperty('boyfriend.specialAnim', true);
	end
end