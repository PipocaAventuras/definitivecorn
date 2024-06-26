package;

import flixel.util.FlxColor;
import flixel.util.FlxSave;
using StringTools;

class LanguageManager
{
   public static var currentLocaleList:Array<String>;
   public static var save:FlxSave;

   public static function initSave()
   {
      save = new FlxSave();
      save.bind('language', 'Definitive Corn Team');
   }

   public static function init()
   {
      var languageCode:String = save.data.language != null ? save.data.language : 'en-US';
      currentLocaleList = CoolUtil.coolTextFile(Paths.file('locale/' + languageCode + '/textList.txt', TEXT, 'preload'));
   }

   public static function languageFromPathName(pathName:String):Language
   {
      var languages:Array<Language> = getLanguages();

      for (language in languages)
      {
         if (language.pathName == pathName)
         {
            return language;
         }
      }
      return null;
   }

   public static function getTextString(stringName:String):String
   {
      for (currentValue in currentLocaleList)
      {
         var parts:Array<String> = currentValue.trim().split('==');
         if (parts.length == 2 && parts[0] == stringName)
         {
            var returnedString:String = parts[1];
            returnedString = returnedString.replace(':linebreak:', '\n');
            returnedString = returnedString.replace(':addquote:', '\"');
            return returnedString;
         }
      }
      return stringName;
   }

   public static function getLanguages():Array<Language>
   {
      var languages:Array<Language> = new Array<Language>();
      var languagesText:Array<String> = CoolUtil.coolTextFile(Paths.langaugeFile());

      for (languageInfo in languagesText)
      {
         var splitInfo:Array<String> = languageInfo.split(':');
         if (splitInfo.length >= 3)
         {
            var languageClass:Language = new Language(splitInfo[0], splitInfo[1], FlxColor.fromString(splitInfo[2]));
            languages.push(languageClass);
         }
      }
      return languages;
   }
}