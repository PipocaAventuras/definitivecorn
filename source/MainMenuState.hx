package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import Achievements;
import editors.CharacterEditorState;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curModVer:String = '1.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var checkered:FlxBackdrop;
	
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'extras', 'ost', 'credits', 'options'];

	var bigIcons:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	public static var firstStart:Bool = true;
	
	public static var daRealEngineVer:String = 'Corn';

	public static var engineVers:Array<String> = ['Corn'];

	public static var bgPaths:Array<String> = 
	[
		'backgrounds/Spike',
		'backgrounds/GB',
		'backgrounds/Spike2',
		'backgrounds/PragaInfernal',
        'backgrounds/YesOrYes',
		'backgrounds/JoojadorRuim',
		'backgrounds/IceCube',
		'backgrounds/IceCube2',
		'backgrounds/cheesevtaz',
		'backgrounds/Weodobo',
		'backgrounds/Slopgear',
		'backgrounds/JoojadorRuim2',
		'backgrounds/OctoStar',
		'backgrounds/OctoStar2',
		'backgrounds/Slopgear2',
		'backgrounds/YesOrYes2',
		'backgrounds/cheesevtaz2',
		'backgrounds/MiojoPiadas',
		'backgrounds/GB2',
		'backgrounds/HF185',
		'backgrounds/YesOrYes3',
		'backgrounds/IceCube3',
		'backgrounds/Luan',
		'backgrounds/cheesevtaz3',
		'backgrounds/HF1852',
		'backgrounds/MP4',
		'backgrounds/LuffyFan',
		'backgrounds/Ben',
		'backgrounds/Perk'
	];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		checkered = new FlxBackdrop(Paths.image('checkeredBG', 'preload'), 1, 1, true, true, 1, 1);
		checkered.antialiasing = true;
		checkered.scrollFactor.set();
		add(checkered);

		var yScroll:Float = Math.max(0.1 - (0.03 * (optionShit.length - 4)), 0.1);
		var backBg:FlxSprite = new FlxSprite(-80).loadGraphic(randomizeBG());
		backBg.scrollFactor.set(0, yScroll);
		backBg.setGraphicSize(Std.int(backBg.width * 1.175));
		backBg.color = 0xFDE871;
		backBg.updateHitbox();
		backBg.screenCenter();
		backBg.antialiasing = ClientPrefs.globalAntialiasing;
		add(backBg);

		FlxTween.tween(backBg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(checkered, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var menuSide:FlxSprite = new FlxSprite(0, -1).loadGraphic(Paths.image('menuSide'));
		menuSide.scrollFactor.x = 0;
		menuSide.scrollFactor.y = 0.18;
		menuSide.antialiasing = true;
		menuSide.scrollFactor.set();
		menuSide.updateHitbox();
        menuSide.screenCenter(X);
		add(menuSide);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

        bigIcons = new FlxSprite(650, 150);
		bigIcons.frames = Paths.getSparrowAtlas('main_menu_icons');
		for (i in 0...optionShit.length)
		{
			bigIcons.animation.addByPrefix(optionShit[i], optionShit[i] == 'extras' ? 'extras0' : optionShit[i], 24);
		}
		bigIcons.scrollFactor.set(0, 0);
		bigIcons.antialiasing = true;
		bigIcons.updateHitbox();
		bigIcons.animation.play(optionShit[0]);
		add(bigIcons);

		var scale:Float = 1;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 0.06);
		
		camFollow.setPosition(640, 150.5);
		for (i in 0...optionShit.length)
			{
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * -30;
				var menuItem:FlxSprite = new FlxSprite(0, (i * 80)  + offset);
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " basic", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItem.x += -350;
				menuItems.add(menuItem);
				menuItem.scale.set(0.8, 0.8);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
	
		firstStart = false;

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, curModVer + ' ' + daRealEngineVer + " Engine", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Comic Sans MS Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		var scrollSpeed:Float = 50;
		checkered.x -= scrollSpeed * elapsed;
		checkered.y -= scrollSpeed * elapsed;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
				{
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
	
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 1.3, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								if(ClientPrefs.flashing)
								{
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
									{
										goToState();
									});
								}
								else
								{
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										goToState();
									});
								}
							}
						});
					}
				}
			}
			#if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
			  selectedSomethin = true;
			  LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
			}
			#end
	
			super.update(elapsed);
	
			menuItems.forEach(function(spr:FlxSprite)
			{
				//spr.screenCenter(X);
			});
		}
	function goToState()
		{
			var daChoice:String = optionShit[curSelected];
	
			switch (daChoice)
			{
				case 'story_mode':
					MusicBeatState.switchState(new PlayMenuState());
				case 'extras':
					MusicBeatState.switchState(new FreeplayState());
				case 'ost':
					MusicBeatState.switchState(new MusicPlayerState());
				case 'credits':
					MusicBeatState.switchState(new CreditsState());
				case 'options':
					MusicBeatState.switchState(new OptionsState());
			}
		}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
				bigIcons.animation.play(optionShit[curSelected]);
			}
		});
	}
	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		return Paths.image(bgPaths[chance]);
	}
}