elapsedtime = 0;
function onUpdate(elapsed)
    elapsedtime=elapsedtime+0.05;
    setProperty('dad.x', -800-math.sin(elapsedtime/2)*100);
    setProperty('dad.y', -200-math.sin(elapsedtime)*50);
    songPos = getSongPosition()
    local currentBeat = (songPos/1250)*(curBpm/100)
    noteTweenY('defaultOpponentStrumY0', 0, defaultPlayerStrumY0 - 50*math.sin((currentBeat+0*0.25)*math.pi), 0.5)
    noteTweenY('defaultOpponentStrumY1', 1, defaultPlayerStrumY1 - 50*math.sin((currentBeat+1*0.25)*math.pi), 0.5)
    noteTweenY('defaultOpponentStrumY2', 2, defaultPlayerStrumY2 - 50*math.sin((currentBeat+2*0.25)*math.pi), 0.5)
    noteTweenY('defaultOpponentStrumY3', 3, defaultPlayerStrumY3 - 50*math.sin((currentBeat+3*0.25)*math.pi), 0.5)
    noteTweenY('defaultPlayerStrumY0', 4, defaultPlayerStrumY0 - 50*math.sin((currentBeat+4*0.25)*math.pi), 0.5)
    noteTweenY('defaultPlayerStrumY1', 5, defaultPlayerStrumY1 - 50*math.sin((currentBeat+5*0.25)*math.pi), 0.5)
    noteTweenY('defaultPlayerStrumY2', 6, defaultPlayerStrumY2 - 50*math.sin((currentBeat+6*0.25)*math.pi), 0.5)
    noteTweenY('defaultPlayerStrumY3', 7, defaultPlayerStrumY3 - 50*math.sin((currentBeat+7*0.25)*math.pi), 0.5)
end
function opponentNoteHit()
    health = getProperty('health')
    if getProperty('health') > 0.1 then
        setProperty('health', health- 0.02);
    end
end