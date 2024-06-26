package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var bg:FlxBackdrop;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Toggle Practice Mode', 'Change Character', 'Options', 'Exit to menu'];
	var menuitemsStory:Array<String> = ['Resume', 'Restart Song', 'Toggle Practice Mode', 'Options', 'Exit to menu'];
	var menuCryAbouIt:Array<String> = ['Resume', 'Restart Song', 'Change Character', 'Options', 'Exit to menu'];
	var menucryaboutitStory:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;

	public static var transCamera:FlxCamera;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemsOG;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'maize' | 'electronic' | 'motocycle' | 'fancy' | 'pipebomb' | 'fnaf is real' | 'carnivore' | 'spin dashin' | 'agronomist' | 'subversive':
			    menuItems = menuitemsStory;
			case 'probability':
	        	menuItems = menucryaboutitStory;
			case 'rage':
	        	menuItems = menuCryAbouIt;
		}

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var backBg:FlxSprite = new FlxSprite();
		backBg.makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.BLACK);
		backBg.alpha = 0;
		backBg.scrollFactor.set();
		add(backBg);

		bg = new FlxBackdrop(Paths.image('checkeredBG', 'shared'), 1, 1, true, true, 1, 1);
		bg.alpha = 0;
		bg.antialiasing = true;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("comic.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		blueballedTxt.text = LanguageManager.getTextString('pause_blueballed') + " " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('comic.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, LanguageManager.getTextString('pause_practice'), 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('comic-sans.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('comic.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		switch (Paths.formatToSongPath(PlayState.SONG.song))
        {
			case 'motocycle' | 'fancy' | 'pipebomb' | 'summer' | 'agronomist' | 'subversive' | 'spin-dashin' | 'asfalto' | 'falsify' | 'eighteen' | 'agronomist-v71961' | 'icsa3aahcmaj' | 'cookie-dough' | 'jollytastic!':
				levelInfo.text = PlayState.SONG.song + " - " + "poopypants839";
			case 'probability' | 'electronic' | 'carnivore' | 'pooped' | 'kawai!1!' | 'tech' | 'trains' | 'lightning' | 'dealings' | 'style' | 'mustard' | 'nice-and-cool':
                levelInfo.text = PlayState.SONG.song + " - " + "geby";
			case 'maize' | 'confrontation' | 'insane-corn' | 'reminiscence' | 'dangerous':
			    levelInfo.text = PlayState.SONG.song + " - " + "Luan";
			case 'power' | 'fun-spooky-battle' | 'vacation':
			    levelInfo.text = PlayState.SONG.song + " - " + "Espla";
			case 'oblique' | 'rage' | 'miss-ass-hold' | 'talkative' | 'fnaf-is-real' | 'deez-nuts-v2':
			    levelInfo.text = PlayState.SONG.song + " - " + "JooJ Dumwell";
            case '123.12.1234.123':
				levelInfo.text = PlayState.SONG.song + " - " + "Ben";
			case 'cake':
				levelInfo.text = PlayState.SONG.song + " - " + "D-Plushies";
			case 'lore':
				levelInfo.text = PlayState.SONG.song + " - " + "Kiwiquest (ft. poopypants839)";
			case 'phantasm':
				levelInfo.text = PlayState.SONG.song + " - " + "Biddle3 (ft. poopypants839)";
			case 'in-the-trap':
				levelInfo.text = PlayState.SONG.song + " - " + "Valerange (ft. poopypants839)";
			case 'agronomo':
				levelInfo.text = PlayState.SONG.song + " - " + "poopypants839 (ft. Praga Infernal + Noname)";
			case 'p':
			    levelInfo.text = PlayState.SONG.song + " - " + "geby + Webby + poopypants839";
            case 'untitled':
			    levelInfo.text = PlayState.SONG.song + " - " + "geby + Espla + Luan + Ben + JooJ Dumwell + poopypants839";
			default:
				levelInfo.text = PlayState.SONG.song;
        }

		blueballedTxt.alpha = 0;
		levelInfo.alpha = 0;

        blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		levelInfo.x = FlxG.width - (levelInfo.width + 20);

        FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(backBg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		if (FreeplayState.skipSelect.contains(PlayState.SONG.song.toLowerCase()))
		{
			menuItems = menuitemsStory;
		}

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, LanguageManager.getTextString('pause_' + menuItems[i]), true, false);
			songText.isMenuItemCenter = true;
			songText.isMenuItem = false;
			songText.itemType = "Classic";
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		var scrollSpeed:Float = 50;
		bg.x -= scrollSpeed * elapsed;
		bg.y -= scrollSpeed * elapsed;
		
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			for (i in 0...difficultyChoices.length-1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.cpuControlled = false;
					return;
				}
			}
			
			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Toggle Practice Mode':
					PlayState.practiceMode = !PlayState.practiceMode;
					PlayState.usedPractice = true;
					practiceText.visible = PlayState.practiceMode;
				case "Restart Song":
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
				case 'Botplay':
					PlayState.cpuControlled = !PlayState.cpuControlled;
					PlayState.usedPractice = true;
					botplayText.visible = PlayState.cpuControlled;
				case "Change Character":
					PlayState.characteroverride = 'none';
					PlayState.formoverride = 'none';
					MusicBeatState.switchState(new CharacterSelectState());	
				case 'Options':
					MusicBeatState.switchState(new OptionsState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					OptionsState.onPlayState = true;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.switchState(new MainMenuState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.usedPractice = false;
					PlayState.changedDifficulty = false;
					PlayState.cpuControlled = false;
				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.itemType = "Classic";
			item.isMenuItem = false;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}