package;

import flixel.FlxG;
import flixel.FlxState;

class StartStateSelector extends MusicBeatState
{
   public override function create()
   {
      LanguageManager.initSave();
      LanguageManager.save.data.language == null;
      if (LanguageManager.save.data.language == null)
      {
         MusicBeatState.switchState(new SelectLanguageState());
      }
      else
      {
         MusicBeatState.switchState(new TitleState());
      }
   }
}