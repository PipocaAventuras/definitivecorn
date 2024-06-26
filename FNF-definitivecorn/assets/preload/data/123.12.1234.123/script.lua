local keepScroll = false
function onCreate()
        if getPropertyFromClass('ClientPrefs', 'middleScroll') == true then
            keepScroll = true;
        elseif getPropertyFromClass('ClientPrefs', 'middleScroll') == false then
            setPropertyFromClass('ClientPrefs', 'middleScroll', true);
        end
    end
    
    function onDestroy()
        if keepScroll == false then
            setPropertyFromClass('ClientPrefs', 'middleScroll', false);
        elseif keepScroll == true then
            keepScroll = false;
        end
    end
    