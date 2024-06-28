package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import Shaders.PulseEffect;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.misc.ColorTween;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import StageData;
import FunkinLua;
import DialogueBoxPsych;

#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var resultaccuracy:Float = 0;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var subtitleManager:SubtitleManager;
	public var creditsPopup:CreditsPopUp;
	public static var curStage:String = '';
	public static var characteroverride:String = "none";
	public static var formoverride:String = "none";
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 0;

	public var vocals:FlxSound;

	var isDadGlobal:Bool = true;

	var funnyFloatyBoys:Array<String> = ['probability-bambi', 'playable-probabilitybambi', 'rage-bambi', 'bunda', 'bunda-player', 'miles', 'miles-player', 'poopina', 'poopina-player', 'frog-w-dave', 'frogdave-player', 'thembo', 'thembo-player', '3dtristangf', 'dave3d', 'dave3d-player', 'bambi3d', 'player-probability-bambi', 'bunda-2d', '2dbunda-player', 'blomquo-talkative', 'talkblomquo-player', 'carafino', 'carafino-player', 'rock-untitled', 'cararock-player', 'rock-player'];
    var funnyRageFloaty:Array<String> = ['rage-bambi', 'ragebambi-player'];

	var canSlide:Bool = true;

	public var elapsedtime:Float = 0;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;

	public static var screenshader:Shaders.PulseEffect = new PulseEffect();

	public static var curmult:Array<Float> = [1, 1, 1, 1];

	public var curbg:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;
	var nightColor:FlxColor = 0xFF878787;
    public var sunsetColor:FlxColor = FlxColor.fromRGB(255, 143, 178);
	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public static var eyesoreson = true;

	private var healthBarBG:AttachedSprite;
	public var healthBarOverlay:FlxSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var shakeCam:Bool = false;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

    var flatgrass:FlxSprite = new FlxSprite(350, 75).loadGraphic(Paths.image('gm_flatgrass'));
    var hills:FlxSprite = new FlxSprite(-173, 100).loadGraphic(Paths.image('orangey hills'));
    var farm:FlxSprite = new FlxSprite(100, 125).loadGraphic(Paths.image('funfarmhouse'));
    var foreground:FlxSprite = new FlxSprite(-600, 500).loadGraphic(Paths.image('grass lands'));
    var cornFence:FlxSprite = new FlxSprite(-400, 200).loadGraphic(Paths.image('cornFence'));
    var cornFence2:FlxSprite = new FlxSprite(1100, 200).loadGraphic(Paths.image('cornFence2'));
    var cornBag:FlxSprite = new FlxSprite(1200, 550).loadGraphic(Paths.image('cornbag'));
    var sign:FlxSprite = new FlxSprite(0, 350).loadGraphic(Paths.image('sign'));
    public var bg2:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('probability_bg'));
	public var bgp2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('p_bg2'));
	public var davey:FlxSprite = new FlxSprite().loadGraphic(Paths.image('subversive/mainHallway'));
	public var YCTP:FlxSprite = new FlxSprite().loadGraphic(Paths.image('subversive/YCTP'));
	public var BGhallwayChase:FlxSprite;
	public var hallwayChase:FlxSprite;
	public var imseeingthelocker:FlxSprite = new FlxSprite().loadGraphic(Paths.image('subversive/imseeingthelocker'));
	public var detention:FlxSprite = new FlxSprite(-350, -20).loadGraphic(Paths.image('subversive/detention'));
	public var silverManHallway:FlxSprite = new FlxSprite(380, -30).loadGraphic(Paths.image('subversive/silverManHallway'));
	public var silva:FlxSprite = new FlxSprite(-450, 0).loadGraphic(Paths.image('subversive/silva'));
	public var nodesk:FlxSprite = new FlxSprite(850, 0).loadGraphic(Paths.image('subversive/nodesk'));
	public var desk:FlxSprite = new FlxSprite(1000, 100).loadGraphic(Paths.image('subversive/desk'));
	public var cinema:FlxSprite = new FlxSprite(-500, -500).loadGraphic(Paths.image('subversive/cinema'));
	public var bgg2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('funspookybattle_bg2'));
	public var bg1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('funspookybattle_bg1'));
	public var black:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('the'));
	public var fino:FlxSprite = new FlxSprite(-661, -754).loadGraphic(Paths.image('nomeindefinido/fino_bg'));
	public var sproya:FlxSprite = new FlxSprite(500, -350).loadGraphic(Paths.image('nomeindefinido/sproya_background'));
	public var maize:FlxSprite = new FlxSprite(500, -400).loadGraphic(Paths.image('nomeindefinido/scrappedteam_bg'));
	public var sky:FlxSprite = new FlxSprite(-600, -300).loadGraphic(Paths.image('sky_night'));
	public var sunset:FlxSprite = new FlxSprite(-600, -300).loadGraphic(Paths.image('sky_sunset'));
	public var fancy:FlxSprite = new FlxSprite(500, -400).loadGraphic(Paths.image('nomeindefinido/fancy_bg'));
	public var bmabi:FlxSprite = new FlxSprite(500, -700).loadGraphic(Paths.image('nomeindefinido/bmabi_bg'));
	public var comercial:FlxSprite = new FlxSprite(500, -400).loadGraphic(Paths.image('nomeindefinido/marcellofight'));
	public var flipaclip:FlxSprite = new FlxSprite(500, -400).loadGraphic(Paths.image('nomeindefinido/flipaclip_bg'));
	public var paroxeie:FlxSprite = new FlxSprite(950, -350).loadGraphic(Paths.image('nomeindefinido/fnafiscool'));
	public var white:FlxSprite = new FlxSprite(300, -700).loadGraphic(Paths.image('white'));
	public var discord:FlxSprite = new FlxSprite(700, -400).loadGraphic(Paths.image('nomeindefinido/fnafiscool'));
	public var sansino:FlxSprite = new FlxSprite(500, -700).loadGraphic(Paths.image('nomeindefinido/sansinoBg'));
	public var solanabota:FlxSprite = new FlxSprite(700, 100).loadGraphic(Paths.image('nomeindefinido/manbi_bg'));
	public var EEEVILhallwayChase:FlxSprite;
	public var EvilhallwayChase:FlxSprite;
	public var exesky:FlxSprite = new FlxSprite(-1000, -250).loadGraphic(Paths.image('exe_sky'));
	public var evil:FlxSprite = new FlxSprite(0, 350).loadGraphic(Paths.image('spindashin_bg2'));
	public var fleet:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fleet'));
	public var fet:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('asfalto_feet'));
	public var bgcar:FlxSprite = new FlxSprite(-800, -320).loadGraphic(Paths.image('motocycle_bg_car'));
	public var redsky:FlxSprite = new FlxSprite(-900, -200).loadGraphic(Paths.image('redsky'));
	public var scary:FlxSprite = new FlxSprite(-500, -400).loadGraphic(Paths.image('insaneyt'));
	public var bgr:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('reminiscence_bg'));
	public var bgr2:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('reminiscence_bg2'));
	public var future:FlxSprite = new FlxSprite(-300, 0).loadGraphic(Paths.image('subvercial_bg'));
	public var bob:FlxSprite = new FlxSprite(-700, -200).loadGraphic(Paths.image('agronomistv71961_bg2'));
	public var gb:BGSprite;
	public var perk:BGSprite;
	public var webby:BGSprite;
	public var staticscr:BGSprite;
	public var car1:BGSprite;
	public var car2:BGSprite;
	public var alice:BGSprite;
	public var awa:BGSprite;
	public var plambiradical:BGSprite;
	public var mataramoplambi:BGSprite;
	public var xmas:BGSprite;

	var emojiTeleporter:FlxSprite;
	var fancyFrame:FlxSprite;
	var heyTimer:Float;

	var foregroundSprites:FlxTypedGroup<BGSprite>;
	var foregroundSpritesAlt:FlxTypedGroup<FlxSprite>;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	var songLength:Float = 0;

	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var camFollowX:Int = 0;
    var camFollowY:Int = 0;
    var dadCamFollowX:Int = 0;
	var dadCamFollowY:Int = 0;

	private var luaArray:Array<FunkinLua> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	var canFloat:Bool = true;

	var creditsWatermark:FlxText;

	var bfNoteCamOffset:Array<Float> = new Array<Float>();
	var dadNoteCamOffset:Array<Float> = new Array<Float>();

	override public function create()
	{
        eyesoreson = ClientPrefs.flashing;

		instance = this;

		#if MODS_ALLOWED
		Paths.destroyLoadedImages(resetSpriteCache);
		#end
		resetSpriteCache = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		foregroundSpritesAlt = new FlxTypedGroup<FlxSprite>();

		#if desktop
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		{
			detailsText = "Playing:";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
	
		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'p': //P
				var bg:BGSprite = new BGSprite('p_bg1', 0, 0, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 1.15), Std.int(bg.height * 1.15));
				add(bg);

				bgp2.loadGraphic(Paths.image('p_bg2'));
				bgp2.active = true;
				bgp2.visible = false;
				bgp2.setGraphicSize(Std.int(bgp2.width * 1.15), Std.int(bgp2.height * 1.15));
				add(bgp2);

			case 'electronic': //Electronic
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('electronic_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;

				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;

			case 'deeznutsv2': //Deez Nuts v2
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('deeznutsv2_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;
				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;

				staticscr = new BGSprite('peppino_jumpscare',  -600, -50, 0.9, 0.9, ['jumpscare']);
				staticscr.setGraphicSize(Std.int(staticscr.width * 1.3));
				staticscr.scrollFactor.set();
				staticscr.screenCenter();
				staticscr.active = false;
				staticscr.visible = false;
				foregroundSprites.add(staticscr);

			case 'confrontation': //Confrontation
				var bg:FlxSprite = new FlxSprite(1430, -200).loadGraphic(Paths.image('probability_bg'));
				bg.active = true;
				add(bg);

				var bg2:FlxSprite = new FlxSprite(-1130, -200).loadGraphic(Paths.image('electronic_bg'));
				bg.active = true;
				add(bg2);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg2.shader = testshader.shader;
				curbg = bg2;
				bg.shader = testshader.shader;
				curbg = bg;

			case 'houseNight': //Insane Corn
                var bg:BGSprite = new BGSprite('sky_night', -600, -300, 0.6, 0.6);
                add(bg);

                var hills:BGSprite = new BGSprite('hills', -834, -159, 0.7, 0.7);
                hills.updateHitbox();
                add(hills);

                var gate:BGSprite = new BGSprite('gate', -755, 250);
                gate.updateHitbox();
                add(gate);

                var grass:BGSprite = new BGSprite('grass', -832, 505);
                grass.updateHitbox();
                add(grass);

                hills.color = 0xFF878787;
                gate.color = 0xFF878787;
                grass.color = 0xFF878787;
                scary.color = 0xFF878787;

                scary.loadGraphic(Paths.image('insaneyt'));
                scary.antialiasing = true;
                scary.scrollFactor.set(0.6, 0.6);
                scary.active = true;
                scary.visible = false;
                add(scary);

                var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
                testshader.waveAmplitude = 0.1;
                testshader.waveFrequency = 5;
                testshader.waveSpeed = 2;
                scary.shader = testshader.shader;
                curbg = scary;
			
			case 'lore': //Lore
				var bg:BGSprite = new BGSprite('lore_bg', -300, 100, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				add(bg);
			
			case 'reminiscence': //Reminiscence
				bgr.loadGraphic(Paths.image('reminiscence_bg'));
				bgr.setGraphicSize(Std.int(bgr.width * 1.5));
				bgr.scrollFactor.set(0.9, 0.9);
				bgr.active = true;
				bgr.visible = true;
				add(bgr);

				bgr2.loadGraphic(Paths.image('reminiscence_bg2'));
				bgr2.setGraphicSize(Std.int(bgr2.width * 1.5));
				bgr2.scrollFactor.set(0.9, 0.9);
				bgr2.active = true;
				bgr2.visible = false;
				add(bgr2);
		    
			case 'cookie-dough': //Cookie Dough
			    var bg2:BGSprite = new BGSprite('sky_night', -600, -300, 0.2, 0.2);
                add(bg2);

				var bg:BGSprite = new BGSprite('cookie-dough-bg1', -800, -190);
				bg.setGraphicSize(Std.int(bg.width * 2.1));
				add(bg);

				bg.color = 0xFF878787;
			
			case 'vacation': //Vacation
			    var bg2:BGSprite = new BGSprite('vacation_sun', -900, -200, 0.9, 0.9);
				bg2.active = true;
				add(bg2);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg2.shader = testshader.shader;
				curbg = bg2;

				var bg:BGSprite = new BGSprite('vacation_bg', -300, 300);
				bg.setGraphicSize(Std.int(bg.width * 3.5));
				add(bg);

			case 'mustard': //Mustard
			    var bg:BGSprite = new BGSprite('mustard_bg', -600, -300, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.7));
                add(bg);
			
			case 'niceandcool': //Nice and Cool
			    var bg:BGSprite = new BGSprite('niceandcool_bg', -600, -300, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.7));
                add(bg);
			
			case 'lightning': //Lightning
				var bg:BGSprite = new BGSprite('lightning_bg', -280, -190, 0.9, 0.9);
				add(bg);

			case 'cake': //Cake
			    var bg:BGSprite = new BGSprite('cake_bg', -650, 600, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				bg.updateHitbox();
				add(bg);
			
			case 'pipebomb'://Pipebomb
			    var wavy:BGSprite = new BGSprite('wavypipebomb_bg', -600, -200, 0.9, 0.9);
				wavy.active = true;
				add(wavy);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				wavy.shader = testshader.shader;
				curbg = wavy;

			    var bg:BGSprite = new BGSprite('pipebomb_bg', -600, -200, 0.9, 0.9);
				add(bg);

				black.loadGraphic(Paths.image('the'));
				black.setGraphicSize(Std.int(black.width * 9999));
				black.visible = false;
				add(black);
			
			case 'style': //Style
			    var bg:BGSprite = new BGSprite('style_bg', -600, -300, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.7));
                add(bg);
			
			case 'spindashin': //Spin Dashin

			    var sky:BGSprite = new BGSprite('sd_sky', -1000, -250, 0.9, 0.9);
				sky.antialiasing = false;
				sky.setGraphicSize(Std.int(sky.width * 0.8));
				add(sky);

				var bg:BGSprite = new BGSprite('spindashin_bg', 0, 350, 0.9, 0.9);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 5));
				add(bg);

				exesky.loadGraphic(Paths.image('exe_sky'));
				exesky.antialiasing = false;
				exesky.scrollFactor.set(0.9, 0.9);
				exesky.setGraphicSize(Std.int(exesky.width * 0.8));
				exesky.active = true;
				exesky.visible = false;
				add(exesky);

				evil.loadGraphic(Paths.image('spindashin_bg2'));
				evil.antialiasing = false;
				evil.setGraphicSize(Std.int(evil.width * 5));
				evil.scrollFactor.set(0.9, 0.9);
				evil.active = true;
				evil.visible = false;
				add(evil);

				black.loadGraphic(Paths.image('the'));
				black.setGraphicSize(Std.int(black.width * 9999));
				black.visible = false;
				foregroundSpritesAlt.add(black);
			
			case 'dave_plays': //ICSA3AAHGMAJ
				var bg:BGSprite = new BGSprite('dave_plays_bg', -600, -200, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.5));
				add(bg);

			case 'dealings': //Dealings
			    var sky:BGSprite = new BGSprite('sky', -60, -370, 0.9, 0.9);
				sky.setGraphicSize(Std.int(sky.width * 0.7));
				sky.updateHitbox();
				add(sky);

				var city:BGSprite = new BGSprite('dealings/city', 30, 130, 0.9, 0.9);
				add(city);

				var window:BGSprite = new BGSprite('dealings/window thing or what', 270, 280, 0.9, 0.9);
				add(window);

				var wall:BGSprite = new BGSprite('dealings/wall', -140, -100, 0.9, 0.9);
				add(wall);

				var floor:BGSprite = new BGSprite('dealings/floor', -120, 500, 0.9, 0.9);
				floor.setGraphicSize(Std.int(floor.width * 1.1));
				floor.updateHitbox();
				add(floor);
			
			case 'fleet': //Phantasm
				var bg:BGSprite = new BGSprite('sonic', 0, 0, 0.9, 0.9);
				add(bg);

				fleet.loadGraphic(Paths.image('fleet'));
				fleet.antialiasing = true;
				fleet.scrollFactor.set(0.9, 0.9);
				fleet.active = true;
				fleet.visible = false;
				add(fleet);
			
			case 'tech': //Tech
                var bg:BGSprite = new BGSprite('tech_bg', -600, -200, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				add(bg);
			
			case 'kawai': //Kawai!1!
				var bg:BGSprite = new BGSprite('kawai_bg', -600, -200, 0.9, 0.9);
				add(bg);

				alice = new BGSprite('characters/Speaker_assets', 1900, 900, 0.9, 0.9, ['GF Dancing Beat']);
                add(alice);

                if (FlxG.random.int(1, 100) == 1)
                {
                    alice = new BGSprite('alice', 1900, 900, 0.9, 0.9, ['alice']);
                    alice.setGraphicSize(Std.int(alice.width *  1.25));
                    add(alice);
                }
			
			case 'inthetrap': //In The Trap
				var bg:BGSprite = new BGSprite('inthetrap_bg', -600, -200, 0.9, 0.9);
				add(bg);
 
                var box:BGSprite = new BGSprite('literallyabox', -600, -200, 0.9, 0.9);
				foregroundSprites.add(box);
			
			case 'asfalto': //Asfalto
                var bg:BGSprite = new BGSprite('asfalto_bg', -600, -200, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.9));
                add(bg);

                fet.loadGraphic(Paths.image('asfalto_feet'));
				fet.setGraphicSize(Std.int(fet.width * 0.9));
                fet.antialiasing = true;
                fet.scrollFactor.set(0.9, 0.9);
                fet.active = true;
                fet.visible = false;
                add(fet);

			case 'oblique': //Oblique
				var bg_1:BGSprite = new BGSprite('oblique_bg', -600, -200, 0.9, 0.9);
				bg_1.active = true;
				bg_1.visible = true;
				add(bg_1);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg_1.shader = testshader.shader;
				curbg = bg_1;

			    var bg:BGSprite = new BGSprite('oblique_bg2', -600, -200, 0.9, 0.9);
				add(bg);

			case 'inside-house':
				var bg:BGSprite = new BGSprite('inside_house', -1000, -350, 0.9, 0.9);
				add(bg);
			
			case 'pooped': //Pooped
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('pooped_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;
				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
			
			case 'probability': //Probability
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('probability_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;
				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.2;
				testshader.waveFrequency = 3.5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
			
			case 'subversive': //Subversive
				davey.loadGraphic(Paths.image('subversive/mainHallway'));
				davey.setGraphicSize(Std.int(davey.width * 2.55), Std.int(davey.height * 2.55));
				davey.active = true;
				davey.visible = true;
				add(davey);

				YCTP.loadGraphic(Paths.image('subversive/YCTP'));
				YCTP.setGraphicSize(Std.int(YCTP.width * 2.55), Std.int(YCTP.height * 2.55));
				YCTP.active = true;
				YCTP.visible = false;
				add(YCTP);

				var BGhallwayChase = Paths.getSparrowAtlas('subversive/hallwayChase');

				hallwayChase = new FlxSprite(0, 50);
				hallwayChase.frames = BGhallwayChase;
				hallwayChase.animation.addByPrefix('idle', 'chase');
				hallwayChase.setGraphicSize(Std.int(hallwayChase.width * 2.85), Std.int(hallwayChase.height * 2.85));
				hallwayChase.animation.play('idle');
				hallwayChase.antialiasing = true;
				hallwayChase.active = false;
				hallwayChase.visible = false;
				add(hallwayChase);

				imseeingthelocker.loadGraphic(Paths.image('subversive/imseeingthelocker'));
				imseeingthelocker.setGraphicSize(Std.int(imseeingthelocker.width * 2.55), Std.int(imseeingthelocker.height * 2.55));
				imseeingthelocker.active = true;
				imseeingthelocker.visible = false;
				add(imseeingthelocker);

				detention.loadGraphic(Paths.image('subversive/detention'));
				detention.setGraphicSize(Std.int(detention.width * 3.25), Std.int(detention.height * 3.25));
				detention.active = true;
				detention.visible = false;
				add(detention);

				silverManHallway.loadGraphic(Paths.image('subversive/silverManHallway'));
				silverManHallway.setGraphicSize(Std.int(silverManHallway.width * 2.35), Std.int(silverManHallway.height * 2.25));
				silverManHallway.active = true;
				silverManHallway.visible = false;
				add(silverManHallway);

				silva.loadGraphic(Paths.image('subversive/silva'));
				silva.setGraphicSize(Std.int(silva.width * 2.55), Std.int(silva.height * 2.55));
				silva.active = true;
				silva.visible = false;
				add(silva);
				
				nodesk.loadGraphic(Paths.image('subversive/nodesk'));
				nodesk.setGraphicSize(Std.int(nodesk.width * 2.95), Std.int(nodesk.height * 2.95));
				nodesk.scrollFactor.set(0.9, 0.9);
				nodesk.active = true;
				nodesk.visible = false;
				add(nodesk);

				desk.loadGraphic(Paths.image('subversive/desk'));
				desk.setGraphicSize(Std.int(desk.width * 2.95), Std.int(desk.height * 2.95));
				desk.active = true;
				desk.visible = false;
				foregroundSpritesAlt.add(desk);
			    
				cinema.loadGraphic(Paths.image('subversive/cinema'));
				cinema.setGraphicSize(Std.int(cinema.width * 1.2), Std.int(cinema.height * 1.2));
				cinema.active = true;
				cinema.visible = false;
				add(cinema);

				staticscr = new BGSprite('subversive/victory',  -600, -50, 0.9, 0.9);
				staticscr.setGraphicSize(Std.int(staticscr.width * 2));
				staticscr.scrollFactor.set();
				staticscr.screenCenter();
				staticscr.active = true;
				staticscr.visible = false;
				foregroundSprites.add(staticscr);

			case 'rage': //Rage
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('rage_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;
				bg.setGraphicSize(Std.int(bg.width * 1.8));
				add(bg);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.3;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 5;
				bg.shader = testshader.shader;
				curbg = bg;

				var bg2:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('rage_bg2'));
				bg2.antialiasing = true;
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.active = true;
				add(bg2);
		    
			case 'trains': //Trains
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('trains_bg'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = true;
				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;

			case 'farmDay': //Maize
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('sky'));
				add(bg);

				sunset.loadGraphic(Paths.image('sky_sunset'));
				sunset.active = true;
				sunset.visible = false;
				add(sunset);

				sky.loadGraphic(Paths.image('sky_night'));
				sky.active = true;
				sky.visible = false;
				add(sky);

				flatgrass.loadGraphic(Paths.image('gm_flatgrass'));
                flatgrass.setGraphicSize(Std.int(flatgrass.width * 0.34));
                add(flatgrass);

                hills.loadGraphic(Paths.image('orangey hills'));
                add(hills);

                farm.loadGraphic(Paths.image('funfarmhouse'));
                farm.setGraphicSize(Std.int(farm.width * 0.9));
                add(farm);

                foreground.loadGraphic(Paths.image('grass lands'));
                add(foreground);

                cornFence.loadGraphic(Paths.image('cornFence'));
                add(cornFence);

                cornFence2.loadGraphic(Paths.image('cornFence2'));
                add(cornFence2);

                cornBag.loadGraphic(Paths.image('cornbag'));
                add(cornBag);

                sign.loadGraphic(Paths.image('sign'));
                add(sign);

				bg2.loadGraphic(Paths.image('probability_bg'));
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.active = true;
				bg2.visible = false;
				add(bg2);

				add(bg);

				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.2;
				testshader.waveFrequency = 3.5;
				testshader.waveSpeed = 2;
				bg2.shader = testshader.shader;
				curbg = bg2;

			case 'agronomist': //Agronomist
				var bg:BGSprite = new BGSprite('agronomist_bg', -600, -200, 0.9, 0.9);
				add(bg);
				
				future.loadGraphic(Paths.image('subvercial_bg'));
				future.setGraphicSize(Std.int(future.width * 1.15));
				future.scrollFactor.set(0.9, 0.9);
				future.active = true;
				future.visible = false;
				add(future);
			
			case 'nome_indefinido': //Untitled
				fino.loadGraphic(Paths.image('nomeindefinido/fino_bg'));
				fino.setGraphicSize(Std.int(fino.width * 3.2));
				fino.scrollFactor.set(0.9, 0.9);
				fino.updateHitbox();
				fino.active = true;
				fino.visible = true;
				add(fino);

				sproya.loadGraphic(Paths.image('nomeindefinido/sproya_background'));
				sproya.setGraphicSize(Std.int(sproya.width * 1.2));
				sproya.scrollFactor.set(0.9, 0.9);
				sproya.active = true;
				sproya.visible = false;
				add(sproya);

				sky.loadGraphic(Paths.image('sky_night'));
				sky.scrollFactor.set(0.2, 0.2);
				sky.active = true;
				sky.visible = false;
				add(sky);

				maize.loadGraphic(Paths.image('nomeindefinido/scrappedteam_bg'));
				maize.setGraphicSize(Std.int(maize.width * 1.1), Std.int(maize.height * 1.1));
				maize.active = true;
				maize.visible = false;
				add(maize);

			    perk = new BGSprite('nomeindefinido/scrappedteambg/perk', 1200, -20, 0.9, 0.9, ['perk']);
			    perk.visible = false;
			    add(perk);

				webby = new BGSprite('nomeindefinido/scrappedteambg/webby', 1420, 50, 0.9, 0.9, ['webby']);
				webby.flipX = true;
				webby.visible = false;
				add(webby);

			    gb = new BGSprite('nomeindefinido/scrappedteambg/gb', 1120, 30, 0.9, 0.9, ['gb']);
				gb.setGraphicSize(Std.int(gb.width * 0.8), Std.int(gb.height * 0.8));
				gb.visible = false;
				add(gb);

				gb.color = 0xFF878787;
				perk.color = 0xFF878787;
                webby.color = 0xFF878787;
                maize.color = 0xFF878787;

				fancy.loadGraphic(Paths.image('nomeindefinido/fancy_bg'));
				fancy.active = true;
				fancy.visible = false;
				add(fancy);

				bmabi.loadGraphic(Paths.image('nomeindefinido/bmabi_bg'));
				bmabi.active = true;
				bmabi.visible = false;
				add(bmabi);

				comercial.loadGraphic(Paths.image('nomeindefinido/marcellofight'));
				comercial.setGraphicSize(Std.int(comercial.width * 1.35), Std.int(comercial.height * 1.35));
				comercial.active = true;
				comercial.visible = false;
				add(comercial);

				flipaclip.loadGraphic(Paths.image('nomeindefinido/flipaclip_bg'));
				flipaclip.setGraphicSize(Std.int(flipaclip.width * 1.5), Std.int(flipaclip.height * 1.5));
				flipaclip.active = true;
				flipaclip.visible = false;
				add(flipaclip);
				
				paroxeie.loadGraphic(Paths.image('nomeindefinido/fnafiscool'));
				paroxeie.setGraphicSize(Std.int(paroxeie.width * 3));
				paroxeie.active = true;
				paroxeie.visible = false;
				add(paroxeie);

				white.loadGraphic(Paths.image('white'));
				white.setGraphicSize(Std.int(white.width * 10), Std.int(white.height * 10));
				white.active = true;
				white.visible = false;
				add(white);

				discord.loadGraphic(Paths.image('nomeindefinido/discord'));
				discord.setGraphicSize(Std.int(discord.width * 1.5));
				discord.active = true;
				discord.visible = false;
				add(discord);

				sansino.loadGraphic(Paths.image('nomeindefinido/sansinoBg'));
				sansino.setGraphicSize(Std.int(sansino.width * 3));
				sansino.active = true;
				sansino.visible = false;
				add(sansino);

				solanabota.loadGraphic(Paths.image('nomeindefinido/manbi_bg'));
				solanabota.setGraphicSize(Std.int(solanabota.width * 4));
				solanabota.active = true;
				solanabota.visible = false;
				add(solanabota);

				var EEEVILhallwayChase = Paths.getSparrowAtlas('nomeindefinido/EvilhallwayChase');
				EvilhallwayChase = new FlxSprite(600, -150);
				EvilhallwayChase.frames = EEEVILhallwayChase;
				EvilhallwayChase.animation.addByPrefix('idle', 'chase');
				EvilhallwayChase.setGraphicSize(Std.int(EvilhallwayChase.width * 2.85), Std.int(EvilhallwayChase.height * 2.85));
				EvilhallwayChase.animation.play('idle');
				EvilhallwayChase.antialiasing = true;
				EvilhallwayChase.active = false;
				EvilhallwayChase.visible = false;
				add(EvilhallwayChase);

				car1 = new BGSprite('nomeindefinido/car',  700, 400, 0.9, 0.9);
				car1.setGraphicSize(Std.int(car1.width * 2));
				car1.active = true;
				car1.visible = false;
				foregroundSprites.add(car1);

				car2 = new BGSprite('nomeindefinido/car',  1700, 400, 0.9, 0.9);
				car2.setGraphicSize(Std.int(car2.width * 2));
				car2.active = true;
				car2.visible = false;
				foregroundSprites.add(car2);

				staticscr = new BGSprite('nomeindefinido/staticScreen',  -600, -50, 0.9, 0.9, ['idle']);
				staticscr.setGraphicSize(Std.int(staticscr.width * 1.5));
				staticscr.scrollFactor.set();
				staticscr.screenCenter();
				staticscr.active = true;
				staticscr.visible = false;
				foregroundSprites.add(staticscr);
			
			case 'funspookybattle': //Fun Spooky Battle
			    var sky:BGSprite = new BGSprite('sky_night', 100, 100, 0.9, 0.9);
				sky.setGraphicSize(Std.int(sky.width * 0.7));
				sky.updateHitbox();
				add(sky);

				bg1.loadGraphic(Paths.image('funspookybattle_bg1'));
				bg1.setGraphicSize(Std.int(bg1.width * 0.4));
				bg1.scrollFactor.set(0.9, 0.9);
				bg1.active = true;
				bg1.visible = true;
				add(bg1);

				bgg2.loadGraphic(Paths.image('funspookybattle_bg2'));
				bgg2.setGraphicSize(Std.int(bgg2.width * 0.4));
				bgg2.scrollFactor.set(0.9, 0.9);
				bgg2.active = true;
				bgg2.visible = false;
				add(bgg2);

			case 'black': //123.12.1234.123
				var bg:BGSprite = new BGSprite('the', -600, -200, 0.9, 0.9);
				add(bg);

				redsky.loadGraphic(Paths.image('redsky'));
				redsky.setGraphicSize(Std.int(redsky.width * 0.8));
				redsky.antialiasing = true;
				redsky.scrollFactor.set(0.9, 0.9);
				redsky.active = true;
				redsky.visible = false;
				add(redsky);
			
			case 'discord': //MISS ASS HOLD				
				var color:BGSprite = new BGSprite('ass/bgocolor', 0, 0);
				color.setGraphicSize(Std.int(color.width * 1000)); //lmao
				add(color);

			    var bg:BGSprite = new BGSprite('ass/bg', -160, -150);
				bg.setGraphicSize(Std.int(bg.width * 1.9));
				add(bg);

				if(!ClientPrefs.cursing)
				{
					var bg:BGSprite = new BGSprite('ass/bg-censored', -160, -150);
					bg.setGraphicSize(Std.int(bg.width * 1.9));
					add(bg);
				}

				var chat:BGSprite = new BGSprite('ass/chat', -210, 630);
				chat.setGraphicSize(Std.int(chat.width * 2));
				add(chat);

				var emoji:BGSprite = new BGSprite('ass/emoji', 1640, 606);
				emoji.setGraphicSize(Std.int(emoji.width * 2));
				add(emoji);

				FlxG.mouse.visible = true;

				FlxMouseEventManager.add(emoji, function onMouseDown(emojiTeleporter:FlxSprite)
				{
					PlayState.SONG = Song.loadFromJson("talkative", "talkative");
				 	FlxG.save.data.missassholdFound = true;
					shakeCam = false;
					MusicBeatState.switchState(new PlayState());
					return;
				}, null, null, null);
			
			case 'talkative': //TALKATIVE
			    var bg:BGSprite = new BGSprite('ass/bgocolor', 0, 0);
				bg.setGraphicSize(Std.int(bg.width * 1000)); //lmao
				add(bg);

			    var emojichat:BGSprite = new BGSprite('ass/emojichat', -160, 460);
				emojichat.setGraphicSize(Std.int(emojichat.width * 1.5));
				add(emojichat);

			    var emoji:BGSprite = new BGSprite('ass/emoji-patch', 900, -240);
				add(emoji);

			case 'agronomistv71961': //Agronomist V71961
				var bg:BGSprite = new BGSprite('agronomistv71961_bg', -600, -200, 0.9, 0.9);
				add(bg);

				bob.loadGraphic(Paths.image('agronomistv71961_bg2'));
				bob.scrollFactor.set(0.9, 0.9);
				bob.active = true;
				bob.visible = false;
				add(bob);
			
			case 'agronomo': //Agronomo
				var bg:BGSprite = new BGSprite('agronomo_bg', -600, -200, 0.9, 0.9);
				add(bg);
			
			case 'jollytastic': //Jollytastic!
				var bg:BGSprite = new BGSprite('jollytastic_bg', -600, -200, 0.9, 0.9);
				bg.active = true;
				bg.visible = true;
				add(bg);

				xmas = new BGSprite('merry_christmas', -600, -200, 0.9, 0.9);
				xmas.setGraphicSize(Std.int(xmas.width * 0.8), Std.int(xmas.height * 0.8));
				xmas.scrollFactor.set();
				xmas.screenCenter();
				foregroundSprites.add(xmas);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;

				bg.color = 0xFFFF8FB2;
			
			case 'falsify':
				var bg:FlxSprite = new FlxSprite(-700, 0).loadGraphic(Paths.image('falsify_bg'));
				add(bg);
			
			case 'fnafisreal': //Fnaf is Real
				var bg:BGSprite = new BGSprite('fnafisreal_bg', -300, 100, 0.9, 0.9);
				add(bg);

			case 'carnivore': //Carnivore
				var bg:BGSprite = new BGSprite('carnivore_bg', -100, 100, 0.9, 0.9);
				bg.setGraphicSize(Std.int(bg.width * 0.7), Std.int(bg.height * 0.7));
				add(bg);

			case 'summer': //Summer
				var summer:BGSprite = new BGSprite('summer_bg', -600, -200, 0.9, 0.9);
				summer.active = true;
				summer.visible = true;
				add(summer);

				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				summer.shader = testshader.shader;
				curbg = summer;

				awa = new BGSprite('awa', 300, 200, 0.9, 0.9, ['anim']);
				awa.setGraphicSize(Std.int(awa.width * 1.8), Std.int(awa.height * 1.8));
				add(awa);

			    var bg:BGSprite = new BGSprite('summer_beach', -600, -200, 0.9, 0.9);
				add(bg);
			
			case 'motocycle': //Motocycle
				var bg:BGSprite = new BGSprite('motocycle_bg', -600, -200, 0.9, 0.9);
				add(bg);

				plambiradical = new BGSprite('characters/plambi_wtf', -200, 150, 0.9, 0.9, ['oh']);
				plambiradical.setGraphicSize(Std.int(plambiradical.width * 1.2));
				plambiradical.active = true;
				plambiradical.visible = false;
				add(plambiradical);

				mataramoplambi = new BGSprite('characters/plambi_wtf', -850, 50, 0.9, 0.9, ['shoot']);
				mataramoplambi.setGraphicSize(Std.int(mataramoplambi.width * 2.6));
				mataramoplambi.active = false;
				mataramoplambi.visible = false;
				add(mataramoplambi);

				plambiradical.color = 0xFF878787;
				mataramoplambi.color = 0xFF878787;

				bgcar.loadGraphic(Paths.image('motocycle_bg_car'));
				bgcar.setGraphicSize(Std.int(bgcar.width * 1.35), Std.int(bgcar.height * 1.35));
				bgcar.antialiasing = true;
				bgcar.scrollFactor.set(0.9, 0.9);
				bgcar.active = true;
				bgcar.visible = false;
				foregroundSpritesAlt.add(bgcar);
			
			case 'fancy': //Fancy
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fancy_bg'));
				bg.setGraphicSize(Std.int(bg.width * 1.35), Std.int(bg.height * 1.35));
				add(bg);

				var frame:FlxSprite = new FlxSprite().loadGraphic(Paths.image('little_secret'));
				frame.setGraphicSize(Std.int(frame.width * 1.35), Std.int(frame.height * 1.35));
				add(frame);

				FlxG.mouse.visible = true;

				FlxMouseEventManager.add(frame, function onMouseDown(fancyFrame:FlxSprite)
				{
					PlayState.SONG = Song.loadFromJson("untitled", "untitled");
					FlxG.save.data.fancyFound = true;
					shakeCam = false;
					MusicBeatState.switchState(new PlayState());
					return;
				}, null, null, null);
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		screenshader.waveAmplitude = 0.5;
		screenshader.waveFrequency = 1;
		screenshader.waveSpeed = 1;
		screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		if(formoverride == "bf-christmas")
		{
			gfVersion = 'gf-christmas';
		}

		if (!['none', 'bf'].contains(formoverride))
	    {
			switch (curSong)
			{
				case 'nice and cool':
				    gfVersion = 'tommy';
				default:
					gfVersion = 'speaker';
			}
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		if (formoverride == "none" || formoverride == "bf" || formoverride == SONG.player1)
		{
			boyfriend = new Boyfriend(0, 0, SONG.player1);
		}
		else
		{
			boyfriend = new Boyfriend(0, 0, formoverride);
		}
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		add(foregroundSprites);

		add(foregroundSpritesAlt);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}

		if(!ClientPrefs.cursing)
		{
			switch (SONG.song.toLowerCase())
			{
                case 'maize' | 'probability' | 'motocycle' | 'fnaf is real' | 'pipebomb':
				    var file:String = Paths.txt(songName + '/' + songName + 'Dialogue' + '-censored'); //Censorship
					if (OpenFlAssets.exists(file)) {
						dialogue = CoolUtil.coolTextFile(file);
					}
			}
		}


		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);	

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		healthBarOverlay = new FlxSprite().loadGraphic(Paths.image('healthBarOverlay'));
		healthBarOverlay.y = FlxG.height * 0.89;
		healthBarOverlay.screenCenter(X);
		healthBarOverlay.scrollFactor.set();
		healthBarOverlay.visible = !ClientPrefs.hideHud;
        healthBarOverlay.color = FlxColor.BLACK;
		healthBarOverlay.blend = MULTIPLY;
		healthBarOverlay.x = healthBarBG.x-1.9;
	    healthBarOverlay.alpha = ClientPrefs.healthBarAlpha;
		healthBarOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(healthBarOverlay); healthBarOverlay.alpha = ClientPrefs.healthBarAlpha; if(ClientPrefs.downScroll) healthBarOverlay.y = 0.11 * FlxG.height;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		var credits:String;
		switch (SONG.song.toLowerCase())
		{
			case 'agronomist v71961':
			    credits = LanguageManager.getTextString('agrov71961_credit');
			case 'p':
				credits = LanguageManager.getTextString('p_credit');
			case 'summer':
				credits = LanguageManager.getTextString('summer_credit');
			case 'dealings':
				credits = LanguageManager.getTextString('dealings_credit');
			case 'lightning':
				credits = LanguageManager.getTextString('lightning_credit');
			case 'mustard':
				credits = LanguageManager.getTextString('mustard_credit');
			case 'reminiscence':
				credits = LanguageManager.getTextString('reminiscence_credit');
			case 'cookie dough':
				credits = LanguageManager.getTextString('cookiedough_credit');
			case 'vacation':
				credits = LanguageManager.getTextString('vacation_credit');
			case 'oblique':
				credits = LanguageManager.getTextString('oblique_credit');
			default:
				credits = '';
		}
		var creditsText:Bool = credits != '';
		var textYPos:Float = healthBarBG.y + 50;
		if (creditsText)
		{
			textYPos = healthBarBG.y + 30;
		}

		var songWatermark = new FlxText(4, textYPos, 0,
		SONG.song
		+ " "
		+ " ", 16);
		songWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songWatermark.scrollFactor.set();
		add(songWatermark);

		creditsWatermark = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
		creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditsWatermark.scrollFactor.set();
		add(creditsWatermark);
		creditsWatermark.cameras = [camHUD];

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
  
		botplayTxt = new FlxText(400, timeTxt.y + (timeTxt.height / 4) + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeTxt.y + (timeTxt.height / 4) - 78;
		}

		switch (SONG.song.toLowerCase())
		{
			case 'spin dashin':
				scoreTxt.setFormat(Paths.font("sonic.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				botplayTxt.setFormat(Paths.font("sonic.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				songWatermark.setFormat(Paths.font("sonic.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				timeTxt.setFormat(Paths.font("sonic.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'tech':
				scoreTxt.setFormat(Paths.font("PixelOperator-Bold.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				botplayTxt.setFormat(Paths.font("PixelOperator-Bold.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				songWatermark.setFormat(Paths.font("PixelOperator-Bold.ttf"), 23, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				timeTxt.setFormat(Paths.font("PixelOperator-Bold.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		healthBarOverlay.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		songWatermark.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);

		if (!seenCutscene || FlxG.save.data.freeplayCuts)
		{
			switch (daSong)
			{		 
				case 'maize' | 'probability' | 'electronic' | 'motocycle' | 'fancy' | 'pipebomb' | 'carnivore' | 'fnaf-is-real' | 'subversive':
					schoolIntro(doof);
				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		RecalculateRating();

		subtitleManager = new SubtitleManager();
		subtitleManager.cameras = [camHUD];
		add(subtitleManager);

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		#end
		super.create();
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		camFollowPos.setPosition(boyfriend.getGraphicMidpoint().x - 200, dad.getGraphicMidpoint().y - 10);
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = endSong;
			} else {
				doof.finishThing = startCountdown;
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox, isStart:Bool = true):Void
	{
		inCutscene = true;
		camFollowPos.setPosition(boyfriend.getGraphicMidpoint().x - 200, dad.getGraphicMidpoint().y - 10);
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var stupidBasics:Float = 1;
		if (isStart)
		{
			FlxTween.tween(black, {alpha: 0}, stupidBasics);
		}
		else
		{
			black.alpha = 0;
			stupidBasics = 0;
		}
		new FlxTimer().start(stupidBasics, function(fuckingSussy:FlxTimer)
		{
			if (dialogueBox != null)
			{
				add(dialogueBox);
			}
			else
			{
				startCountdown();
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				var introSoundAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var soundAssetsAlt:Array<String> = new Array<String>();

				introSoundAssets.set('default', ['default/intro3', 'default/intro2', 'default/intro1', 'default/introGo']);
				introSoundAssets.set('pixel', ['pixel/intro3-pixel', 'pixel/intro2-pixel', 'pixel/intro1-pixel', 'pixel/introGo-pixel']);
				introSoundAssets.set('tech', ['tech/intro3_tech', 'tech/intro2_tech', 'tech/intro1_tech', 'tech/introGo_tech']);
				introSoundAssets.set('dave', ['dave/intro3_dave', 'dave/intro2_dave', 'dave/intro1_dave', 'dave/introGo_dave']);
				introSoundAssets.set('bambi', ['bambi/intro3_bambi', 'bambi/intro2_bambi', 'bambi/intro1_bambi', 'bambi/introGo_bambi']);
				introSoundAssets.set('gentleman', ['gentleman/intro3_gentleman', 'gentleman/intro2_gentleman', 'gentleman/intro1_gentleman', 'gentleman/introGo_gentleman']);
				introSoundAssets.set('joke', ['joke/intro3_joke', 'joke/intro2_joke', 'joke/intro1_joke', 'joke/introGo_joke']);

				switch (SONG.song.toLowerCase())
				{
					case 'agronomist' | 'subversive' | 'asfalto' | 'insane corn' | 'kawai!1!' | 'agronomist v71961' | '123.12.1234.123' | 'icsa3aahcmaj' | 'talkative':
						soundAssetsAlt = introSoundAssets.get('dave');
					case 'maize' | 'probability' | 'electronic' | 'motocycle' | 'pipebomb' | 'fnaf is real' | 'carnivore' | 'confrontation' | 'pooped' | 'falsify' | 'trains' | 'cake' | 'nice and cool' | 'style' | 'summer' | 'jollytastic!' | 'cookie dough' | 'vacation' | 'lightning' | 'mustard' | 'oblique' | 'reminiscence' | 'p' | 'lore' | 'in the trap' | 'rage' | 'agronomo':
						soundAssetsAlt = introSoundAssets.get('bambi');
                    case 'fancy' | 'phantasm' | 'untitled':
					    soundAssetsAlt = introSoundAssets.get('gentleman');
					case 'spin dashin':
					    soundAssetsAlt = introSoundAssets.get('pixel');
					case 'tech':
					    soundAssetsAlt = introSoundAssets.get('tech');
					case 'miss ass hold' | 'deez nuts v2':
					    soundAssetsAlt = introSoundAssets.get('joke');
					default:
						soundAssetsAlt = introSoundAssets.get('default');
				}

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[0]), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();
						ready.camera = camOther;

						if (PlayState.isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						add(ready);
						countDownSprites.push(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(ready);
								remove(ready);
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[1]), 0.6);
					    if(ClientPrefs.followarrow)	isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (PlayState.isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

                        set.camera = camOther;
						set.screenCenter();
						set.antialiasing = antialias;
						add(set);
						countDownSprites.push(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(set);
								remove(set);
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[2]), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (PlayState.isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
						go.updateHitbox();
						go.camera = camOther;
						go.screenCenter();
						go.antialiasing = antialias;
						add(go);
						countDownSprites.push(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(go);
								remove(go);
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[3]), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);

						if (boyfriend.animOffsets.exists('hey'))
							{
								boyfriend.playAnim('hey');
							}
						if (gf.animOffsets.exists('cheer'))
							{
								gf.playAnim('cheer', true);
							}
						if (curSong.toLowerCase() == 'talkative')
			                {
				                dad.playAnim('hey', true);
			                }
					case 4:
						creditsPopup = new CreditsPopUp(FlxG.width, 200);
						creditsPopup.camera = camOther;
						creditsPopup.scrollFactor.set();
						creditsPopup.x = creditsPopup.width * -1;
						add(creditsPopup);
	
						FlxTween.tween(creditsPopup, {x: 0}, 0.5, {ease: FlxEase.backOut, onComplete: function(tweeen:FlxTween)
						{
							FlxTween.tween(creditsPopup, {x: creditsPopup.width * -1} , 1, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
							{
								creditsPopup.destroy();
							}, startDelay: 3});
						}});
					}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
			
		if(!ClientPrefs.cursing)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
                case 'probability' | 'rage' | 'falsify' | 'p' | 'subversive' | 'talkative':
				    vocals = new FlxSound().loadEmbedded(Paths.voicesCensored(PlayState.SONG.song));
			}
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note;
					if(PlayState.SONG.isSkinSep) {
						if (gottaHitNote){
							swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, true);
						} else {
							 swagNote = new Note(daStrumTime, daNoteData, oldNote);
						}
					} else {
						swagNote = new Note(daStrumTime, daNoteData, oldNote);
					}

					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
					swagNote.noteType = songNotes[3];
					if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note;
							if(PlayState.SONG.isSkinSep) {
								 //checks if its a player note, if it is, then it turns it into a note that DOESNT use the custom style
								if (gottaHitNote){
									sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true, false, true);
								} else {
									sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
								}
							} else { 
								sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							}
							sustainNote.mustPress = gottaHitNote;
							sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}

					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				} else { //Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[3].toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[2])) {
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		elapsedtime += elapsed;
		if (curbg != null)
		{
			if (curbg.active) // only the furiosity background is active
			{
				var shad = cast(curbg.shader, Shaders.GlitchShader);
				shad.uTime.value[0] += elapsed;
			}
		}
		if(funnyFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canFloat)
		{
			dad.y += (Math.sin(elapsedtime) * 0.2);
		}
		if(funnyRageFloaty.contains(dad.curCharacter.toLowerCase()) && canSlide)
			{
				dad.x += (Math.sin(elapsedtime) * 1.4);
			}
		if(funnyFloatyBoys.contains(boyfriend.curCharacter.toLowerCase()) && canFloat)
		{
			boyfriend.y += (Math.sin(elapsedtime) * 0.2);
		}
		if(funnyFloatyBoys.contains(gf.curCharacter.toLowerCase()) && canFloat)
		{
			gf.y += (Math.sin(elapsedtime) * 0.2);
		}

		FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]); // this is very stupid but doesn't effect memory all that much so
		if (shakeCam && eyesoreson)
		{
			// var shad = cast(FlxG.camera.screen.shader,Shaders.PulseShader);
			FlxG.camera.shake(0.010, 0.010);
		}

		screenshader.shader.uTime.value[0] += elapsed;
		if (shakeCam && eyesoreson)
		{
			screenshader.shader.uampmul.value[0] = 1;
		}
		else
		{
			screenshader.shader.uampmul.value[0] -= (elapsed / 2);
		}
		screenshader.Enabled = shakeCam && eyesoreson;

    /*
	if (FlxG.keys.justPressed.NINE)
	{
		iconP1.swapOldIcon();
	}
	*/
	switch (SONG.song.toLowerCase())
	{
		case 'confrontation':
			switch (curStep)
			{
				case 120 | 376 | 632 | 760 | 1144 | 1400 | 1536:
					defaultCamZoom = 0.85;
				case 128 | 640 | 768 | 1152 | 1664:
					defaultCamZoom = 0.75;
				case 384 | 1408:
					defaultCamZoom = 0.95;
			}
		case 'pooped':
			switch (curStep)
			{
				case 384 | 864 | 1136 | 1408:
					defaultCamZoom = 0.85;
				case 640 | 896 | 1280:
					defaultCamZoom = 0.75;
				case 870:
					defaultCamZoom = 0.95;
				case 876:
					defaultCamZoom = 1;
				case 1152:
					defaultCamZoom = 0.9;
			}
		case 'rage':
		    switch (curStep)
		    {
				case 128:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub1-censored'), 0.02, 1, {subtitleSize: 60});
					}
					else
					{
				        subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub1'), 0.02, 1, {subtitleSize: 60});
					}
					makeInvisibleNotes(true);
				case 160:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub2'), 0.02, 1, {subtitleSize: 60});
				case 192:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub3-censored'), 0.02, 1, {subtitleSize: 60});
					}
					else
					{
				        subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub3'), 0.02, 1, {subtitleSize: 60});
					}
				case 222:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('rage_sub4'), 0.02, 1, {subtitleSize: 60});
					makeInvisibleNotes(false);
				case 256 | 512 | 640 | 768 | 896 | 1536:
					FlxG.camera.flash(FlxColor.WHITE);
				case 384 | 1280 | 1664:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.4;
				case 464:
					defaultCamZoom = 0.4;
				case 1024 | 1408:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
				case 1104 | 1248:
					defaultCamZoom = 0.7;
				case 1120:
					defaultCamZoom = 0.6;
				case 1152:
					defaultCamZoom = 0.7;
					FlxG.camera.flash(FlxColor.WHITE);
				case 1232:
					defaultCamZoom = 0.8;
				case 1337:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub1'), 0.02, 1, {subtitleSize: 60});
					shakeCam = true;
				case 1344:
				    shakeCam = false;
			}
		case 'deez nuts v2':
		    switch (curStep)
		    {
				case 32 | 160 | 224 | 288 | 352 | 480 | 544 | 608 | 736 | 800 | 864 | 992 | 1056 | 1120 | 1248 | 1312 | 1376 | 1504 | 1568 | 1632 | 1696 | 1760 | 2656 | 2720 | 2784 | 2896 | 3840 | 4608 | 4688 | 4816 | 5840 | 5904:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 416 | 2816 | 3280 | 4352 | 5584:
				    defaultCamZoom = 0.8;
				case 672 | 1888 | 3088 | 5072:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
				case 928 | 1440 | 2400 | 2832 | 3472 | 3664 | 4480 | 5328:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
				case 1184 | 1824 | 3600:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.8;
				case 5980:
				    staticscr.visible = true;
					staticscr.active = true;
			}
		case 'miss ass hold':
			switch (curStep)
			{
				case 192 | 832:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 256 | 320 | 384 | 448 | 576 | 640 | 704 | 768 | 896 | 960 | 1024 | 1088 | 1152 | 1216 | 1280 | 1408 | 1472 | 1536 | 1600:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 512 | 1344:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
				case 1664:
					FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(true);
			}
		case 'insane corn':
			switch (curStep)
			{
				case 0:
					FlxG.camera.flash(FlxColor.BLACK, 40);
				case 240 | 496 | 2432:
				    defaultCamZoom = 0.8;
				case 256 | 2560:
				    defaultCamZoom = 0.7;
				case 512 | 1664:
				    defaultCamZoom = 0.7;
					scary.visible = true;
					FlxG.camera.flash(FlxColor.WHITE, 2);
				case 1024 | 2176:
					FlxG.camera.flash(FlxColor.WHITE);
					scary.visible = false;
				case 1520:
				    defaultCamZoom = 0.8;
					var time = (Conductor.stepCrochet / 1000) * 15;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
				case 2688:
				    defaultCamZoom = 0.8;
					FlxG.camera.flash(FlxColor.WHITE);
				case 2944:
						var time = (Conductor.stepCrochet / 1000) * 270;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
			}
		case 'maize':
			switch (curStep)
			{
				case 256 | 768 | 1536:
					defaultCamZoom = 0.75;
					FlxG.camera.flash(FlxColor.WHITE);
				case 512:
					defaultCamZoom = 0.95;
					FlxG.camera.flash(FlxColor.WHITE);
				case 1024 | 2176:
				    defaultCamZoom = 0.9;
				case 2048 | 3072:
				    defaultCamZoom = 0.85;
				case 2304 | 3328:
					defaultCamZoom = 0.75;
				case 2560:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
					sunset.visible = true;
					dad.color = 0xFFFF8FB2;
					gf.color = 0xFFFF8FB2;
                    boyfriend.color = 0xFFFF8FB2;
					flatgrass.color = 0xFFFF8FB2;
					hills.color = 0xFFFF8FB2;
					farm.color = 0xFFFF8FB2;
					foreground.color = 0xFFFF8FB2;
					cornFence.color = 0xFFFF8FB2;
					cornFence2.color = 0xFFFF8FB2;
					cornBag.color = 0xFFFF8FB2;
					sign.color = 0xFFFF8FB2;
				case 2564:
					subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub1'), 0.02, 1);
					makeInvisibleNotes(true);
				case 2578:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub2'), 0.02, 0.7);
                case 2590:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub3'), 0.02, 1);
				case 2612:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub4'), 0.02, 1);
				case 2633:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub5'), 0.02, 1, {subtitleSize: 60});
				case 2694:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub6'), 0.02, 1);
				case 2708:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub7'), 0.02, 0.5);
				case 2722:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub8'), 0.02, 1);
				case 2739:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub9'), 0.02, 1, {subtitleSize: 40});
				case 2757:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub10'), 0.02, 1);
				case 2774:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub11'), 0.02, 1);
                case 2792:
					subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub12'), 0.02, 1, {subtitleSize: 60});
					makeInvisibleNotes(false);
				case 2816:
				    FlxG.camera.flash(FlxColor.WHITE, 4);
					defaultCamZoom = 0.75;
					dad.color = 0xFF878787;
					gf.color = 0xFF878787;
                    boyfriend.color = 0xFF878787;
					sunset.visible = false;
					sky.visible = true;
					flatgrass.color = 0xFF878787;
					hills.color = 0xFF878787;
					farm.color = 0xFF878787;
					foreground.color = 0xFF878787;
					cornFence.color = 0xFF878787;
					cornFence2.color = 0xFF878787;
					cornBag.color = 0xFF878787;
					sign.color = 0xFF878787;
				case 3840:
				    FlxG.camera.flash(FlxColor.WHITE);
					bg2.visible = true;
					dad.color = 0xFFFFFFFF;
					gf.color = 0xFFFFFFFF;
                    boyfriend.color = 0xFFFFFFFF;

			}
		case 'probability':
			switch (curStep)
			{
				case 128 | 512 | 768 | 1920:
					FlxG.camera.flash(FlxColor.WHITE);
				case 138:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub1'), 0.02, 1);
					makeInvisibleNotes(true);
				case 154:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub2'), 0.02, 0.7);
                case 168:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub3'), 0.02, 1);
				case 191:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub4'), 0.02, 1);
				case 226:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub5'), 0.02, 1, {subtitleSize: 60});
				case 255:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub6'), 0.02, 1);
				case 271:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub7'), 0.02, 0.5);
				case 287:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub8'), 0.02, 1);
				case 307:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub9'), 0.02, 1, {subtitleSize: 40});
				case 328:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub10'), 0.02, 1);
				case 348:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub11'), 0.02, 1);
				case 368 | 624:
				    defaultCamZoom = 0.8;
                case 369:
					subtitleManager.addSubtitle(LanguageManager.getTextString('maize_sub12'), 0.02, 1, {subtitleSize: 60});
					makeInvisibleNotes(false);
				case 384 | 640:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;	
				case 824:
				    defaultCamZoom = 0.7;
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub1'), 0.01, 0.1, {subtitleSize: 40});
					makeInvisibleNotes(true);
				case 832:
				    defaultCamZoom = 0.6;
					makeInvisibleNotes(false);
				case 880:
				    defaultCamZoom = 0.75;
					makeInvisibleNotes(true);
					shakeCam = true;
				case 896:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;	
					makeInvisibleNotes(false);
					shakeCam = false;
				case 1024:
				    shakeCam = true;
					FlxG.camera.flash(FlxColor.WHITE);
				case 1152 | 1408:
				    shakeCam = false;
					FlxG.camera.flash(FlxColor.WHITE);
				case 1280:
				    shakeCam = true;
				case 1648:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub1'), 0.02, 1, {subtitleSize: 60});
					defaultCamZoom = 0.8;
				case 1664:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 240;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.6;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 1672:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub2'), 0.01, 0.3, {subtitleSize: 60});
					makeInvisibleNotes(true);
				case 1685:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub3-censored'), 0.01, 0.3, {subtitleSize: 60});
					}
					else
					{
				        subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub3'), 0.01, 0.3, {subtitleSize: 60});
					}
				case 1696:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub4'), 0.01, 1, {subtitleSize: 60});
				case 1717:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub5'), 0.01, 0.2, {subtitleSize: 60});
				case 1726:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub6-censored'), 0.01, 0.1, {subtitleSize: 60});
					}
					else
					{
				        subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub6'), 0.01, 0.1, {subtitleSize: 60});
					}
				case 1740 | 1750:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub7'), 0.01, 0.1, {subtitleSize: 40});
				case 1756 | 1772:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub8'), 0.01, 0.2, {subtitleSize: 40});
				case 1767 | 1782:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub6-censored'), 0.01, 0.1, {subtitleSize: 60});
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub9'), 0.01, 0.2, {subtitleSize: 40});
					}
				case 1836:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub2'), 0.01, 0.1, {subtitleSize: 40});
				case 1850:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub3'), 0.01, 0.1, {subtitleSize: 40});
				case 1859:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub10'), 0.01, 0.2, {subtitleSize: 40});
				case 1868:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub11'), 0.01, 0.2, {subtitleSize: 40});
				case 1880:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub12'), 0.1, 0.2, {subtitleSize: 40});
				case 1888:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub13'), 0.1, 0.2, {subtitleSize: 40});
				case 1904:
					subtitleManager.addSubtitle(LanguageManager.getTextString('probability_sub14'), 0.02, 0.2, {subtitleSize: 60});
			}
		case 'agronomist':
			switch (curStep)
			{
				case 18:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub1'), 0.02, 1);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 46;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 39:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub2'), 0.02, 1);
				case 64 | 192 | 528 | 960:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 320 | 1088:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 448:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 576:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 580:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub3'), 0.5, 1);
				case 603:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub4'), 0.6, 1);
				case 626:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub5'), 0.02, 1);
				case 643:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub6'), 0.6, 1);
				case 692:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub7'), 0.02, 1);
				case 704:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 832:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 1127:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomist_sub8'), 0.02, 1);
			}
		case 'subversive':
		    switch (curStep)
			{
				case 112 | 1824 | 3232 | 3360 | 3488 | 3616 | 5952 | 7824 | 8352:
				    defaultCamZoom = 0.8;
				case 128 | 512 | 640 | 2016 | 2320 | 4464 | 5392 | 5968 | 7696 | 7840 | 8368 | 9753 | 10849 | 11552 | 11808:
				    defaultCamZoom = 0.7;
					FlxG.camera.flash(FlxColor.WHITE);
				case 384 | 1760 | 1888 | 4208 | 5136 | 7568 | 8880 | 9721 | 10593 | 11296:
				    defaultCamZoom = 0.8;
					FlxG.camera.flash(FlxColor.WHITE);
				case 640 | 2144 | 2208 | 2240 | 2256 | 3968 | 4080 | 4752 | 5776 | 7968 | 8096 | 8224 | 9329 | 10262 | 10337 | 10465 | 11040 | 11280 | 11936 | 12000 | 12064 | 12448 | 12192 | 12576 | 12832:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 752:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub1'), 0.01, 0.5);
				case 768:
				    FlxG.camera.flash(FlxColor.WHITE);
					davey.visible = false;
                    YCTP.visible = true;
					defaultCamZoom = 0.4;
					subtitleManager.addSubtitle(('0 x 2 - 6 + 0'), 0.01, 1.5);
				case 832:
					subtitleManager.addSubtitle(('8 + 5 - 6 x 9'), 0.01, 1.5);
				case 880:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub2'), 0.01, 0.5);
				case 1024 | 1036 | 1047:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub3'), 0.01, 0.1);
				case 1058:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub4'), 0.01, 1);
				case 1090:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub5'), 0.01, 1);
				case 1122:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub6'), 0.01, 0.7);
				case 1148:
					subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub7'), 0.05, 1);
				case 1184:
				    FlxG.camera.flash(FlxColor.WHITE);
					YCTP.visible = false;
                    hallwayChase.visible = true;
					hallwayChase.active = true;
					defaultCamZoom = 0.7;
				case 1472:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 1488:
				    FlxTween.tween(dad, {x: dad.x - 500}, 0.5, {ease:FlxEase.quadOut});
				case 1504:
					FlxG.camera.flash(FlxColor.WHITE);
				case 1776 | 1840:
				    defaultCamZoom = 0.9;
				case 1792 | 1856 | 3248 | 3376 | 3504 | 3632 | 9136:
				    defaultCamZoom = 0.7;
				case 2272:
				    FlxG.camera.flash(FlxColor.WHITE);
				    hallwayChase.visible = false;
					hallwayChase.active = false;
					imseeingthelocker.visible = true;
					defaultCamZoom = 0.9;
				case 2304:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub8'), 0.01, 1);
				case 3154:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub9'), 0.01, 1);
				case 3184:
				    FlxTween.tween(dad, {x: dad.x + 600}, 0.5, {ease:FlxEase.quadOut});
					FlxG.camera.flash(FlxColor.WHITE);
				case 3657:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub10'), 0.05, 1);
				case 3680 | 3952:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 3696:
				    FlxG.camera.flash(FlxColor.WHITE);
				    detention.visible = true;
					imseeingthelocker.visible = false;
				case 4720:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub11'), 0.01, 1);
				case 5520:
				    FlxG.camera.flash(FlxColor.WHITE);
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 256;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 4677:
				    FlxG.camera.flash(FlxColor.WHITE);
					detention.visible = false;
					silverManHallway.visible = true;
				case 6480:
				    FlxG.camera.flash(FlxColor.WHITE);
				    silva.visible = true;
					var time = (Conductor.stepCrochet / 1000) * 576;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
				case 7056:
				    FlxG.camera.flash(FlxColor.WHITE);
				    silva.visible = false;
				case 7826:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub12'), 0.01, 0.5);
				case 9185:
				    FlxG.camera.flash(FlxColor.WHITE);
					staticscr.visible = true;
					defaultCamZoom = 0.65;
				case 9393:
				    FlxG.camera.flash(FlxColor.WHITE);
					silverManHallway.visible = false;
					makeInvisibleNotes(true);
				case 9394:
					staticscr.visible = false;
					defaultCamZoom = 0.7;
					nodesk.visible = true;
					desk.visible = true;
				case 9413:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub13'), 0.01, 2);
				case 9457:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub14'), 0.01, 0.5);
				case 9480:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub15'), 0.01, 0.5);
				case 9501:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub16'), 0.01, 1);
				case 9525:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub17'), 0.01, 1);
				case 9559:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub18'), 0.01, 1);
				case 9593:
				    FlxG.camera.flash(FlxColor.WHITE);
                    makeInvisibleNotes(false);
				case 10235:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub19'), 0.01, 1);
				case 10263:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub20'), 0.01, 0.5);
					makeInvisibleNotes(true);
				case 10278:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub21'), 0.01, 0.9);
				case 10302:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub22'), 0.01, 1.2);
					makeInvisibleNotes(false);
				case 10913:
					nodesk.visible = false;
					desk.visible = false;
					FlxG.camera.flash(FlxColor.WHITE, 2);
				case 10914:
				    cinema.visible = true;
					defaultCamZoom = 0.75;
					makeInvisibleNotes(true);
				case 10931:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub23'), 0.01, 1);
				case 10963:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub24'), 0.01, 0.3);
				case 10980:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub25'), 0.01, 0.5);
				case 10997:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub26-censored'), 0.01, 1);
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('subversive_sub26'), 0.01, 1);
					}
				case 11025:
				    makeInvisibleNotes(false);
                case 12320:
				    FlxG.camera.flash(FlxColor.WHITE);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 512;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			}
		case 'reminiscence':
		    switch (curStep)
			{
				case 0:
				    defaultCamZoom = 1.2;
				    FlxG.camera.flash(FlxColor.WHITE, 30);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 160;
						FlxTween.num(curZoom, curZoom - 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 256 | 512:
				    defaultCamZoom = 0.9;
				case 384 | 640 | 1536:
				    defaultCamZoom = 0.8;
				case 752 | 1264:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 768:
				    bgr2.visible = true;
					bgr.visible = false;
				case 1280:
				    defaultCamZoom = 0.9;
				    bgr2.visible = false;
					bgr.visible = true;
				case 1664:
					var time = (Conductor.stepCrochet / 1000) * 144;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
			}
		case 'mustard':
		    switch (curStep)
			{
				case 48 | 304 | 816 | 1088:
		            defaultCamZoom = 0.9;
				case 64 | 320 | 832 | 1104:
				    defaultCamZoom = 0.8;
				case 184 | 312 | 568 | 824 | 1096:
					var time = (Conductor.stepCrochet / 1000) * 8;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
			}
		case 'in the trap':
		    switch (curStep)
			{
				case 256 | 768 | 1280:
				    FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'tech':
			switch (curStep)
			{
				case 512 | 1280:
				    defaultCamZoom = 0.85;
                case 768 | 1536 | 2048:
				    defaultCamZoom = 0.75;
				case 1792:
				    defaultCamZoom = 0.65;
			}
		case 'carnivore':
			switch (curStep)
			{
				case 128 | 384 | 768 | 1088 | 1984 | 2022:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 640:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 896:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.85;
				case 960:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 1120 | 1248 | 1376 | 1632 | 1760 | 1888:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 1;
				case 1184 | 1312 | 1440 | 1568 | 1696 | 2016:
				    defaultCamZoom = 0.8;
				case 1504:
				    defaultCamZoom = 1;
				case 1824 | 1952:
				    defaultCamZoom = 0.9;
			}
		case 'oblique':
			switch (curStep)
			{
				case 0 | 384 | 512 | 640 | 768 | 896 | 1280 | 1536 | 1664:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 128:
				    FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(true);
				case 230:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('oblique_sub1'), 0.01, 1);
				case 240:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('oblique_sub2'), 0.02, 1);
					makeInvisibleNotes(false);
				case 256 | 1408:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
				case 1024:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
				case 1792:
				    var time = (Conductor.stepCrochet / 1000) * 128;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
			}
		case 'electronic':
			switch (curStep)
			{
				case 16:
				    FlxG.camera.flash(FlxColor.WHITE);
                case 144 | 528 | 784 | 1168 | 1424:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.85;
				case 272 | 656 | 1040 | 1456:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.75;
				case 400:
				    FlxG.camera.flash(FlxColor.WHITE);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.05, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 912 | 1296:
					defaultCamZoom = 0.75;
			}
		case 'asfalto':
			switch (curStep)
			{
				case 64 | 336 | 1600 | 2304 | 2432:
					FlxG.camera.flash(FlxColor.WHITE);
				case 192 | 448 | 640 | 768 | 1344 | 1504 | 1568:
					defaultCamZoom = 0.7;
				case 320 | 576 | 704 | 1472 | 1536:
					defaultCamZoom = 1;
				case 832:
				    iconP2.changeIcon('icon-frog');
					healthBar.createFilledBar(0xFF17781E, 0xFF308ACA);
					healthBar.updateBar();
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 1;
				case 1216:
				    iconP2.changeIcon('icon-dave-gnomo');
					healthBar.createFilledBar(0xFF1A48D1, 0xFF308ACA);
					healthBar.updateBar();
					FlxG.camera.flash(FlxColor.WHITE);
				case 1856:
				    FlxG.camera.flash(FlxColor.WHITE, 4);
					fet.visible = true;
				case 2560:
				    iconP2.changeIcon('icon-frog');
					healthBar.createFilledBar(0xFF17781E, 0xFF308ACA);
					healthBar.updateBar();
					FlxG.camera.flash(FlxColor.WHITE);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 256;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 2624:
				    iconP2.changeIcon('icon-dave-gnomo');
					healthBar.createFilledBar(0xFF1A48D1, 0xFF308ACA);
					healthBar.updateBar();
				case 2808:
				    iconP2.changeIcon('icon-frog');
					healthBar.createFilledBar(0xFF17781E, 0xFF308ACA);
					healthBar.updateBar();
			}
		case 'agronomo':
			switch (curStep)
			{
                case 12:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomo_sub1'), 0.02, 1);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 52;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 38:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomo_sub2'), 0.02, 1);
				case 64:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 320:
				    subtitleManager.addSubtitle(('FLKEJITJWITJWEIRJTERJTKIJW3UTHUWEHTREJJHOERGIJETRHI9HTRGU9TEHJEHYTDR9YERUH9REYTUHERYTIH9IEYRJYEI9RYJREJHYKFJEWIJWIEJIWEJOIEWJOKJWEOIKJIOKEWJIWJEOTJWEOJTOWEJTEWJOITJEWIJTWEIJTGOIWJKOWEJGEWJGOEWJIGJEWIGJEWOIJGEWIOJGIOEWJ'), 2, 2, {subtitleSize: 60});
				case 512:
				    subtitleManager.addSubtitle(('BBBBBBBBBRRURURURURURUURURURURURU'), 1, 1, {subtitleSize: 60});
				case 576:
				    defaultCamZoom = 0.9;
					FlxG.camera.flash(FlxColor.WHITE);
				case 580:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomo_sub3'), 5, 5);
				case 683:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomo_sub4'), 1, 1, {subtitleSize: 60});
					defaultCamZoom = 0.95;
				case 689:
				    defaultCamZoom = 1;
				case 696:
				    defaultCamZoom = 1.05;
				case 703 | 790:
				    defaultCamZoom = 0.8;
				case 784 | 1088:
				    defaultCamZoom = 0.9;
				case 1127:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('agronomo_sub5'), 0.02, 1);
			}
		case '123.12.1234.123':
		    switch (curStep)
			{
				case 112 | 256:
				    defaultCamZoom = 1.1;
				case 128 | 384 | 1248 | 2080:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 1;
				case 449:
					makeInvisibleNotes(true);
					subtitleManager.addSubtitle(LanguageManager.getTextString('ip_sub1'), 0.02, 2);
				case 480:
				    FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(false);
					redsky.visible = true;
				case 992 | 1312 | 2352:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 1120:
				    defaultCamZoom = 0.95;
				case 1568:
				    FlxG.camera.flash(FlxColor.WHITE);
					redsky.visible = false;
					defaultCamZoom = 1;
				case 1696 | 1952:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 1.1;
				case 1824:
				    defaultCamZoom = 1;
				case 2224:
				    FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'agronomist v71961':
			switch (curStep)
			{
				case 0 | 128 | 256 | 768 | 896 | 1024:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 368:
				    defaultCamZoom = 0.8;
				case 384:
				    defaultCamZoom = 0.7;
					FlxG.camera.flash(FlxColor.WHITE);
				case 512:
				    FlxG.camera.flash(FlxColor.WHITE, 2);
					bob.visible = true;
					creditsWatermark.text = LanguageManager.getTextString('agrov719612_credit');
				case 524 | 780:
				    defaultCamZoom = 0.9;
				case 528 | 784:
				    defaultCamZoom = 0.7;
				case 640:
				    FlxG.camera.flash(FlxColor.WHITE);
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 128; 
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			}
		case 'lightning':
			switch (curStep)
			{
				case 64 | 84 | 144 | 256 | 336 | 640 | 778 | 832:
				    FlxG.camera.flash(FlxColor.YELLOW);
				case 384 | 704:
				    FlxG.camera.flash(FlxColor.YELLOW);
				    defaultCamZoom = 0.99;
			    case 512:
				    FlxG.camera.flash(FlxColor.YELLOW);
				    defaultCamZoom = 0.89;
				case 768:
				    defaultCamZoom = 0.89;
			}
		case 'dealings':
			switch (curStep)
			{
				case 32 | 1312:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 288:
				    defaultCamZoom = 1.1;
				    FlxG.camera.flash(FlxColor.WHITE);
				case 416:
				    defaultCamZoom = 1.2;
				case 480:
				    defaultCamZoom = 1.3;
				case 544 | 1056:
				    defaultCamZoom = 1;
					FlxG.camera.flash(FlxColor.WHITE);
				case 800:
				    defaultCamZoom = 1.3;
					FlxG.camera.flash(FlxColor.WHITE);
				case 932:
				    defaultCamZoom = 1.2;
					FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'cake':
			switch (curStep)
			{
				case 112 | 256 | 640 | 896 | 1296:
				    defaultCamZoom = 0.8;
				case 128 | 384 | 1024 | 1552:
				    defaultCamZoom = 0.7;
				case 363 | 1265:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('cake_sub1'), 0.02, 0.5);
				case 374 | 1276:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('cake_sub2'), 0.02, 0.5, {subtitleSize: 40});
				case 768:
				    defaultCamZoom = 0.9;
				case 960:
				    defaultCamZoom = 0.95;
			}
		case 'trains':
			switch (curStep)
			{
				case 17:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub1'), 0.02, 1);
					makeInvisibleNotes(true);
				case 35:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub2'), 0.02, 0.5);
				case 46:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub3'), 0.02, 0.5);
				case 58:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub4'), 0.02, 0.5);
				case 68:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub5'), 0.02, 0.5);
				case 80:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub6'), 0.02, 1);
				case 104:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub7'), 0.02, 0.3);
				case 114:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub8'), 0.02, 0.5, {subtitleSize: 40});
				case 120:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub9'), 0.02, 1);
				case 135:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub10'), 0.02, 0.5);
				case 146:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub11'), 0.02, 0.5);
				case 154:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub12'), 0.02, 0.5);
				case 169:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub13'), 0.02, 0.3);
				case 176:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub14'), 0.02, 0.3);
				case 186:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub15'), 0.02, 0.6);
				case 200:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub16'), 0.02, 0.5);
				case 206:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub17'), 0.02, 1);
				case 225:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub18'), 0.02, 0.2);
				case 233:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub19'), 0.02, 0.3);
				case 240:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub11'), 0.02, 0.5, {subtitleSize: 40});
				case 256:
				    FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(false);
				case 512 | 960:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
				case 784 | 1216:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
				case 832 | 896 | 928:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 945:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub20'), 0.02, 0.5, {subtitleSize: 40});
				case 1248:
				    makeInvisibleNotes(true);
				case 1279:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub21'), 0.02, 0.5);
				case 1291:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub22'), 0.02, 0.3);
				case 1295:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub23'), 0.02, 0.5);
				case 1313:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub24'), 0.02, 0.5);
				case 1337:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('trains_sub25'), 0.02, 1);
			}
		case 'nice and cool':
			switch (curStep)
			{
				case 16:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 272 | 784:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 528 | 1040:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
			}
		case 'p':
			switch (curStep)
			{
				case 1:
				    creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'geby', 'geby');
				case 32 | 160 | 288:
					FlxG.camera.flash(FlxColor.WHITE);
				case 544 | 928 | 1568 | 3040 | 3616:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 800 | 1056 | 1312 | 1824:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
				case 1184:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
					makeInvisibleNotes(true);
				    creditsWatermark.text = LanguageManager.getTextString('dealings_credit');
					creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);

					creditsPopup.switchHeading({path: 'songHeadings/kiwiHeading', antiAliasing: true, iconOffset: 0});
				    creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'Webby', 'Webby');
				    FlxTween.tween(creditsPopup, {x: 0}, 0.5, {ease: FlxEase.backOut, onComplete: function(tweeen:FlxTween)
					{
						FlxTween.tween(creditsPopup, {x: creditsPopup.width * -1} , 1, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
						{
							creditsPopup.destroy();
						}, startDelay: 3});
					}});
				case 1187:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub1'), 0.02, 0.5, {subtitleSize: 60});
				case 1202:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub2-censored'), 0.02, 0.5, {subtitleSize: 60});
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub2'), 0.02, 0.5, {subtitleSize: 60});
					}
				case 1213:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub3'), 0.02, 0.2, {subtitleSize: 60});
				case 1224 | 1258:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub4'), 0.02, 0.3, {subtitleSize: 60});
				case 1243:
				    if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub5'), 0.02, 0.3, {subtitleSize: 60});
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub5-censored'), 0.02, 0.3, {subtitleSize: 60});
					}
				case 1250:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub6'), 0.02, 0.2, {subtitleSize: 60});
				case 1280:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub7'), 0.02, 0.5, {subtitleSize: 70});
				case 1298:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub8-censored'), 0.02, 0.5, {subtitleSize: 70});
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('p_sub8'), 0.02, 0.5, {subtitleSize: 70});
					}
					makeInvisibleNotes(false);
				case 1440:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 2480:
				    FlxG.camera.flash(FlxColor.WHITE);
					creditsWatermark.text = LanguageManager.getTextString('p2_credit');
					bgp2.visible = true;
					creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);

					creditsPopup.switchHeading({path: 'songHeadings/dplushiesHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'poopypants839', 'poopypants839');
				    FlxTween.tween(creditsPopup, {x: 0}, 0.5, {ease: FlxEase.backOut, onComplete: function(tweeen:FlxTween)
					{
						FlxTween.tween(creditsPopup, {x: creditsPopup.width * -1} , 1, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
						{
							creditsPopup.destroy();
						}, startDelay: 3});
					}});
				case 2992 | 3808:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 45;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 3296:
				    defaultCamZoom = 0.7;
			}
		case 'lore':
			switch (curStep)
			{
				case 0 | 512 | 912 | 1024 | 1816 | 2176:
				    defaultCamZoom = 0.95;
				case 64 | 768 | 1088 | 2240 | 1824 | 2048 | 2368:
				    defaultCamZoom = 0.85;
				case 128 | 896 | 928 | 1152 | 2304:
				    defaultCamZoom = 0.75;
				case 1792:
				    defaultCamZoom = 0.85;
					FlxG.camera.flash(FlxColor.WHITE);
					iconP2.changeIcon('icon-gambo');
					healthBar.createFilledBar(0xFFDB3131, 0xFF484848);
					healthBar.updateBar();
				case 1920 | 2416:
					defaultCamZoom = 0.75;
				    iconP2.changeIcon('icon-jonlore');
					healthBar.createFilledBar(0xFFFF74C7, 0xFF484848);
					healthBar.updateBar();
				case 2128 | 2144 | 2372:
				    iconP2.changeIcon('icon-gambo');
					healthBar.createFilledBar(0xFFDB3131, 0xFF484848);
					healthBar.updateBar();
				case 2140 | 2172:
				    iconP2.changeIcon('icon-jonlore');
					healthBar.createFilledBar(0xFFFF74C7, 0xFF484848);
					healthBar.updateBar();
			}
		case 'kawai!1!':
		    switch (curStep)
			{
				case 0 | 31 | 63 | 96 | 128 | 160 | 224 | 288 | 352 | 384 | 416 | 480 | 512 | 544 | 576 | 608 | 640 | 672 | 704 | 768 | 800 | 832 | 864 | 896 | 928 | 960 | 1040 | 1072 | 1104:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 192:
           		    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.55;
				case 256 | 448 | 1008:
           		    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.5;
				case 320 | 803 | 1136:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.6;
				case 720 | 991:
					var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
			}
		case 'untitled':
			switch (curStep)
			{
				case 1:
				    creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'geby', 'geby');
				case 128 | 896 | 2496 | 3168 | 3616 | 5184 | 5984 | 6240 | 7008 | 7184 | 7440 | 7952 | 8080 | 8752 | 9008:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 384 | 2720 | 3296 | 6496:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 1;
				case 640 | 2784 | 3424 | 5696 | 6752 | 7312:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.9;
				case 1078:
				    var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.GREEN, time, false, function()
						{
							FlxG.camera.fade(FlxColor.GREEN, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.GREEN, 0.5);
							});
						});
			  	case 1087:
                    FlxG.camera.flash(FlxColor.GREEN, 7);
				case 1728 | 1856 | 4672 | 4800 | 4928 | 5056:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 128;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.9;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 2520:
				    var time = (Conductor.stepCrochet / 1000) * 8;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
			  	case 2527:
				    FlxG.camera.flash(FlxColor.WHITE);
					sproya.visible = true;
					fino.visible = false;
				case 2592:
				    FlxG.camera.flash(FlxColor.WHITE);
				    creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);

					creditsPopup.switchHeading({path: 'songHeadings/esplaHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'Espla', 'Espla');
				case 2594 | 4164 | 5730 | 7058 | 8498:
				    FlxTween.tween(creditsPopup, {x: 0}, 0.5, {ease: FlxEase.backOut, onComplete: function(tweeen:FlxTween)
					{
						FlxTween.tween(creditsPopup, {x: creditsPopup.width * -1} , 1, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
						{
							creditsPopup.destroy();
						}, startDelay: 3});
					}});
				case 2776:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 8;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 1;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 3024 | 5712 | 5968 | 6224 | 6480 | 6736 | 6992 | 7040 | 8192:
				    var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
				case 3600:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.9;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 4128:
				    var time = (Conductor.stepCrochet / 1000) * 32;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
				case 4161:
				    FlxG.camera.flash(FlxColor.WHITE);
					sproya.visible = false;
					maize.visible = true;
					sky.visible = true;
					gb.visible = true;
					webby.visible = true;
					dad.color = 0xFF878787;
					gf.color = 0xFF878787;
                    boyfriend.color = 0xFF878787;
					defaultCamZoom = 0.85;
				case 4162:
				    creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);

					creditsPopup.switchHeading({path: 'songHeadings/luanHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'Luan', 'Luan');
				case 5727:
				    FlxG.camera.flash(FlxColor.WHITE);
					maize.visible = false;
					sky.visible = false;
					gb.visible = false;
					webby.visible = false;
					fancy.visible = true;
					dad.color = 0xFFFFFFFF;
					gf.color = 0xFFFFFFFF;
                    boyfriend.color = 0xFFFFFFFF;
					defaultCamZoom = 0.9;
				case 5728:
				    creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);
	
					creditsPopup.switchHeading({path: 'songHeadings/benHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'Ben', 'Ben');
				case 7056:					
				    FlxG.camera.flash(FlxColor.WHITE);
					fancy.visible = false;
					bmabi.visible = true;
					defaultCamZoom = 0.85;
					creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);
	
					creditsPopup.switchHeading({path: 'songHeadings/joojHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'JooJ Dumwell', 'JooJ Dumwell');
				case 7568:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.85;
				case 8208:
				    comercial.visible = true;
					bmabi.visible = false;
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.85;
				case 8496:
			     	FlxG.camera.flash(FlxColor.WHITE);
				    creditsPopup = new CreditsPopUp(FlxG.width, 200);
					creditsPopup.camera = camOther;
					creditsPopup.scrollFactor.set();
					creditsPopup.x = creditsPopup.width * -1;
					add(creditsPopup);

					creditsPopup.switchHeading({path: 'songHeadings/dplushiesHeading', antiAliasing: true, iconOffset: 0});
					creditsPopup.changeText(LanguageManager.getTextString('credits_partby') + ' ' + 'poopypants839', 'poopypants839');
				case 9136 | 9408 | 9936 | 10080 | 10352 | 10640 | 10912:
				    staticscr.visible = true;
					defaultCamZoom = 0.7;
				case 9152:
				    staticscr.visible = false;
					comercial.visible = false;
					flipaclip.visible = true;
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 1.2;
				case 9424:
				    staticscr.visible = false;
					FlxG.camera.flash(FlxColor.WHITE);
					flipaclip.visible = false;
					paroxeie.visible = true;
					defaultCamZoom = 0.9;
				case 9952:
				    staticscr.visible = false;
					white.visible = true;
					paroxeie.visible = false;
					FlxG.camera.flash(FlxColor.WHITE);
				case 10096:
				    staticscr.visible = false;
					FlxG.camera.flash(FlxColor.WHITE);
					white.visible = false;
					discord.visible = true;
                    defaultCamZoom = 0.9;
				case 10368:
				    staticscr.visible = false;
					solanabota.visible = true;
					discord.visible = false;
					defaultCamZoom = 0.9;
				case 10656:
				    staticscr.visible = false;
					sansino.visible = true;
					solanabota.visible = false;
					shakeCam = true;
				case 10784:
				    shakeCam = false;
				case 10928:
				    staticscr.visible = false;
					FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(true);
					EvilhallwayChase.visible = true;
					EvilhallwayChase.active = true;
					car1.visible = true;
					car2.visible = true;
				case 10931:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub1'), 0.2, 1);
				case 10946:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub2-censored'), 0.2, 1);
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub2'), 0.2, 1);
					}
				case 10965:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub3'), 0.7, 1);
				case 10996:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub4'), 1.2, 1);
				case 11038:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('untitled_sub5'), 0.3, 1);
				case 11056:
				    FlxG.camera.flash(FlxColor.WHITE);
					makeInvisibleNotes(false);
				case 11312:
				    defaultCamZoom = 0.8;
					FlxG.camera.flash(FlxColor.WHITE);
				case 11444:
				    defaultCamZoom = 0.7;
					FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'spin dashin':
			switch (curStep)
			{
				case 112 | 1264:
				    defaultCamZoom = 0.9;
				case 128 | 640 | 3088 | 3344:
				    defaultCamZoom = 0.8;
				    FlxG.camera.flash(FlxColor.WHITE);
				case 256 | 512 | 704 | 768 | 832 | 896 | 1024 | 2128 | 2704 | 3216:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 384 | 2448:
				    defaultCamZoom = 0.9;
				    FlxG.camera.flash(FlxColor.WHITE);
				case 1152:
				    defaultCamZoom = 0.85;
				case 1304:
				    defaultCamZoom = 0.8;
				    black.visible = true;
				case 1360:
				    defaultCamZoom = 0.85;
					FlxG.camera.flash(FlxColor.RED);
					evil.visible = true;
					exesky.visible = true;
					black.visible = false;
				case 1616:
				    defaultCamZoom = 0.8;
				case 1856:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 1872:
				    FlxG.camera.flash(FlxColor.WHITE);
					evil.visible = false;
					exesky.visible = false;
				case 2320:
				    FlxG.camera.flash(FlxColor.WHITE);
					iconP2.changeIcon('icon-miles');
					healthBar.createFilledBar(0xFFE58100, 0xFF0045D0);
					healthBar.updateBar();
				case 2352 | 2732 | 2944 | 3128:
				    iconP2.changeIcon('icon-puncher');
					healthBar.createFilledBar(0xFFD50247, 0xFF0045D0);
					healthBar.updateBar();
				case 2464 | 2792 | 2964 | 3328:
				    iconP2.changeIcon('icon-speedu');
					healthBar.createFilledBar(0xFF0045AA, 0xFF0045D0);
					healthBar.updateBar();
				case 2576 | 3504:
				    iconP2.changeIcon('icon-puncher');
					healthBar.createFilledBar(0xFFD50247, 0xFF0045D0);
					healthBar.updateBar();
					defaultCamZoom = 0.8;
				    FlxG.camera.flash(FlxColor.WHITE);
				case 2640 | 2836 | 3160 | 3488:
					iconP2.changeIcon('icon-miles');
					healthBar.createFilledBar(0xFFE58100, 0xFF0045D0);
					healthBar.updateBar();
				case 2832:
				    defaultCamZoom = 0.85;
					FlxG.camera.flash(FlxColor.WHITE);
				case 3472:
				    defaultCamZoom = 0.85;
					iconP2.changeIcon('icon-puncher');
					healthBar.createFilledBar(0xFFD50247, 0xFF0045D0);
					healthBar.updateBar();
			}
		case 'icsa3aahcmaj':
			switch (curStep)
			{
				case 16 | 144 | 272 | 400 | 528 | 656 | 784:
				    FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'fnaf is real':
			switch (curStep)
			{
				case 0 | 64 | 128 | 192 | 256 | 320 | 384 | 448 | 512 | 576 | 704 | 832 | 896 | 960 | 1091 | 1230 | 1294 | 1358 | 2480 | 2544 | 2352:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 640 | 1024 | 1584 | 1904:
                    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 768 | 1166 | 1712 | 2096:
                    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 1417:
				    FlxG.camera.flash(FlxColor.BLACK, 13);
				case 2608:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			}
		case 'dangerous':
			switch (curStep)
			{
				case 0:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 256;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.6;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 256:
				    defaultCamZoom = 1;
				case 384 | 1664 | 2176 | 2560:
				    defaultCamZoom = 0.6;
				case 512 | 1280 | 2304:
					defaultCamZoom = 0.7;
				case 752:
				    defaultCamZoom = 0.8;
					var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
				case 768:
				    defaultCamZoom = 0.6;
				case 1272:
				    var time = (Conductor.stepCrochet / 1000) * 8;
						FlxG.camera.fade(FlxColor.BLACK, time, false, function()
						{
							FlxG.camera.fade(FlxColor.BLACK, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							});
						});
				case 1472 | 1760:
				    defaultCamZoom = 0.8;
				case 1792:
				    defaultCamZoom = 0.6;
					FlxG.camera.flash(FlxColor.WHITE);
				case 2048:
				    defaultCamZoom = 0.5;
				case 2584:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 8;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 1;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			}
		case 'talkative':
			switch (curStep)
			{
				case 0 | 128 | 256 | 640 | 896 | 1152 | 1536 | 2480 | 2736 | 2992 | 3376:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 64:
				    FlxG.camera.flash(FlxColor.WHITE);
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 64;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			    case 384 | 768 | 1792 | 2608:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 512 | 1024 | 2048 | 2864:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 3360:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 3392:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('talkative_sub1'), 0.02, 0.5);
				case 3408:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('talkative_sub2-censored'), 0.02, 1);
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('talkative_sub2'), 0.02, 1);
					}
				case 3430:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('talkative_sub3'), 0.02, 1);
				    if(!ClientPrefs.cursing)
					{
						remove(subtitleManager);
					}
				case 3435:
				    shakeCam = true;
			}
		case 'style':
			switch (curStep)
			{
				case 0 | 128 | 256 | 384 | 640 | 896 | 1156 | 1424 | 1552 | 1680:
					FlxG.camera.flash(FlxColor.WHITE);
				case 352 | 608 | 864 | 1120 | 1392 | 1648:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			}
		case 'fancy':
			switch (curStep)
			{
				case 0:
				    makeInvisibleNotes(true);
				case 32:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('fancy_sub1'), 0.02, 1);
					var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.05, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.85;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 59 | 188:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('fancy_sub2'), 0.02, 0.5);
				case 76 | 206:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('fancy_sub3'), 0.02, 1);
				case 104 | 237:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('fancy_sub4'), 0.02, 1);
				case 128:
				    makeInvisibleNotes(false);
				case 160:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('fancy_sub1'), 0.02, 1);
				case 224 | 1440:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 32;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 256 | 1472 | 1856 | 1888 | 1920 | 1936 | 1952 | 1968 | 2240:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 512 | 1216:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.9;
				case 768 | 896 | 1984 | 2112:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 128;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.8;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 1168:
					FlxG.camera.flash(FlxColor.GREEN, 3);
				case 1336 | 1584 | 1712:
				    defaultCamZoom = 0.85;
				case 1344 | 1600 | 1728:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.8;
			}
		case 'motocycle':
			switch (curStep)
			{
				case 16 | 272 | 656 | 912 | 1312 | 1440 | 2768:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 136 | 304 | 400 | 576 | 608 | 624 | 768 | 2608 | 2896:
				    defaultCamZoom = 0.79;
				case 144 | 320 | 416 | 780:
				    defaultCamZoom = 0.59;
				case 256:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('motocycle_sub1'), 1, 1);
				case 512:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('motocycle_sub2'), 1, 1);
				case 528 | 1568 | 2640:
				    defaultCamZoom = 0.69;
					FlxG.camera.flash(FlxColor.WHITE);
				case 592 | 752 | 1098 | 1936 | 2336:
				    defaultCamZoom = 0.69;
				case 616 | 622 | 1808:
				    defaultCamZoom = 0.89;
				case 620:
				    defaultCamZoom = 0.17;
				case 640:
				    defaultCamZoom = 0.59;
				    subtitleManager.addSubtitle(LanguageManager.getTextString('motocycle_sub1'), 1, 1);
				case 1072:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('motocycle_sub3'), 1, 1);
					FlxG.camera.flash(FlxColor.WHITE);
				case 1184 | 1680 | 1816 | 2928 | 2352:
				    defaultCamZoom = 0.59;
					FlxG.camera.flash(FlxColor.WHITE);
				case 1664:
				    defaultCamZoom = 0.69;
				    iconP1.changeIcon('icon-gf');
					healthBar.createFilledBar(0xFF363636, 0xFFA5004D);
					healthBar.updateBar();
				case 2176:
				    FlxTween.tween(bgcar, {x: bgcar.x - -400}, 0.5, {ease:FlxEase.quadOut});
					bgcar.visible = true;
				case 2224:
					FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.59;
					plambiradical.visible = true;
					healthBar.createFilledBar(0xFF000013, 0xFFA5004D);
					healthBar.updateBar();
				case 2949:
					plambiradical.visible = false;
					mataramoplambi.visible = true;
					mataramoplambi.active = true;
				case 2952:
					FlxG.camera.shake(0.0075, 0.1);
					camHUD.shake(0.0045, 0.1);
			}
		case 'power':
			switch (curStep)
			{
				case 184 | 336 | 368 | 912 | 960 | 1008 | 1040:
				    defaultCamZoom = 0.7;
				case 192:
				    defaultCamZoom = 0.8;
					FlxG.camera.flash(FlxColor.WHITE);
                case 316:
				    defaultCamZoom = 0.9;
				case 320 | 528:
				    defaultCamZoom = 0.6;
					FlxG.camera.flash(FlxColor.WHITE);
				case 328 | 360 | 944 | 1024:
				    defaultCamZoom = 0.8;
				case 344 | 376 | 976:
				    defaultCamZoom = 0.6;
				case 464:
				    defaultCamZoom = 0.9;
					FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'fun spooky battle':
			switch (curStep)
			{
				case 376:
					defaultCamZoom = 1.45;
				case 384:
					defaultCamZoom = 1.25;
				case 448:
					FlxG.camera.flash(FlxColor.WHITE);
					bgg2.visible = true;
					bg1.visible = false;
					iconP2.changeIcon('icon-strawman-dave');
					healthBar.createFilledBar(0xFF1A1B66, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
				case 896:
				    FlxG.camera.flash(FlxColor.WHITE);
				    iconP2.changeIcon('icon-pumpkinbambi');
					healthBar.createFilledBar(0xFF048D01, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
				case 1284:
				    iconP2.changeIcon('icon-strawman-dave');
					healthBar.createFilledBar(0xFF1A1B66, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
				case 1288:
				    iconP2.changeIcon('icon-pumpkintristan');
					healthBar.createFilledBar(0xFFA34F13, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
			}
		case 'falsify':
			switch (curStep)
			{
				case 367:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub1-censored'), 0.01, 1);
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub1'), 0.02, 0.5);
					}
				case 376:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub2'), 0.02, 0.5);
				case 384 | 640:
				    defaultCamZoom = 0.7;
				case 400 | 656 | 1152:
				    defaultCamZoom = 0.8;
				case 416 | 672:
				    defaultCamZoom = 0.85;
				case 432 | 496 | 688 | 752:
				    defaultCamZoom = 0.9;
				case 448 | 480 | 704 | 736:
				    defaultCamZoom = 0.95;
				case 464 | 720:
				    defaultCamZoom = 1;
				case 896:
				    defaultCamZoom = 0.7;
				case 1171:
				    subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub3'), 0.02, 1);
					makeInvisibleNotes(true);
				case 1184:
					if(!ClientPrefs.cursing)
					{
						subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub4-censored'), 0.01, 1);
					}
					else
				    {
						subtitleManager.addSubtitle(LanguageManager.getTextString('falsify_sub4'), 0.02, 0.5);
					}
				case 1197:
				    subtitleManager.addSubtitle(('CA€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A'), 0.04, 0.5);
			}
		case 'phantasm':
			switch (curStep)
			{
				case 128 | 512 | 896 | 1152 | 1280 | 1664:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.85;
				case 256:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.75;
                case 640 | 1024 | 1408 | 1792:
				    FlxG.camera.flash(FlxColor.GREEN);
					defaultCamZoom = 0.75;
					fleet.visible = false;
				case 384 | 768 | 1172 | 1276 | 1282 | 1304 | 1536 | 1922 | 1937 | 1943 | 1956:
					FlxG.camera.flash(FlxColor.GREEN);
					fleet.visible = true;
					healthBar.createFilledBar(0xFFCF51D3, 0xFFCF51D3);
					healthBar.updateBar();
				case 1154 | 1176 | 1279 | 1300 | 1408 | 1926 | 1940 | 1946 | 1960:
					FlxG.camera.flash(FlxColor.GREEN);
					fleet.visible = false;
				case 1856 | 1888:
				    FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'pipebomb':
			switch (curStep)
			{
				case 0:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 128:
				    defaultCamZoom = 0.65;
				case 256:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.7;
				case 384:
				    FlxG.camera.flash(FlxColor.WHITE);
				    defaultCamZoom = 0.6;
				case 503:
					FlxG.camera.flash(FlxColor.WHITE);
				    subtitleManager.addSubtitle(LanguageManager.getTextString('pipebomb_sub1'), 0.02, 1);
				case 768:
					defaultCamZoom = 0.8;
					FlxG.camera.flash(FlxColor.WHITE);
					black.visible = true;
				case 896:
					defaultCamZoom = 0.6;
					FlxG.camera.flash(FlxColor.WHITE);
					black.visible = false;
				case 954:
					FlxG.camera.flash(FlxColor.WHITE, 1000000);
			}
		case 'jollytastic!':
			switch (curStep)
			{
				case 16 | 656:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 144 | 784:
				    defaultCamZoom = 0.78;
					FlxG.camera.flash(FlxColor.WHITE);
				case 272 | 536 | 912:
				    defaultCamZoom = 0.68;
					FlxG.camera.flash(FlxColor.WHITE);
				case 384:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.68;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
				case 400:
			     	FlxG.camera.flash(FlxColor.WHITE);
				    iconP2.changeIcon('icon-plambixmas');
					healthBar.createFilledBar(0xFF303030, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
				case 528:
				    defaultCamZoom = 0.78;
				case 848:
				    iconP2.changeIcon('icon-samnyxmas');
					healthBar.createFilledBar(0xFFABCFFF, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
				case 904:
				    iconP2.changeIcon('icon-plambixmas');
					healthBar.createFilledBar(0xFF303030, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
					healthBar.updateBar();
			}
		case 'cookie dough':
			switch (curStep)
			{
				case 112 | 368 | 1016:
				    defaultCamZoom = 0.8;
				case 128 | 384 | 1024:
				    defaultCamZoom = 0.7;
					FlxG.camera.flash(FlxColor.WHITE);
				case 256 | 640 | 768 | 896 | 1152 | 1280 | 1422:
					FlxG.camera.flash(FlxColor.WHITE);
			}
		case 'vacation':
			switch (curStep)
			{
				case 0 | 32 | 64 | 96 | 128 | 176 | 192 | 208 | 240 | 256 | 272 | 352 | 384 | 432 | 448 | 464 | 480 | 496 | 512 | 528 | 560 | 576 | 592 | 608 | 624:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 16:
				    var curZoom = defaultCamZoom;
						var time = (Conductor.stepCrochet / 1000) * 16;
						FlxG.camera.fade(FlxColor.WHITE, time, false, function()
						{
							FlxG.camera.fade(FlxColor.WHITE, 0, true, function()
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							});
						});
						FlxTween.num(curZoom, curZoom + 0.4, time, {onComplete: function(tween:FlxTween)
						{
							defaultCamZoom = 0.7;
						}}, function(newValue:Float)
						{
							defaultCamZoom = newValue;
						});
			    case 160 | 288 | 416:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.8;
				case 224 | 320 | 544:
				    FlxG.camera.flash(FlxColor.WHITE);
					defaultCamZoom = 0.7;
			}
		case 'summer':
			switch (curStep)
			{
				case 16:
				    FlxG.camera.flash(FlxColor.WHITE);
				case 144 | 400 | 528 | 896 | 1024 | 1152:
				    defaultCamZoom = 0.78;
				case 272 | 432 | 560 | 928 | 1056 | 1184:
				    defaultCamZoom = 0.68;
					FlxG.camera.flash(FlxColor.WHITE);
				case 784:
				    defaultCamZoom = 0.78;
				    makeInvisibleNotes(true);
				case 796:
					subtitleManager.addSubtitle(LanguageManager.getTextString('summer_sub1'), 0.02, 1);
				case 807:
					subtitleManager.addSubtitle(LanguageManager.getTextString('summer_sub2'), 0.02, 1);
				case 830:
					subtitleManager.addSubtitle(LanguageManager.getTextString('summer_sub3'), 0.02, 0.6);
				case 838:
					subtitleManager.addSubtitle(LanguageManager.getTextString('summer_sub4'), 0.02, 0.2);
					makeInvisibleNotes(false);
				case 848:
				    defaultCamZoom = 0.68;
			}
		}
		if (shakeCam)
		{
			gf.playAnim('scared', true);
		}

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'pipebomb' | 'houseNight' | 'motocycle' | 'cookie-dough': // Dark character thing
                {
                    dad.color = 0xFF878787;
					gf.color = 0xFF878787;
                    boyfriend.color = 0xFF878787;
                }
			case 'jollytastic':
			    {
					boyfriend.color = 0xFFFF8FB2;
				    dad.color = 0xFFFF8FB2;
				    gf.color = 0xFFFF8FB2;
				}
			case 'funspookybattle': // Bf dark character thing
                {
                    boyfriend.color = 0xFF999999;
                }
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(ratingString == '?') {
		    scoreTxt.text =
			LanguageManager.getTextString('play_score') + songScore + " | " + 
			LanguageManager.getTextString('play_miss') + songMisses +  " | " + 
			LanguageManager.getTextString('play_accuracy') + '0%';
		} else {
			scoreTxt.text = 
			LanguageManager.getTextString('play_score') + songScore + " | " + 
			LanguageManager.getTextString('play_miss') + songMisses +  " | " + 
			LanguageManager.getTextString('play_accuracy') + ((Math.floor(ratingPercent * 10000) / 100)) + '%';
		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				if(FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						vocals.pause();
					}
					PauseSubState.transCamera = camOther;
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
				#end
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene)
		{
				switch (SONG.song.toLowerCase())
				{
					case 'probability':
						#if debug
						MusicBeatState.switchState(new ChartingState());
						#end
						PlayState.SONG = Song.loadFromJson("rage", "rage"); // you dun fucked up
						FlxG.save.data.probabilityFound = true;
						shakeCam = false;
						screenshader.Enabled = false;
						MusicBeatState.switchState(new PlayState());
						return;
					case 'rage':
						MusicBeatState.switchState(new CrasherState());
					case 'spin dashin':
						#if debug
						MusicBeatState.switchState(new ChartingState());
						#end
						PlayState.SONG = Song.loadFromJson("icsa3aahcmaj", "icsa3aahcmaj"); // you dun fucked up
						FlxG.save.data.spinFound = true;
						shakeCam = false;
						screenshader.Enabled = false;
						MusicBeatState.switchState(new PlayState());
						return;
					case 'agronomist v71961':
						#if debug
						MusicBeatState.switchState(new ChartingState());
						#end
						PlayState.SONG = Song.loadFromJson("agronomo", "agronomo"); // you dun fucked up
						FlxG.save.data.agronomoFound = true;
						shakeCam = false;
						screenshader.Enabled = false;
						MusicBeatState.switchState(new PlayState());
						return;
					default:
						persistentUpdate = false;
						paused = true;
						cancelFadeTween();
						CustomFadeTransition.nextCamera = camOther;
						shakeCam = false;
						screenshader.Enabled = false;
						MusicBeatState.switchState(new ChartingState());
						#if desktop
						DiscordClient.changePresence("Chart Editor", null, null, true);
						#end
				}
			}
		if (FlxG.keys.justPressed.F1 && !endingSong && !inCutscene)
			{
				persistentUpdate = false;
				paused = true;
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				MusicBeatState.switchState(new ChartingState());

				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		iconP1.centerOffsets();
		iconP2.centerOffsets();

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;
	
		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;
					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
					timeTxt.text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000) + " - " +FlxStringUtil.formatTime(FlxG.sound.music.length / 1000);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		#if SHADERS_ENABLED
		if (curSong.toLowerCase() == 'furiosity')
			{
				screenshader.shader.uampmul.value[0] = 0;
				screenshader.Enabled = false;
			}
		#end

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						if (daNote.isSustainNote) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if(daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if(daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else if(!daNote.noAnimation) {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
								altAnim = '-alt';
							}
						}

						if(dad.curCharacter == 'probability-bambi' || dad.curCharacter == 'rage-bambi' || dad.curCharacter == 'brandel-paint')
						{
							FlxG.camera.shake(0.0075, 0.1);
							camHUD.shake(0.0045, 0.1);
						}

						var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))];
						
						if(daNote.noteType == 'GF Sing') {
							gf.playAnim(animToPlay + altAnim, true);
							gf.holdTimer = 0;
						} else {
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
						}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	var isDead:Bool = false;
	function doDeathCheck() {
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				var deathSkinCheck = formoverride == "bf" || formoverride == "none" ? SONG.player1 : formoverride;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y, this));
				
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;
			
			case 'HUD Fade':
					var charType:Int = Std.parseInt(value1);
					if (Math.isNaN(charType))
						charType = 0;

					switch (charType)
					{
						case 0:
							FlxTween.tween(camHUD, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
						case 1:
							FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
					}
			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if(!boyfriend.alreadyLoaded) {
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							if(!dad.alreadyLoaded) {
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if(!gf.alreadyLoaded) {
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool) {
		if(isDad) {
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];

			camFollow.x += dadNoteCamOffset[0];
			camFollow.y += dadNoteCamOffset[1];

			bfNoteCamOffset[0] = 0;
			bfNoteCamOffset[1] = 0;
			tweenCamIn();
		} else {
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (SONG.song.toLowerCase())
			{
				case 'fnaf is real' | 'fancy' | 'motocycle' | 'carnivore' | 'style':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 160;
				case 'fun spooky battle':
					camFollow.x = boyfriend.getMidpoint().x - 320;
					camFollow.y = boyfriend.getMidpoint().y - 170;
				case 'p':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'dealings' | 'summer':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'falsify':
					camFollow.x = boyfriend.getMidpoint().x - 550;
				case 'mustard':
					camFollow.y = boyfriend.getMidpoint().y - 150;
				case 'cake':
				    camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'vacation':
				    camFollow.y = boyfriend.getMidpoint().y - 255;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			camFollow.x += bfNoteCamOffset[0];
			camFollow.y += bfNoteCamOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1) {
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween) {
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.0475;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
	
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

        /* scrapped for now
			switch (curSong.toLowerCase()) {
				case "maize":
					CharacterSelectState.unlockCharacter('bambi-player');
					CharacterSelectState.unlockCharacter('screwedbambi-player');
				case "probability":
					CharacterSelectState.unlockCharacter('playable-probabilitybambi');
				case "electronic":
					CharacterSelectState.unlockCharacter('bunda-player');
				case "motocycle":
					CharacterSelectState.unlockCharacter('plambi-player');
					CharacterSelectState.unlockCharacter('plambiangry-player');
					CharacterSelectState.unlockCharacter('leo-player');
				case "fancy":
					CharacterSelectState.unlockCharacter('gentleman-player');
					CharacterSelectState.unlockCharacter('bastard-player');
				case "pipebomb":
					CharacterSelectState.unlockCharacter('mailbamb-player');
					CharacterSelectState.unlockCharacter('zale-player');
				case "fnaf is real":
					CharacterSelectState.unlockCharacter('jon-player');
					CharacterSelectState.unlockCharacter('madjon-player');
					CharacterSelectState.unlockCharacter('niles-player');
				case "carnivore":
					CharacterSelectState.unlockCharacter('flombi-player');
					CharacterSelectState.unlockCharacter('plant-player');
				case "spin dashin":
					CharacterSelectState.unlockCharacter('bf-pixel');
					CharacterSelectState.unlockCharacter('speedu-player');
					CharacterSelectState.unlockCharacter('speeduexe-player');
					CharacterSelectState.unlockCharacter('miles-player');
					CharacterSelectState.unlockCharacter('puncher-player');
				case "agronomist":
					CharacterSelectState.unlockCharacter('agronomist-dave');
					CharacterSelectState.unlockCharacter('marcello-player');
				case "subversive":
					CharacterSelectState.unlockCharacter('ogbf');
					CharacterSelectState.unlockCharacter('futuredave-player');
					CharacterSelectState.unlockCharacter('angryfuturedave-player');
					CharacterSelectState.unlockCharacter('gottasleep20-player');
					CharacterSelectState.unlockCharacter('smartscientist-player');
					CharacterSelectState.unlockCharacter('monotor0-player');
					CharacterSelectState.unlockCharacter('daveson-player');
					CharacterSelectState.unlockCharacter('silverman-player');
					CharacterSelectState.unlockCharacter('sam-player');
				case "confrontation":
					CharacterSelectState.unlockCharacter('player-probability-bambi');
					CharacterSelectState.unlockCharacter('2dbunda-player');
				case "pooped":
					CharacterSelectState.unlockCharacter('poopina-player');
				case "asfalto":
					CharacterSelectState.unlockCharacter('bf-asnalto');
					CharacterSelectState.unlockCharacter('gnomo-player');
					CharacterSelectState.unlockCharacter('frog-player');
					CharacterSelectState.unlockCharacter('feet');
					CharacterSelectState.unlockCharacter('frogdave-player');
				case "tech":
					CharacterSelectState.unlockCharacter('tech-player');
					CharacterSelectState.unlockCharacter('bf-tech');
				case "insane corn":
					CharacterSelectState.unlockCharacter('dave-player');
					CharacterSelectState.unlockCharacter('dave3d-player');
					CharacterSelectState.unlockCharacter('bambi3d');
				case "falsify":
					CharacterSelectState.unlockCharacter('bmabii-player');
				case "trains":
					CharacterSelectState.unlockCharacter('thembo-player');
				case "cake":
					CharacterSelectState.unlockCharacter('baker-player');
				case "dangerous":
					CharacterSelectState.unlockCharacter('niles_dangerous');
				case "power":
					CharacterSelectState.unlockCharacter('tristan-player');
					CharacterSelectState.unlockCharacter('goldentristan-player');
				case "fun spooky battle":
					CharacterSelectState.unlockCharacter('pumpkintristan-player');
					CharacterSelectState.unlockCharacter('strawmandave-player');
					CharacterSelectState.unlockCharacter('pumpkinbambi-player');
				case "style":
					CharacterSelectState.unlockCharacter('gambo-player');
				case "summer":
					CharacterSelectState.unlockCharacter('samny-player');
				case "cookie dough":
					CharacterSelectState.unlockCharacter('crumbansu-player');
				case "vacation":
					CharacterSelectState.unlockCharacter('eba-player');
				case "lightning":
					CharacterSelectState.unlockCharacter('bambichu-player');
					CharacterSelectState.unlockCharacter('angrybambichu-player');
				case "mustard":
					CharacterSelectState.unlockCharacter('pempe-player');
				case "oblique":
					CharacterSelectState.unlockCharacter('blomquo-player');
				case "reminiscence":
					CharacterSelectState.unlockCharacter('vanderley-player');
					CharacterSelectState.unlockCharacter('vandley-player');
					CharacterSelectState.unlockCharacter('binefraft');
				case "dealings":
					CharacterSelectState.unlockCharacter('adopteddrugdealer-player');
				case "kawai!1!":
					CharacterSelectState.unlockCharacter('davekun-player');
					CharacterSelectState.unlockCharacter('bf_shit');
				case "p":
					CharacterSelectState.unlockCharacter('bf-pad');
					CharacterSelectState.unlockCharacter('pizzagod-player');
					CharacterSelectState.unlockCharacter('brandel-player');
					CharacterSelectState.unlockCharacter('pizzagodness-player');
				case "jollytastic!":
					CharacterSelectState.unlockCharacter('bf-christmas');
					CharacterSelectState.unlockCharacter('jollysamny-player');
					CharacterSelectState.unlockCharacter('jollyplambi-player');
				case "agronomist v71961":
					CharacterSelectState.unlockCharacter('damevy-player');
					CharacterSelectState.unlockCharacter('bombles');
					CharacterSelectState.unlockCharacter('ron-player');
					CharacterSelectState.unlockCharacter('bob');
				case "miss ass hold":
					CharacterSelectState.unlockCharacter('missasshold-player');
				case "123.12.1234.123":
					CharacterSelectState.unlockCharacter('playable-ipdave');
					CharacterSelectState.unlockCharacter('playable-ipbambiJoke');
					CharacterSelectState.unlockCharacter('playable-ipbambiSplit');
				case "deez nuts v2":
					CharacterSelectState.unlockCharacter('sapatinho');
					CharacterSelectState.unlockCharacter('robinson-player');
					CharacterSelectState.unlockCharacter('peppino-player');
					CharacterSelectState.unlockCharacter('baldi-player');
					CharacterSelectState.unlockCharacter('umus-player');
					CharacterSelectState.unlockCharacter('lauturninho-player');
				case "lore":
					CharacterSelectState.unlockCharacter('lorejon-player');
					CharacterSelectState.unlockCharacter('niles-lore');
				case "rage":
					CharacterSelectState.unlockCharacter('ragebambi-player');
				case "icsa3aahcmaj":
					CharacterSelectState.unlockCharacter('dave_plays');
				case "talkative":
					CharacterSelectState.unlockCharacter('davekuntalkative-player');
					CharacterSelectState.unlockCharacter('talkblomquo-player');
					CharacterSelectState.unlockCharacter('diamondmantalkative-player');
					CharacterSelectState.unlockCharacter('expungediscord-player');
					CharacterSelectState.unlockCharacter('parents-player');
				case "agronomo":
					CharacterSelectState.unlockCharacter('murilo-player');
					CharacterSelectState.unlockCharacter('gustavo.mpeg');
				case "untitled":
					CharacterSelectState.unlockCharacter('carafino-player');
					CharacterSelectState.unlockCharacter('spike');
					CharacterSelectState.unlockCharacter('cararock-player');
					CharacterSelectState.unlockCharacter('spike-rock');
					CharacterSelectState.unlockCharacter('sproya-player');
					CharacterSelectState.unlockCharacter('oldbambi-player');
					CharacterSelectState.unlockCharacter('bf_maize');
					CharacterSelectState.unlockCharacter('spkkkkbambi-player');
					CharacterSelectState.unlockCharacter('oldangryplambi-player');
					CharacterSelectState.unlockCharacter('oldspike');
					CharacterSelectState.unlockCharacter('rock-player');
					CharacterSelectState.unlockCharacter('bmabi-player');
					CharacterSelectState.unlockCharacter('untmarcello-player');
					CharacterSelectState.unlockCharacter('moldy');
					CharacterSelectState.unlockCharacter('jonparoxeie-player');
					CharacterSelectState.unlockCharacter('spongebob');
					CharacterSelectState.unlockCharacter('manbi-player');
					CharacterSelectState.unlockCharacter('countrybf');
					CharacterSelectState.unlockCharacter('sansinojr');
			}
		*/

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning)
        {
            if (SONG.validScore)
            {
                #if !switch
                var percent:Float = ratingPercent;
                if(Math.isNaN(percent)) percent = 0;
                Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
                #end
            }

            trace('WENT BACK TO FREEPLAY??');
            cancelFadeTween();
            CustomFadeTransition.nextCamera = camOther;
            if(FlxTransitionableState.skipNextTransIn) {
                CustomFadeTransition.nextCamera = null;
            }
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            usedPractice = false;
            changedDifficulty = false;
            cpuControlled = false;
            switch (SONG.song.toLowerCase())
            {
                case 'maize' | 'probability' | 'electronic' | 'motocycle' | 'fancy' | 'pipebomb' | 'carnivore' | 'spin dashin' | 'agronomist' | 'subversive':
                    MusicBeatState.switchState(new PlayMenuState());
                case 'fnaf is real':
                    MusicBeatState.switchState(new EndingState('fnafEnding', 'goodEnding'));
				default:
                    MusicBeatState.switchState(new FreeplayState());
            }
            transitioning = true;
        }
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			score = 200;
		}

		if(daRating == 'sick' && ClientPrefs.noteSplashes && note != null)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(splash);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			songHits++;
			RecalculateRating();
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 20;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(comboSpr);
		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong) {
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray.contains(true)) {
					for (i in 0...controlArray.length) {
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
							&& !daNote.wasGoodHit && daNote.noteData == i) {
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = false;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0) {
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes) {
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									} else
										notesStopped = true;
								}
									
								// eee jack detection before was not super good
								if (controlArray[epicNote.noteData] && !notesStopped) {
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);
								}

							}
						}
						else if (canMiss) 
							ghostMiss(controlArray[i], i, true);
						if (!keysPressed[i] && controlArray[i]) 
							keysPressed[i] = true;
					}
				}
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();

				bfNoteCamOffset[0] = 0;
				bfNoteCamOffset[1] = 0;
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if(controlReleaseArray[spr.ID]) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth; //For testing purposes
		trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}
		
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				if(ghostMiss) ghostMisses++;
				songMisses++;
			}
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function cameraMoveOnNote(note:Int, character:String)
	{
		var amount:Array<Float> = new Array<Float>();
		var followAmount:Float = FlxG.save.data.noteCamera ? 20 : 0;
		switch (note)
		{
			case 0:
				amount[0] = -followAmount;
				amount[1] = 0;
			case 1:
				amount[0] = 0;
				amount[1] = followAmount;
			case 2:
				amount[0] = 0;
				amount[1] = -followAmount;
			case 3:
				amount[0] = followAmount;
				amount[1] = 0;
		}
		switch (character)
		{
			case 'dad':
				dadNoteCamOffset = amount;
			case 'bf':
				bfNoteCamOffset = amount;
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				if (FlxG.save.data.donoteclick)
				{
					FlxG.sound.play(Paths.sound('note_click'));
				}
				combo += 1;
				if(combo > 9999) combo = 9999;
			}
			health += note.hitHealth;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
	            if(boyfriend.curCharacter == 'playable-probabilitybambi' || boyfriend.curCharacter == 'ragebambi-player' || boyfriend.curCharacter == 'player-probability-bambi' || dad.curCharacter == 'brandel-paint')
				{
					FlxG.camera.shake(0.0075, 0.1);
					camHUD.shake(0.0045, 0.1);
				}
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.noteType == 'GF Sing') {
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
				} else {
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function makeInvisibleNotes(invisible:Bool)
	{
		if (invisible)
		{
			for (strumNote in strumLineNotes)
			{
				FlxTween.cancelTweensOf(strumNote);
				FlxTween.tween(strumNote, {alpha: 0}, 1);
			}
		}
		else
		{
			for (strumNote in strumLineNotes)
			{
				FlxTween.cancelTweensOf(strumNote);
				FlxTween.tween(strumNote, {alpha: 1}, 1);
			}
		}
	}

	var startedMoving:Bool = false;

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		super.destroy();
	}

	public function cancelFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
			var funny:Float = (healthBar.percent * 0.01) + 0.01;

            if (curBeat % gfSpeed == 0) {
            curBeat % (gfSpeed * 2) == 0 ? {
            iconP1.scale.set(1.1, 0.8);
            iconP2.scale.set(1.1, 1.3);

            FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
            FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
            } : {
            iconP1.scale.set(1.1, 1.3);
            iconP2.scale.set(1.1, 0.8);

            FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
            FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
        }

            FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
            FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

            iconP1.updateHitbox();
            iconP2.updateHitbox();
            }
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'nome_indefinido':
				gb.dance(true);
				perk.dance(true);
				webby.dance(true);
				staticscr.dance(true);
			case 'summer':
			    awa.dance(true);
			case 'kawai':
                alice.dance(true);
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

			if(Math.isNaN(ratingPercent)) {
				ratingString = '?';
			} else if(ratingPercent >= 1) {
				ratingPercent = 1;
				ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			} else {
				for (i in 0...ratingStuff.length-1) {
					if(ratingPercent < ratingStuff[i][1]) {
						ratingString = ratingStuff[i][0];
						break;
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}
}
