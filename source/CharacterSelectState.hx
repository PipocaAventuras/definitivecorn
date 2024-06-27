package;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import Shaders.PulseEffect;

class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}

class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>)
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteMs = noteMs;
	}
}

class CharacterSelectState extends MusicBeatState
{
	public var current:Int = 0;
	public var currentReal:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;

	public static var screenshader:Shaders.PulseEffect = new PulseEffect();
	public var curbg:FlxSprite;

	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var currentSelectedCharacter:CharacterInSelect;

	var arrows:Array<FlxSprite> = [];

	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	public var char:Boyfriend;

	//it goes left,right,up,down
	
	public var characters:Array<CharacterInSelect> = 
	[
		new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-pixel', 'Pixel Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-christmas', 'Christmas Boyfriend', [1,1,1,1]),
			new CharacterForm('ogbf', 'OG Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-asnalto', 'Gnomo Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-tech', 'Tech Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-pad', 'Paint Boyfriend', [1,1,1,1]),
			new CharacterForm('binefraft', 'Boyfriend (Minecraft)', [1,1,1,1]),
			new CharacterForm('bf_shit', 'Boyfriend-Kun', [1,1,1,1]),
			new CharacterForm('sapatinho', 'Jake Baddle Sapatinho', [1,1,1,1]),
			new CharacterForm('bf_maize', 'Boyfriend (Unused)', [1,1,1,1]),
			new CharacterForm('countrybf', 'Country Boyfriend', [1,1,1,1])
		]),
        new CharacterInSelect('dave-player', [1, 1, 1, 1], [
			new CharacterForm('dave-player', 'Dave', [1,1,1,1]),
			new CharacterForm('dave3d-player', 'Dave (3D)', [1,1,1,1]),
			new CharacterForm('gnomo-player', 'Gnomo Dave', [1,1,1,1]),
			new CharacterForm('strawmandave-player', 'Strawman Dave', [1,1,1,1]),
			new CharacterForm('davekun-player', 'Dave-Kun', [1,1,1,1]),
			new CharacterForm('playable-ipdave', 'Dave (IP)', [1,1,1,1]),
			new CharacterForm('dave_plays', 'Dave Plays', [1,1,1,1]),
			new CharacterForm('davekuntalkative-player', 'Dave-Kun (Talkative)', [1,1,1,1])
		]),
		new CharacterInSelect('bambi-player', [1, 1, 1, 1], [
			new CharacterForm('bambi-player', 'Bambi', [1,1,1,1]),
			new CharacterForm('screwedbambi-player', 'Angry Bambi', [1,1,1,1]),
			new CharacterForm('playable-probabilitybambi', 'Probability Bambi', [1,1,1,1]),
			new CharacterForm('player-probability-bambi', 'Probability Bambi (2D)', [1,1,1,1]),
			new CharacterForm('bambi3d', 'Bambi (3D)', [1,1,1,1]),
			new CharacterForm('pumpkinbambi-player', 'Pumpkin Bambi', [1,1,1,1]),
			new CharacterForm('playable-ipbambiJoke', 'Bambi (IP)', [1,1,1,1]),
			new CharacterForm('playable-ipbambiSplit', 'Splitathon Bambi (IP)', [1,1,1,1]),
			new CharacterForm('ragebambi-player', 'Rage Bambi', [1,1,1,1]),
			new CharacterForm('parents-player', 'Bambi (Talkative)', [1,1,1,1]),
			new CharacterForm('oldbambi-player', 'Bambi (Old)', [1,1,1,1]),
			new CharacterForm('spkkkkbambi-player', 'Spike Bambi', [1,1,1,1])
		]),
		new CharacterInSelect('tristan-player', [1, 1, 1, 1], [
			new CharacterForm('tristan-player', 'Tristan', [1,1,1,1]),
			new CharacterForm('goldentristan-player', 'Golden Tristan', [1,1,1,1]),
			new CharacterForm('pumpkintristan-player', 'Pumpkin Tristan', [1,1,1,1])
		]),
		new CharacterInSelect('bunda-player', [1, 1, 1, 1], [
			new CharacterForm('bunda-player', 'Bunda', [1,1,1,1]),
			new CharacterForm('2dbunda-player', 'Bunda (2D)', [1,1,1,1])
		]),
		new CharacterInSelect('plambi-player', [1, 1, 1, 1], [
			new CharacterForm('plambi-player', 'Plambi', [1,1,1,1]),
			new CharacterForm('plambiangry-player', 'Angry Plambi', [1,1,1,1]),
			new CharacterForm('jollyplambi-player', 'Plambi (Jollytastic!)', [1,1,1,1]),
			new CharacterForm('oldangryplambi-player', 'Angry Plambi (Old)', [1,1,1,1])
		]),
		new CharacterInSelect('leo-player', [1, 1, 1, 1], [
			new CharacterForm('leo-player', 'Leo', [1,1,1,1])
		]),
		new CharacterInSelect('gentleman-player', [1, 1, 1, 1], [
			new CharacterForm('gentleman-player', 'Gentleman', [1,1,1,1]),
			new CharacterForm('bastard-player', 'Bastard', [1,1,1,1]),
			new CharacterForm('gentleman-phantasm', 'Gentleman (Phantasm)', [1,1,1,1]),
			new CharacterForm('bastard-phantasm', 'Bastard (Phantasm)', [1,1,1,1]),
			new CharacterForm('carafino-player', 'Fino', [1,1,1,1]),
			new CharacterForm('cararock-player', 'Rock', [1,1,1,1]),
			new CharacterForm('rock-player', 'Bastard (Old)', [1,1,1,1])
		]),
		new CharacterInSelect('mailbamb-player', [1, 1, 1, 1], [
			new CharacterForm('mailbamb-player', 'Mailbamb', [1,1,1,1])
		]),
		new CharacterInSelect('zale-player', [1, 1, 1, 1], [
			new CharacterForm('zale-player', 'Zale', [1,1,1,1])
		]),
        new CharacterInSelect('jon-player', [1, 1, 1, 1], [
			new CharacterForm('jon-player', 'Jon', [1,1,1,1]),
			new CharacterForm('madjon-player', 'Angry Jon', [1,1,1,1]),
			new CharacterForm('lorejon-player', 'Jon (Lore)', [1,1,1,1]),
			new CharacterForm('jonparoxeie-player', 'Jon Paroxeie', [1,1,1,1])
		]),
		new CharacterInSelect('niles-player', [1, 1, 1, 1], [
			new CharacterForm('niles-player', 'Niles', [1,1,1,1]),
			new CharacterForm('nilesdangerous-player', 'Niles with a Gun', [1,1,1,1]),
			new CharacterForm('niles-lore', 'Niles (Lore)', [1,1,1,1])
		]),
		new CharacterInSelect('flombi-player', [1, 1, 1, 1], [
			new CharacterForm('flombi-player', 'Flombi', [1,1,1,1]),
			new CharacterForm('plant-player', 'Flombi Carnivore Plant', [1,1,1,1])
		]),
		new CharacterInSelect('speedu-player', [1, 1, 1, 1], [
			new CharacterForm('speedu-player', 'Speedu', [1,1,1,1]),
			new CharacterForm('speeduexe-player', 'Speedu.exe', [1,1,1,1])
		]),
		new CharacterInSelect('miles-player', [1, 1, 1, 1], [
			new CharacterForm('miles-player', 'Miles', [1,1,1,1])
		]),
		new CharacterInSelect('puncher-player', [1, 1, 1, 1], [
			new CharacterForm('puncher-player', 'Puncher', [1,1,1,1])
		]),
		new CharacterInSelect('agronomist-dave', [1, 1, 1, 1], [
			new CharacterForm('agronomist-dave', 'OG Dave', [1,1,1,1]),
			new CharacterForm('futuredave-player', 'OG Future Dave', [1,1,1,1]),
			new CharacterForm('angryfuturedave-player', 'Angry OG Future Dave', [1,1,1,1])
		]),
		new CharacterInSelect('marcello-player', [1, 1, 1, 1], [
			new CharacterForm('marcello-player', 'Marcello', [1,1,1,1]),
			new CharacterForm('untmarcello-player', 'Marcello (Untitled)', [1,1,1,1])
		]),
		new CharacterInSelect('gottasleep20-player', [1, 1, 1, 1], [
			new CharacterForm('gottasleep20-player', 'Gotta Sleep 2.0', [1,1,1,1])
		]),
		new CharacterInSelect('smartscientist-player', [1, 1, 1, 1], [
			new CharacterForm('smartscientist-player', 'Smart Scientist', [1,1,1,1])
		]),
		new CharacterInSelect('monotor0-player', [1, 1, 1, 1], [
			new CharacterForm('monotor0-player', 'Monotor-0', [1,1,1,1])
		]),
        new CharacterInSelect('daveson-player', [1, 1, 1, 1], [
			new CharacterForm('daveson-player', 'Daveson', [1,1,1,1])
		]),
        new CharacterInSelect('silverman-player', [1, 1, 1, 1], [
			new CharacterForm('silverman-player', 'Silverman', [1,1,1,1])
		]),
		new CharacterInSelect('sam-player', [1, 1, 1, 1], [
			new CharacterForm('sam-player', 'Sam', [1,1,1,1])
		]),
		new CharacterInSelect('poopina-player', [1, 1, 1, 1], [
			new CharacterForm('poopina-player', 'Poopina', [1,1,1,1])
		]),
		new CharacterInSelect('frog-player', [1, 1, 1, 1], [
			new CharacterForm('frog-player', 'Frog', [1,1,1,1]),
		]),
		new CharacterInSelect('frogdave-player', [1, 1, 1, 1], [
			new CharacterForm('frogdave-player', 'Gnomo Dave and Frog', [1,1,1,1])
		]),
		new CharacterInSelect('feet', [1, 1, 1, 1], [
			new CharacterForm('feet', 'Foot', [1,1,1,1])
		]),
		new CharacterInSelect('tech-player', [1, 1, 1, 1], [
			new CharacterForm('tech-player', 'Tech Robot', [1,1,1,1])
		]),
		new CharacterInSelect('bmabii-player', [1, 1, 1, 1], [
			new CharacterForm('bmabii-player', 'Bmabii', [1,1,1,1])
		]),
		new CharacterInSelect('thembo-player', [1, 1, 1, 1], [
			new CharacterForm('thembo-player', 'Thembo', [1,1,1,1])
		]),
		new CharacterInSelect('baker-player', [1, 1, 1, 1], [
			new CharacterForm('baker-player', 'Baker', [1,1,1,1])
		]),
		new CharacterInSelect('gambo-player', [1, 1, 1, 1], [
			new CharacterForm('gambo-player', 'Gambo', [1,1,1,1])
		]),
		new CharacterInSelect('samny-player', [1, 1, 1, 1], [
			new CharacterForm('samny-player', 'Samny', [1,1,1,1]),
			new CharacterForm('jollysamny-player', 'Samny (Jollytastic!)', [1,1,1,1])
		]),
		new CharacterInSelect('crumbansu-player', [1, 1, 1, 1], [
			new CharacterForm('crumbansu-player', 'Crumbansu', [1,1,1,1])
		]),
		new CharacterInSelect('eba-player', [1, 1, 1, 1], [
			new CharacterForm('eba-player', 'Eba', [1,1,1,1])
		]),
		new CharacterInSelect('bambichu-player', [1, 1, 1, 1], [
			new CharacterForm('bambichu-player', 'Bambichu', [1,1,1,1]),
			new CharacterForm('angrybambichu-player', 'Bambichu (Angry)', [1,1,1,1])
		]),
		new CharacterInSelect('pempe-player', [1, 1, 1, 1], [
			new CharacterForm('pempe-player', 'Pempe', [1,1,1,1])
		]),
		new CharacterInSelect('blomquo-player', [1, 1, 1, 1], [
			new CharacterForm('blomquo-player', 'Blomquo', [1,1,1,1]),
			new CharacterForm('talkblomquo-player', 'Blomquo (Talkative)', [1,1,1,1])
		]),
		new CharacterInSelect('vanderley-player', [1, 1, 1, 1], [
			new CharacterForm('vanderley-player', 'Vanderley', [1,1,1,1]),
			new CharacterForm('vandley-player', 'Vanderley (Minecraft)', [1,1,1,1])
		]),
		new CharacterInSelect('adopteddrugdealer-player', [1, 1, 1, 1], [
			new CharacterForm('adopteddrugdealer-player', 'Adopted Drug Dealer', [1,1,1,1])
		]),
		new CharacterInSelect('pizzagod-player', [1, 1, 1, 1], [
			new CharacterForm('pizzagod-player', 'Pizza God', [1,1,1,1]),
			new CharacterForm('pizzagodness-player', 'Angry Pizza God', [1,1,1,1])
		]),
		new CharacterInSelect('brandel-player', [1, 1, 1, 1], [
			new CharacterForm('brandel-player', 'Brandel', [1,1,1,1])
		]),
		new CharacterInSelect('damevy-player', [1, 1, 1, 1], [
			new CharacterForm('damevy-player', 'Danevy', [1,1,1,1]),
			new CharacterForm('ron-player', 'Ron', [1,1,1,1])
		]),
		new CharacterInSelect('bombles', [1, 1, 1, 1], [
			new CharacterForm('bombles', 'Bombles', [1,1,1,1]),
			new CharacterForm('bob', 'Bob', [1,1,1,1])
		]),
		new CharacterInSelect('missasshold-player', [1, 1, 1, 1], [
			new CharacterForm('missasshold-player', 'MISS ASS HOLD', [1,1,1,1])
		]),
		new CharacterInSelect('robinson-player', [1, 1, 1, 1], [
			new CharacterForm('robinson-player', 'Robin', [1,1,1,1])
		]),
		new CharacterInSelect('peppino-player', [1, 1, 1, 1], [
			new CharacterForm('peppino-player', 'Peppino', [1,1,1,1])
		]),
		new CharacterInSelect('baldi-player', [1, 1, 1, 1], [
			new CharacterForm('baldi-player', 'Baldi (Deez Nuts)', [1,1,1,1])
		]),
		new CharacterInSelect('umus-player', [1, 1, 1, 1], [
			new CharacterForm('umus-player', 'Umus', [1,1,1,1])
		]),
		new CharacterInSelect('lauturninho-player', [1, 1, 1, 1], [
			new CharacterForm('lauturninho-player', 'Lauturninho', [1,1,1,1])
		]),
		new CharacterInSelect('diamondmantalkative-player', [1, 1, 1, 1], [
			new CharacterForm('diamondmantalkative-player', 'Diamond Man (Talkative)', [1,1,1,1])
		]),
		new CharacterInSelect('expungediscord-player', [1, 1, 1, 1], [
			new CharacterForm('expungediscord-player', 'Expunged (Talkative)', [1,1,1,1])
		]),
		new CharacterInSelect('murilo-player', [1, 1, 1, 1], [
			new CharacterForm('murilo-player', 'Murilo', [1,1,1,1])
		]),
		new CharacterInSelect('gustavo.mpeg', [1, 1, 1, 1], [
			new CharacterForm('gustavo.mpeg', 'Denubil', [1,1,1,1])
		]),
		new CharacterInSelect('spike', [1, 1, 1, 1], [
			new CharacterForm('spike', 'Spike', [1,1,1,1]),
			new CharacterForm('spike-rock', 'Spike (Rock)', [1,1,1,1]),
			new CharacterForm('oldspike', 'Spike (Old)', [1,1,1,1])
		]),
		new CharacterInSelect('sproya-player', [1, 1, 1, 1], [
			new CharacterForm('sproya-player', 'Sproya', [1,1,1,1])
		]),
		new CharacterInSelect('bmabi-player', [1, 1, 1, 1], [
			new CharacterForm('bmabi-player', 'Bmabi', [1,1,1,1])
		]),
		new CharacterInSelect('moldy', [1, 1, 1, 1], [
			new CharacterForm('moldy', 'Moldy', [1,1,1,1])
		]),
		new CharacterInSelect('spongebob', [1, 1, 1, 1], [
			new CharacterForm('spongebob', 'SpongeBob', [1,1,1,1])
		]),
		new CharacterInSelect('manbi-player', [1, 1, 1, 1], [
			new CharacterForm('manbi-player', 'Manbi', [1,1,1,1])
		]),
		new CharacterInSelect('sansinojr', [1, 1, 1, 1], [
			new CharacterForm('sansinojr', 'Sansino Junior', [1,1,1,1])
		])
	];
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		Conductor.changeBPM(175);

		FlxG.save.data.characterSelect = true;

		FlxG.cameras.reset(camGame);

		if (FlxG.save.data.charactersUnlocked == null)
		{
			reset();
		}
		currentSelectedCharacter = characters[current];

		#if debug
		if (FlxG.keys.justPressed.SEVEN)
		{
			for (character in characters)
			{
				for (form in character.forms)
				{
					unlockCharacter(form.name); // unlock everyone
				}
			}
		}
		#end

		var end:FlxSprite = new FlxSprite(0, 0);
		FlxG.sound.playMusic(Paths.music("characterSelect"),1,true);
		add(end);
		
		screenshader.waveAmplitude = 1;
		screenshader.waveFrequency = 2;
		screenshader.waveSpeed = 1;
		screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);

		var bg:BGSprite = new BGSprite('p_bg1', -300, -200, 0.9, 0.9);
		bg.setGraphicSize(Std.int(bg.width * 1.15), Std.int(bg.height * 1.15));
		add(bg);

		//create character
		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, "bf");
		char.screenCenter();
		char.y = 300;
		add(char);

		FlxG.camera.zoom = 0.7;
		
		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - -600, "Boyfriend");
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 7;
		characterText.screenCenter(X);
		add(characterText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.sprTracker = characterText;
		funnyIconMan.visible = false;
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(500, -50).loadGraphic(Paths.image('charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.5));
		tutorialThing.antialiasing = true;
		add(tutorialThing);

		var arrowLeft:FlxSprite = new FlxSprite(10,300).loadGraphic(Paths.image("ArrowLeft_Idle", "preload"));
		arrowLeft.antialiasing = true;
		arrowLeft.scrollFactor.set();
		arrows[0] = arrowLeft;
		add(arrowLeft);

		var arrowRight:FlxSprite = new FlxSprite(-5,300).loadGraphic(Paths.image("ArrowRight_Idle", "preload"));
		arrowRight.antialiasing = true;
		arrowRight.x = 1280 - arrowRight.width - 5;
		arrowRight.scrollFactor.set();
		arrows[1] = arrowRight;
		add(arrowRight);
	}

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		//FlxG.camera.focusOn(FlxG.ce);

		if (curbg != null)
			{
				if (curbg.active)
				{
					var shad = cast(curbg.shader, Shaders.GlitchShader);
					shad.uTime.value[0] += elapsed;
				}
			}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if(controls.UI_LEFT_P && !PressedTheFunny)
		{
			if(!char.nativelyPlayable)
			{
				char.playAnim('singRIGHT', true);
			}
			else
			{
				char.playAnim('singLEFT', true);
			}

		}
		if(controls.UI_RIGHT_P && !PressedTheFunny)
		{
			if(!char.nativelyPlayable)
			{
				char.playAnim('singLEFT', true);
			}
			else
			{
				char.playAnim('singRIGHT', true);
			}
		}
		if(controls.UI_UP_P && !PressedTheFunny)
		{
			char.playAnim('singUP', true);
		}
		if(controls.UI_DOWN_P && !PressedTheFunny)
		{
			char.playAnim('singDOWN', true);
		}
		if (controls.ACCEPT)
		{
			if (isLocked(characters[current].forms[curForm].name))
				{
					FlxG.camera.shake(0.05, 0.1);
					FlxG.sound.play(Paths.sound('badnoise1'), 0.9);
					return;
				}
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null; 
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('characterSelectEnd'));
			new FlxTimer().start(1.9, endIt);
		}
		if (FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[0].loadGraphic(Paths.image("ArrowLeft_Pressed", "preload"));
		}

		if (FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[1].loadGraphic(Paths.image("ArrowRight_Pressed", "preload"));
		}
		if (FlxG.keys.justReleased.LEFT)
			arrows[0].loadGraphic(Paths.image("ArrowLeft_Idle", "preload"));
		if (FlxG.keys.justReleased.RIGHT)
			arrows[1].loadGraphic(Paths.image("ArrowRight_Idle", "preload"));
		if (FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
	}

	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
			FlxG.save.flush();
		}
	}
	public static function isLocked(character:String):Bool
	{
		return !FlxG.save.data.charactersUnlocked.contains(character);
	}
	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		unlockCharacter('bf');
        unlockCharacter('bambi-player');
	    unlockCharacter('screwedbambi-player');
	    unlockCharacter('playable-probabilitybambi');
		unlockCharacter('bunda-player');
		unlockCharacter('plambi-player');
		unlockCharacter('plambiangry-player');
		unlockCharacter('leo-player');
		unlockCharacter('gentleman-player');
		unlockCharacter('bastard-player');
		unlockCharacter('mailbamb-player');
		unlockCharacter('zale-player');
		unlockCharacter('jon-player');
		unlockCharacter('madjon-player');
		unlockCharacter('niles-player');
		unlockCharacter('flombi-player');
		unlockCharacter('plant-player');
		unlockCharacter('bf-pixel');
		unlockCharacter('speedu-player');
		unlockCharacter('speeduexe-player');
		unlockCharacter('miles-player');
		unlockCharacter('puncher-player');
		unlockCharacter('agronomist-dave');
		unlockCharacter('marcello-player');
		unlockCharacter('ogbf');
		unlockCharacter('futuredave-player');
		unlockCharacter('angryfuturedave-player');
		unlockCharacter('gottasleep20-player');
		unlockCharacter('smartscientist-player');
		unlockCharacter('monotor0-player');
		unlockCharacter('daveson-player');
		unlockCharacter('silverman-player');
		unlockCharacter('sam-player');
		unlockCharacter('player-probability-bambi');
		unlockCharacter('2dbunda-player');
		unlockCharacter('poopina-player');
		unlockCharacter('bf-asnalto');
		unlockCharacter('gnomo-player');
		unlockCharacter('frog-player');
		unlockCharacter('feet');
		unlockCharacter('frogdave-player');
		unlockCharacter('tech-player');
		unlockCharacter('bf-tech');
		unlockCharacter('dave-player');
		unlockCharacter('dave3d-player');
		unlockCharacter('bambi3d');
		unlockCharacter('bmabii-player');
		unlockCharacter('thembo-player');
		unlockCharacter('baker-player');
		unlockCharacter('nilesdangerous-player');
		unlockCharacter('tristan-player');
		unlockCharacter('goldentristan-player');
		unlockCharacter('pumpkintristan-player');
		unlockCharacter('strawmandave-player');
		unlockCharacter('pumpkinbambi-player');
		unlockCharacter('gambo-player');
		unlockCharacter('samny-player');
		unlockCharacter('crumbansu-player');
		unlockCharacter('eba-player');
		unlockCharacter('bambichu-player');
		unlockCharacter('angrybambichu-player');
		unlockCharacter('pempe-player');
		unlockCharacter('blomquo-player');
		unlockCharacter('vanderley-player');
		unlockCharacter('vandley-player');
		unlockCharacter('binefraft');
		unlockCharacter('adopteddrugdealer-player');
		unlockCharacter('davekun-player');
		unlockCharacter('bf_shit');
		unlockCharacter('bf-pad');
		unlockCharacter('pizzagod-player');
		unlockCharacter('brandel-player');
		unlockCharacter('pizzagodness-player');
		unlockCharacter('bf-christmas');
		unlockCharacter('jollysamny-player');
		unlockCharacter('jollyplambi-player');
		unlockCharacter('damevy-player');
		unlockCharacter('bombles');
		unlockCharacter('ron-player');
		unlockCharacter('bob');
		unlockCharacter('missasshold-player');
		unlockCharacter('playable-ipdave');
		unlockCharacter('playable-ipbambiJoke');
		unlockCharacter('playable-ipbambiSplit');
		unlockCharacter('sapatinho');
		unlockCharacter('robinson-player');
		unlockCharacter('peppino-player');
		unlockCharacter('baldi-player');
		unlockCharacter('umus-player');
		unlockCharacter('lauturninho-player');
		unlockCharacter('gentleman-phantasm');
		unlockCharacter('bastard-phantasm');
		unlockCharacter('lorejon-player');
		unlockCharacter('niles-lore');

		if (FlxG.save.data.probabilityFound)
		{
			unlockCharacter('ragebambi-player');
		}

		if (FlxG.save.data.spinFound)
		{
			unlockCharacter('dave_plays');
		}

		if (FlxG.save.data.agronomoFound)
		{
		    unlockCharacter('murilo-player');
			unlockCharacter('gustavo.mpeg');
		}

		if (FlxG.save.data.missassholdFound)
		{
			unlockCharacter('davekuntalkative-player');
			unlockCharacter('talkblomquo-player');
			unlockCharacter('diamondmantalkative-player');
		    unlockCharacter('expungediscord-player');
			unlockCharacter('parents-player');
		}

		if (FlxG.save.data.fancyFound)
		{
			unlockCharacter('carafino-player');
			unlockCharacter('spike');
		    unlockCharacter('cararock-player');
			unlockCharacter('spike-rock');
			unlockCharacter('sproya-player');
			unlockCharacter('oldbambi-player');
			unlockCharacter('bf_maize');
			unlockCharacter('spkkkkbambi-player');
			unlockCharacter('oldangryplambi-player');
			unlockCharacter('oldspike');
			unlockCharacter('rock-player');
			unlockCharacter('bmabi-player');
		    unlockCharacter('untmarcello-player');
			unlockCharacter('moldy');
			unlockCharacter('jonparoxeie-player');
		    unlockCharacter('spongebob');
			unlockCharacter('manbi-player');
			unlockCharacter('countrybf');
			unlockCharacter('sansinojr');
		}

		FlxG.save.flush();
	}
	public function UpdateBF()
	{
		funnyIconMan.color = FlxColor.WHITE;
		currentSelectedCharacter = characters[current];
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 7;
		characterText.screenCenter(X);
		char.destroy();
		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, currentSelectedCharacter.forms[curForm].name);
		char.screenCenter();
		char.y = 300;
		switch (char.curCharacter)
		{
			case 'bf-pixel':
			    char.y = 400;
				char.x = 600;
			case 'bf-asnalto':
				char.y = 50;
				char.x = -550;
			case 'ogbf':
				char.y = 100;
				char.x = 100;
			case 'bf-tech' | 'playable-ipdave' | 'lorejon-player' | 'niles-lore':
				char.y = 200;
			case 'bf_shit':
				char.y = 200;
				char.x = 400;
			case 'bf-pad':
				char.y = 400;
				char.x = 500;
			case 'binefraft':
				char.y = 200;
				char.x = 400;
			case 'bambi-player' | 'screwedbambi-player':
			    char.y = 350;
			case 'playable-probabilitybambi':
			    char.y = -200;
				char.x = 250;
			case 'ragebambi-player':
			    char.y = -450;
				char.x = -50;
			case 'player-probability-bambi':
			    char.x = 400;
				char.y = 150;
			case 'bambi3d':
			    char.x = 300;
			case 'playable-ipbambiJoke':
			    char.x = 400;
				char.y = 250;
			case 'playable-ipbambiSplit':
                char.x = 450;
				char.y = 250;
			case 'dave-player':
				char.y = 100;
			case 'dave3d-player':
			    char.y = -100;
			case 'strawmandave-player':
			    char.y = 0;
			case 'gnomo-player' | 'spkkkkbambi-player' | 'pumpkinbambi-player':
			    char.y = 400;
			case 'davekuntalkative-player':
			    char.y = 450;
				char.x = 550;
			case 'parents-player':
				char.x = 600;
				char.y = 400;
			case 'davekun-player' | 'dave_plays':
			    char.y = 100;
			case "tristan-player" | 'goldentristan-player':
				char.y = 250;
			case 'pumpkintristan-player':
			    char.y = 150;
			case "bunda-player":
			    char.y = 50;
				char.x = 480;
			case '2dbunda-player':
			    char.y = 200;
				char.x = 530;
			case 'plambi-player':
			    char.y = -50;
			case 'jollyplambi-player':
			    char.y = 0;
				char.x = 50;
			case 'plambiangry-player' | 'gentleman-phantasm':
			    char.y = -50;
				char.x = 50;
			case 'oldangryplambi-player':
			    char.y = -200;
				char.x = -250;
			case "leo-player":
			    char.y = -250;
				char.x = -180;
			case 'gentleman-player':
			    char.y = 0;
				char.x = -50;
			case 'bastard-player':
				char.y = 0;
				char.x = 0;
			case 'bastard-phantasm':
			    char.y = -200;
				char.x = 0;
			case 'carafino-player':
			    char.y = 0;
			    char.x = 300;
			case 'cararock-player':
			    char.y = -50;
			    char.x = 450;
			case 'rock-player':
			    char.y = -350;
			    char.x = -125;
			case "mailbamb-player":
			    char.y = 225;
				char.x = 500;
			case "zale-player":
				char.y = 150;
			    char.x = 500;
			case 'jon-player' | 'madjon-player':
			    char.y = -450;
				char.x = -375;
			case 'jonparoxeie-player':
			    char.y = 0;
			case 'niles-player' | 'nilesdangerous-player':
				char.y = 380;
			case 'flombi-player' | 'plant-player':
				char.y = 0;
				char.x = 300;
			case 'speedu-player':
				char.x = 500;
				char.y = 400;
			case 'speeduexe-player':
			    char.y = 400;
				char.x = 550;
			case 'miles-player' | 'smartscientist-player':
			    char.x = 500;
			case 'puncher-player':
			    char.y = 350;
				char.x = 600;
			case 'agronomist-dave':
			    char.y = 100;
				char.x = 450;
			case 'futuredave-player' | 'angryfuturedave-player':
			    char.y = -50;
				char.x = 400;
			case 'untmarcello-player':
				char.x = 725;
				char.y = 200;
		    case 'gottasleep20-player':
			    char.x = 600;
			case 'monotor0-player':
			    char.y = 100;
				char.x = 600;
			case 'daveson-player':
			    char.y = 100;
				char.x = 650;
			case 'silverman-player':
			    char.y = 100;
				char.x = 150;
			case 'sam-player':
			    char.y = 400;
				char.x = 550;
		}
		add(char);
		funnyIconMan.animation.play(char.curCharacter);
		if (isLocked(characters[current].forms[curForm].name))
			{
				char.color = FlxColor.BLACK;
				funnyIconMan.color = FlxColor.BLACK;
				funnyIconMan.animation.curAnim.curFrame = 1;
				characterText.text = '???';
			}
		characterText.screenCenter(X);
	}

	override function beatHit()
	{
		super.beatHit();
		if (char != null && !selectedCharacter)
		{
			char.playAnim('idle');
		}
	}
	
	public function endIt(e:FlxTimer = null)
	{
		trace("ENDING");
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;
		PlayState.curmult = currentSelectedCharacter.forms[curForm].noteMs;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	
}