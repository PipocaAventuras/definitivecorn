function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'NOTE_phone_smash' then 
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_phone');

                        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
			end
		end
	end
end
local shootAnims = {"singSmash", "singSmash", "singSmash", "singSmash"}
function opponentNoteHit(id, direction, noteType)
	if noteType == 'NOTE_phone_smash' then
		if difficulty == 2 then
		end
		characterPlayAnim('dad', shootAnims[direction + 1], false);
		setProperty('dad.specialAnim', true);
	end
end