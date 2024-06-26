package;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.tweens.misc.ColorTween;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSave;

class SelectLanguageState extends MusicBeatState
{
   var checkered:FlxBackdrop;
   var selectLanguage:FlxText;
   var textItems:Array<FlxText> = new Array<FlxText>();
   var curLanguageSelected:Int;
   var currentLanguageText:FlxText;
   var langaugeList:Array<Language> = new Array<Language>();
   var accepted:Bool;

   public override function create()
   {
      PlayerSettings.init();

      FlxG.sound.playMusic(Paths.music('breakfast'), 0.7);
      
      FlxG.sound.music.fadeIn(2, 0, 0.7);

      langaugeList = LanguageManager.getLanguages();

      var underbg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/Spike'));
      
      checkered = new FlxBackdrop(Paths.image('checkeredBG'), 1, 1, true, true, 1, 1);
      checkered.antialiasing = true;
      checkered.color = langaugeList[curLanguageSelected].langaugeColor;
      add(checkered);

      var backBg:FlxSprite = new FlxSprite(-80).loadGraphic(MainMenuState.randomizeBG());
		backBg.setGraphicSize(Std.int(backBg.width * 1.175));
		backBg.color = 0xFDE871;
		backBg.updateHitbox();
		backBg.screenCenter();
		backBg.antialiasing = ClientPrefs.globalAntialiasing;
		add(backBg);

      FlxTween.tween(backBg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(checkered, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

      selectLanguage = new FlxText(0, 150, FlxG.width, "Select a Language", 40);
      selectLanguage.setFormat("Comic Sans MS Bold", 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      selectLanguage.antialiasing = true;
      selectLanguage.borderSize = 3;
      selectLanguage.screenCenter(X);
      add(selectLanguage);

      for (i in 0...langaugeList.length)
      {
         var currentLangauge = langaugeList[i];

         var langaugeText:FlxText = new FlxText(0, 350 + (i * 75), FlxG.width, currentLangauge.langaugeName, 40);
         langaugeText.screenCenter(X);
         langaugeText.setFormat("Comic Sans MS Bold", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
         langaugeText.antialiasing = true;
         langaugeText.borderSize = 2;

         var flag:FlxSprite = new FlxSprite().loadGraphic(Paths.image('languages/' + currentLangauge.langaugeName));
         flag.x = langaugeText.x + langaugeText.width + flag.width / 2;

         var yValues = CoolUtil.getMinAndMax(flag.height, langaugeText.height);
         flag.y = langaugeText.y + ((yValues[0] - yValues[1]) / 2);
         add(flag);

         langaugeText.y -= 10;
         langaugeText.x -= 10;
         langaugeText.alpha = 0;

         flag.y -= 10;
         flag.alpha = 0;

         FlxTween.tween(langaugeText, {y: langaugeText.y + 10, alpha: 1}, 0.07, {startDelay: i * 0.1});
         FlxTween.tween(flag, {y: flag.y + 10, alpha: 1}, 0.07, {startDelay: i * 0.1});

         textItems.push(langaugeText);
         add(langaugeText);
      }

      changeSelection();
   }
   public override function update(elapsed:Float)
   {
      var scrollSpeed:Float = 50;
      checkered.x -= scrollSpeed * elapsed;
      checkered.y -= scrollSpeed * elapsed;

      if (!accepted)
      {
			if (controls.ACCEPT)
			{
				accepted = true;

				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);

				LanguageManager.save.data.language = langaugeList[curLanguageSelected].pathName;
            LanguageManager.save.flush();
            LanguageManager.currentLocaleList = CoolUtil.coolTextFile(Paths.file('locale/' + LanguageManager.save.data.language + '/textList.txt', TEXT, 'preload'));

            FlxFlicker.flicker(currentLanguageText, 1.1, 0.07, true, true, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new StartStateSelector());
               FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			      FlxG.sound.music.fadeIn(4, 0, 0.7);
				});
			}
			if (controls.NOTE_UP_P)
			{
				changeSelection(-1);
			}
			if (controls.NOTE_DOWN_P)
			{
				changeSelection(1);
			}
      }
   }
   function changeSelection(amount:Int = 0)
   {
      if (amount != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

      curLanguageSelected += amount;
      if (curLanguageSelected > langaugeList.length - 1)
      {
         curLanguageSelected = 0;
      }
      if (curLanguageSelected < 0)
      {
         curLanguageSelected = langaugeList.length - 1;
      }
      currentLanguageText = textItems[curLanguageSelected];
      for (menuItem in textItems)
      {
         updateText(menuItem, menuItem == textItems[curLanguageSelected]);
      }
      FlxTween.color(checkered, 0.4, checkered.color, langaugeList[curLanguageSelected].langaugeColor);
   }
   function updateText(text:FlxText, selected:Bool)
   {
      if (selected)
      {
         text.setFormat("Comic Sans MS Bold", 25, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      }
      else
      {
         text.setFormat("Comic Sans MS Bold", 25);
      }
   }
}