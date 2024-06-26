package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.util.FlxStringUtil;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end
using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/Spike'));

    var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var curChar:String = "unknown";

	private var InMainFreeplayState:Bool = false;

	private var CurrentSongIcon:FlxSprite;

	private var AllPossibleSongs:Array<String> = ["extras", "oc", 'joke', "covers"];

	var songColors:Array<FlxColor> = 
	[
		0xFFFFE584,    // CONFRONTATION
    	0xFF9A6F59,    // POOPED
		0xFFFFEAD7,    // KAWAI
		0xFF1A48D1,    // ASFALTO
		0xFFFFFBEE,    // TECH
		0xFF0F5FFF,    // INSANE CORN
		0xFF66CC00,    // FALSIFY
		0xFF92897E,    // TRAINS
		0xFFE35E14,    // OBLIQUE
		0xFFFFFFFF,    // CAKE
		0xFFFF0032,    // POWER
		0xFFA34F13,    // FUN SPOOKY BATTLE
		0xFFAE9005,    // LIGHTNING
		0xFF666591,    // DEALINGS
		0xFF30BB0F,    // REMINISCENCE
		0xFFEF8C42,    // AGRONOMIST V71961
		0xFF0F5FFF,    // 123.12.1234.123
		0xFFFF74C7,    // LORE
		0xFF303030,    // PHANTASM
		0xFF6A6A6A,    // IN THE TRAP
		0xFF5E0000,    // RAGE
		0xFFFFAACC,    // ICSA3AAHCMAJ
		0xFF2A8030,    // AGRONOMO
		0xFF2F2F30,    // UNTITLED
		0xFFFFC86C,    // VACATION
		0xFFF0E4A4,    // COOKIE DOUGH
		0xFFFFAA66,    // MUSTARD
		0xFFF7403F,    // STYLE
		0xFFFF8002,    // P
		0xFFAA66CD,    // DEEZ NUTS
		0xFFC6790C,    // SUMMER
		0xFF05009C,    // TALKATIVE
		0xFFFF253E,    // NICE AND COOL
		0xFFABCFFF,    // JOLLYTASTIC!
    ];
	public static var skipSelect:Array<String> = 
	[
		'confrontation',
		'asfalto',
		'tech', 
		'insane corn',
		'reminiscence',
		'kawai!1!',
		'agronomist v71961',
		'123.12.1234.123',
		'deez nuts v2',
		'lore',
		'phantasm',
		'in the trap',
		'icsa3aahcmaj',
		'agronomo',
		'untitled'
	];

	private var CurrentPack:Int = 0;

	var loadingPack:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

    var characterSelectText:FlxText;
	public static var showCharText:Bool = true;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Extras Song Menu", null);
		#end

		showCharText = FlxG.save.data.wasInCharSelect;
		
		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		bg.loadGraphic(MainMenuState.randomizeBG());
		bg.color = 0xFDE871;
		add(bg);

		if (FlxG.save.data.probabilityFound || FlxG.save.data.spinFound || FlxG.save.data.agronomoFound || FlxG.save.data.missassholdFound || FlxG.save.data.fancyFound)
		{
			AllPossibleSongs = ['extras', 'oc', 'joke', 'covers', 'secrets'];
		}

		CurrentSongIcon = new FlxSprite(0,0).loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));

		CurrentSongIcon.centerOffsets(false);
		CurrentSongIcon.x = (FlxG.width / 2) - 256;
		CurrentSongIcon.y = (FlxG.height / 2) - 315;
		CurrentSongIcon.setGraphicSize(Std.int(CurrentSongIcon.width * 1.1));
		CurrentSongIcon.screenCenter();
		CurrentSongIcon.antialiasing = true;

		add(CurrentSongIcon);
		super.create();
	}

	public function LoadProperPack()
		{
			switch (AllPossibleSongs[CurrentPack].toLowerCase())
			{
				case 'extras':
				    addWeek(['Confrontation'], 0, ['bunda2d']);
					addWeek(['Pooped'], 1, ['poopina']);
					addWeek(['Asfalto'], 3,['dave-gnomo']);
					addWeek(['Tech'], 4,['tech-robot']);
					addWeek(['Insane Corn'], 5,['dave']);
					addWeek(['Falsify'], 6,['bmabi']);
					addWeek(['Trains'], 7, ['thembo']);
					addWeek(['Cake'], 9, ['baker']);
					addWeek(['Dangerous'], 9, ['niles']);
					addWeek(['Nice and Cool'], 32, ['bamje']);
					addWeek(['Power'], 10, ['tristan']);
					addWeek(['Fun Spooky Battle'], 11, ['pumpkintristan']);
				    addWeek(['Style'], 27, ['gambo']);
				case 'oc':
				    addWeek(['Summer'], 30, ['samny']);
					addWeek(['Cookie Dough'], 25, ['crumbansu']);
					addWeek(['Vacation'], 24, ['eba']);
					addWeek(['Lightning'], 12, ['bambichu']);
					addWeek(['Mustard'], 26, ['pempe']);
					addWeek(['Oblique'], 8, ['blomquo']);
					addWeek(['Reminiscence'], 14, ['vanderley']);
					addWeek(['Dealings'], 13, ['adopteddrugdealer']);
				case 'joke':
				    addWeek(['p'], 28, ['pizzagod']);
			    	addWeek(['Kawai!1!'], 2,['dave-kun']);
					addWeek(['Jollytastic!'], 33, ['samnyxmas']);
					addWeek(['Agronomist V71961'], 15,['danevy']);
					addWeek(['MISS ASS HOLD'], 9, ['missasshold']);
					addWeek(['123.12.1234.123'], 16, ['ip_dave']);
					addWeek(['Deez Nuts v2'], 29, ['robinson']);
				case 'covers':
					addWeek(['Lore'], 17,['jonlore']);
					addWeek(['Phantasm'], 18,['gentlemen']);
					addWeek(['In the Trap'], 19,['plambitrap']);
				case 'secrets':
				if (FlxG.save.data.probabilityFound)
					addWeek(['Rage'], 20, ['ragebambi']);
				if (FlxG.save.data.spinFound)
					addWeek(['icsa3aahcmaj'], 21, ['dave_plays']);
				if (FlxG.save.data.agronomoFound)
					addWeek(['Agronomo'], 22, ['martielo']);
				if (FlxG.save.data.missassholdFound)
					addWeek(['Talkative'], 31, ['discordkun']);
				if (FlxG.save.data.fancyFound)
					addWeek(['Untitled'], 23, ['carafino']);
			}
		}


	public function GoToActualFreeplay()
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItemCenter = true;
			songText.isMenuItem = false;
			songText.itemType = "Classic";
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x -10, scoreText.y + 30, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.x = 20;
		diffText.y = 40;
		add(diffText);

		if (showCharText)
		{
			characterSelectText = new FlxText(FlxG.width, FlxG.height, 0, LanguageManager.getTextString("freeplay_skipChar"), 18);
			characterSelectText.setFormat("Comic Sans MS Bold", 18, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			characterSelectText.borderSize = 1.5;
			characterSelectText.antialiasing = true;
			characterSelectText.scrollFactor.set();
			characterSelectText.alpha = 0;
			characterSelectText.x -= characterSelectText.textField.textWidth;
			characterSelectText.y -= characterSelectText.textField.textHeight;
			add(characterSelectText);

			FlxTween.tween(characterSelectText,{alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
		}

		add(scoreText);

		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function UpdatePackSelection(change:Int)
	{
		CurrentPack += change;
		if (CurrentPack == -1)
		{
			CurrentPack = AllPossibleSongs.length - 1;
		}
		if (CurrentPack == AllPossibleSongs.length)
		{
			CurrentPack = 0;
		}
		CurrentSongIcon.loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));
	}

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
        characterSelectText = null;

		if (!InMainFreeplayState) 
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				UpdatePackSelection(-1);
			}
			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				UpdatePackSelection(1);
			}
			if (controls.ACCEPT && !loadingPack)
			{
				loadingPack = true;
				LoadProperPack();
				FlxTween.tween(CurrentSongIcon, {alpha: 0}, 0.3);
				new FlxTimer().start(0.5, function(Dumbshit:FlxTimer)
				{
					CurrentSongIcon.visible = false;
					GoToActualFreeplay();
					InMainFreeplayState = true;
					loadingPack = false;
				});
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}	
		
			return;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;
		
		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		scoreText.text = LanguageManager.getTextString('freeplay_personalBest') + ' ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var fuckyou = FlxG.keys.justPressed.SEVEN;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplayState());
	
			if (accepted)
			{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			
				trace(poop);
			
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
			
				PlayState.storyWeek = songs[curSelected].week;
			    if ((FlxG.keys.pressed.CONTROL || skipSelect.contains(PlayState.SONG.song.toLowerCase())))
				{
					LoadingState.loadAndSwitchState(new PlayState());
				}
				else
				{
    				if (!FlxG.save.data.wasInCharSelect)
					{
						FlxG.save.data.wasInCharSelect = true;
						FlxG.save.flush();
					}
					LoadingState.loadAndSwitchState(new CharacterSelectState());
				}
			}
		}
		if (fuckyou)
		{
			FlxG.sound.music.volume = 0;
			
			new FlxTimer().start(0.25, function(tmr:FlxTimer)
			{
			LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
				FreeplayState.destroyFreeplayVocals();
			});
		}
	#if PRELOAD_ALL
	if(space && instPlaying != curSelected)
	{
		destroyFreeplayVocals();
		Paths.currentModDirectory = songs[curSelected].folder;
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		if (PlayState.SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
		vocals.play();
		vocals.persist = true;
		vocals.looped = true;
		vocals.volume = 0.7;
		instPlaying = curSelected;
	}
	else #end if (accepted)
	{
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
		#if MODS_ALLOWED
		if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
		#else
		if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
		#end
			poop = songLowercase;
			curDifficulty = 1;
			trace('Couldnt find file');
		}
		trace(poop);

		PlayState.characteroverride = "none";
		PlayState.formoverride = "none";
		PlayState.curmult = [1, 1, 1, 1];

		PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;

		PlayState.storyWeek = songs[curSelected].week;
		trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		if ((FlxG.keys.pressed.CONTROL || skipSelect.contains(PlayState.SONG.song.toLowerCase())))
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
		else
		{
			if (!FlxG.save.data.wasInCharSelect)
			{
				FlxG.save.data.wasInCharSelect = true;
				FlxG.save.flush();
			}
			LoadingState.loadAndSwitchState(new CharacterSelectState());
		}

		FlxG.sound.music.volume = 0;
				
		destroyFreeplayVocals();
	}
	else if(controls.RESET)
	{
		openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	super.update(elapsed);
}

public static function destroyFreeplayVocals() {
	if(vocals != null) {
		vocals.stop();
		vocals.destroy();
	}
	vocals = null;
}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 1)
			curDifficulty = 0;
		if (curDifficulty > 1)
			curDifficulty = 0;
		
		if (songs[curSelected].week == 4)
			{
				curDifficulty = 1;
			}
		if (songs[curSelected].week == 6 || songs[curSelected].week == 7 || songs[curSelected].week == 8 || songs[curSelected].week == 9 || songs[curSelected].week == 10 || songs[curSelected].week == 11)
			{
				curDifficulty = 1;
			}
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].week == 4)
		{
			curDifficulty = 1;
		}
		if (songs[curSelected].week == 6 || songs[curSelected].week == 7 || songs[curSelected].week == 8 || songs[curSelected].week == 9 || songs[curSelected].week == 10 || songs[curSelected].week == 11)
		{
			curDifficulty = 1;
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		FlxTween.color(bg, 0.25, bg.color, songColors[songs[curSelected].week]);
		changeDiff();
	}
    private function positionHighscore() {
			scoreText.x = FlxG.width - scoreText.width - 6;
	
			scoreBG.scale.x = FlxG.width - scoreText.x + 6;
			scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}