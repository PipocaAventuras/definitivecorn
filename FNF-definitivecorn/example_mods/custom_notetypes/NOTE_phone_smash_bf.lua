function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'NOTE_phone_smash_bf' then 
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_phone');

                        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
			end
		end
	end
end
local shootAnims = {"singSmash", "singSmash", "singSmash", "singSmash"}
function goodNoteHit(id, direction, noteType)
	if noteType == 'NOTE_phone_smash_bf' then
		if difficulty == 2 then
		end
		characterPlayAnim('boyfriend', shootAnims[direction + 1], false);
		setProperty('boyfriend.specialAnim', true);
	end
end