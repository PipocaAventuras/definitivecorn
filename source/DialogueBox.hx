package;

import flixel.math.FlxPoint;
#if windows
import openfl.display.Shader;
#end
import flixel.tweens.FlxTween;
import haxe.Log;
import flixel.input.gamepad.lists.FlxBaseGamepadList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var skipText:FlxText;

	var blackScreen:FlxSprite;

	var curCharacter:String = '';
	var curExpression:String = '';
	var curMod:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bfPortraitSizeMultiplier:Float = 1.5;
	var textBoxSizeFix:Float = 7;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var debug:Bool = false;

	#if windows
	var curshader:Dynamic;
	#end

	public static var randomNumber:Int;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'maize':
			    FlxG.sound.playMusic(Paths.music('dialogue/MaizeDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'probability':
			    FlxG.sound.playMusic(Paths.music('dialogue/ProbabilityDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'electronic':
			    FlxG.sound.playMusic(Paths.music('dialogue/ElectronicDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'motocycle':
			    FlxG.sound.playMusic(Paths.music('dialogue/MotocycleDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'fancy':
			    FlxG.sound.playMusic(Paths.music('dialogue/FancyDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'pipebomb':
			    FlxG.sound.playMusic(Paths.music('dialogue/PipebombDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'carnivore':
			    FlxG.sound.playMusic(Paths.music('dialogue/CarnivoreDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'fnaf is real':
			    FlxG.sound.playMusic(Paths.music('dialogue/FnafIsRealDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'subversive':
			    FlxG.sound.playMusic(Paths.music('dialogue/SubversiveDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		FlxTween.tween(bgFade, {alpha: 0.7}, 4.15);

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				box = new FlxSprite(-20, 400);
		}

		blackScreen = new FlxSprite(0, 0).makeGraphic(5000, 5000, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 0;
		add(blackScreen);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble');
				box.setGraphicSize(Std.int(box.width / textBoxSizeFix));
				box.updateHitbox();
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
				box.antialiasing = true;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		var portraitLeftCharacter:String = 'generic';
		var portraitRightCharacter:String = 'bf';

		portraitLeft = new FlxSprite();
		portraitRight = new FlxSprite();

		switch (PlayState.SONG.song.toLowerCase())
		{	
			case 'maize' | 'probability':
				portraitLeftCharacter = 'bambi';
			case 'electronic':
				portraitRightCharacter = 'gf';
				portraitLeftCharacter = 'bunda';
			case 'motocycle':
				portraitLeftCharacter = 'plambi';
			case 'fancy':
				portraitRightCharacter = 'gf';
				portraitLeftCharacter = 'gentleman';
			case 'pipebomb':
				portraitLeftCharacter = 'generic';
			case 'fnaf is real':
				portraitLeftCharacter = 'jon';
			case 'carnivore':
				portraitLeftCharacter = 'flombi';
			case 'subversive':
				portraitLeftCharacter = 'futuredave';
		}

		var leftPortrait:Portrait = getPortrait(portraitLeftCharacter);
		var rightPortrait:Portrait = getPortrait(portraitRightCharacter);

		portraitLeft.frames = Paths.getSparrowAtlas(leftPortrait.portraitPath);
		portraitLeft.animation.addByPrefix('enter', leftPortrait.portraitPrefix, 24, false);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();

		portraitRight.frames = Paths.getSparrowAtlas(rightPortrait.portraitPath);
		portraitRight.animation.addByPrefix('enter', rightPortrait.portraitPrefix, 24, false);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		
		portraitRight.visible = false;
		portraitLeft.visible = false;
		portraitRight.visible = false;

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				portraitLeft.setPosition(276.95, 170);
				portraitLeft.visible = true;
				portraitRight.setPosition(276.95, 170);
				portraitRight.visible = true;
		}
		add(portraitLeft);
		add(portraitRight);

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
				dropText.font = 'Comic Sans MS Bold';
				dropText.color = 0xFF00137F;
				add(dropText);

				skipText = new FlxText(880, 690, Std.int(FlxG.width * 0.6), LanguageManager.getTextString("dialogue_skip"), 18);
				skipText.scrollFactor.set(0, 0);
				skipText.borderSize = 1.5;
				skipText.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(skipText);
		
				swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
				swagDialogue.font = 'Comic Sans MS Bold';
				swagDialogue.color = 0xFF000000;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
				add(swagDialogue);
		}
		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		#if windows
		if (curshader != null)
		{
			curshader.shader.uTime.value[0] += elapsed;
		}
		#end

		dropText.text = swagDialogue.text;
		switch (curCharacter)
		{
			case 'bambi':
				swagDialogue.sounds = [FlxG.sound.load(Paths.soundRandom('dialogue/bambDialogue', 1, 3), 0.6)];
			case 'pbbambi':
				swagDialogue.sounds = [FlxG.sound.load(Paths.soundRandom('dialogue/bambDialogue', 1, 3), 0.6)];
			case 'bunda':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bundaDialogue'), 0.6)];	
			case 'plambi':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/plambiDialogue'), 0.6)];	
			case 'gentleman':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gentlemanDialogue'), 0.6)];
			case 'mailbamb':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/mailbambDialogue'), 0.6)];	
			case 'flombi':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/flombiDialogue'), 0.6)];		
			case 'jon' | 'madjon':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/jonDialogue'), 0.6)];
			case 'futuredave' | 'angryfuturedave':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/futuredaveDialogue'), 0.6)];
			case 'bf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bfDialogue'), 0.6)];		
			case 'gf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gfDialogue'), 0.6)];
			case 'gerenic':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		}

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(FlxG.keys.justPressed.SPACE && !isEnding){
			isEnding = true;
			endDialogue();
		}

		if (FlxG.keys.justPressed.ENTER && dialogueStarted && !isEnding)
		{
			remove(dialogue);
			
			switch (PlayState.SONG.song.toLowerCase())
			{
				default:
					FlxG.sound.play(Paths.sound('dialogueClose'), 0.8);
			}

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;	
					endDialogue();
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function endDialogue()
	{
	    FlxG.sound.music.fadeOut(2.2, 0);

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
			FlxTween.tween(box, {alpha: 0}, 1.2);
			FlxTween.tween(bgFade, {alpha: 0}, 1.2);
			FlxTween.tween(portraitLeft, {alpha: 0}, 1.2);
			FlxTween.tween(portraitRight, {alpha: 0}, 1.2);
			FlxTween.tween(swagDialogue, {alpha: 0}, 1.2);
			FlxTween.tween(dropText, {alpha: 0}, 1.2);
			FlxTween.tween(skipText, {alpha: 0}, 1.2);
		}

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			finishThing();
			kill();
		});
	}

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		#if windows
		curshader = null;
		#end
		if (curCharacter != 'generic')
		{
			var portrait:Portrait = getPortrait(curCharacter);
			if (portrait.left)
			{
				portraitLeft.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitLeft.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();

				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
				}
			}
			else
			{
				portraitRight.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitRight.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();

				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
				}
			}
			switch (curCharacter)
			{
				case 'bambi':
						portraitLeft.setPosition(330, 215);
				case 'pbbambi':
						portraitLeft.setPosition(200, 50);
				case 'bunda':
						portraitLeft.setPosition(160, 130);
				case 'flombi':
						portraitLeft.setPosition(260, 85);
				case 'madjon':
				        portraitLeft.setPosition(240, 150);
				case 'jon' | 'futuredave' | 'angryfuturedave':
						portraitLeft.setPosition(300, 150);
				case 'gentleman':
						portraitLeft.setPosition(300, 100);
				case 'plambi':
						portraitLeft.setPosition(150, 100);
				case 'mailbamb':
						portraitLeft.setPosition(300, 180);
				case 'bf' | 'gf': //create boyfriend & genderbent boyfriend
					portraitRight.setPosition(570, 220);
			}
			box.flipX = portraitLeft.visible;
			portraitLeft.x -= 150;
			//portraitRight.x += 100;
			portraitLeft.antialiasing = true;
			portraitRight.antialiasing = true;
			portraitLeft.animation.play('enter',true);
			portraitRight.animation.play('enter',true);
		}
		else
		{
			portraitLeft.visible = false;
			portraitRight.visible = false;
		}
		switch (curMod)
		{
			case 'setfont_normal':
				dropText.font = 'Comic Sans MS Bold';
				swagDialogue.font = 'Comic Sans MS Bold';
			case 'to_black':
				FlxTween.tween(blackScreen, {alpha:1}, 0.25);
		}
    }
	function getPortrait(character:String):Portrait
	{
		var portrait:Portrait = new Portrait('', '', '', true);
		switch (character)
		{
			case 'bambi':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'maize':
						portrait.portraitPath = 'dialogue/BAMBI_Dialogue';
						portrait.portraitPrefix = 'bambi maize portrait';
					case 'probability':
						portrait.portraitPath = 'dialogue/PROBABILITYBAMBI_Dialogue';
						portrait.portraitPrefix = 'bambi probability portrait';
				}
			case 'pbbambi':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'probability':
						portrait.portraitPath = 'dialogue/PROBABILITYBAMBI_Dialogue';
						portrait.portraitPrefix = 'bambi probability portrait';
				}
			case 'bunda':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'electronic':
						portrait.portraitPath = 'dialogue/BUNDA_Dialogue';
						portrait.portraitPrefix = 'bunda electronic portrait';
				}
			case 'plambi':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'motocycle':
						portrait.portraitPath = 'dialogue/PLAMBI_Dialogue';
						portrait.portraitPrefix = 'plambi motocycle portrait';
				}
			case 'jon':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'fnaf is real':
						portrait.portraitPath = 'dialogue/JON_Dialogue';
						portrait.portraitPrefix = 'jon fnaf is real portrait';
				}
			case 'madjon':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'fnaf is real':
						portrait.portraitPath = 'dialogue/JON_Dialogue';
						portrait.portraitPrefix = 'mad jon fnaf is real portrait';
				}
			case 'futuredave':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'subversive':
						portrait.portraitPath = 'dialogue/FUTUREDAVE_Dialogue';
						portrait.portraitPrefix = 'future dave subversive portrait';
				}
			case 'angryfuturedave':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'subversive':
						portrait.portraitPath = 'dialogue/FUTUREDAVE_Dialogue';
						portrait.portraitPrefix = 'angry future dave subversive portrait';
				}
			case 'gentleman':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'fancy':
						portrait.portraitPath = 'dialogue/FANCY_Dialogue';
						portrait.portraitPrefix = 'gentleman fancy portrait';
				}
			case 'flombi':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'carnivore':
						portrait.portraitPath = 'dialogue/FLOMBI_Dialogue';
						portrait.portraitPrefix = 'flombi carnivore portrait';
				}
			case 'mailbamb':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'pipebomb':
						portrait.portraitPath = 'dialogue/MAILBAMB_Dialogue';
						portrait.portraitPrefix = 'mailbamb pipebomb portrait';
				}
			case 'bf':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'maize':
						portrait.portraitPath = 'dialogue/BF_Dialogue';
						portrait.portraitPrefix = 'bf furiosity & corntheft portrait';
					case 'carnivore' | 'fnaf is real':
						portrait.portraitPath = 'dialogue/BF_Dialogue';
						portrait.portraitPrefix = 'bf house portrait';
					case 'probability' | 'electronic' | 'motocycle' | 'fancy' | 'pipebomb':
						portrait.portraitPath = 'dialogue/BF_Dialogue';
						portrait.portraitPrefix = 'bf insanity & splitathon portrait';
					case 'subversive':
					    portrait.portraitPath = 'dialogue/OGBF_Dialogue';
						portrait.portraitPrefix = 'og bf subversive portrait';
				}
				portrait.left = false;
			case 'gf':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'maize' | 'electronic':
						portrait.portraitPath = 'dialogue/GF_Dialogue';
						portrait.portraitPrefix = 'gf corntheft portrait';
					case 'motocycle':
						portrait.portraitPath = 'dialogue/GF_Dialogue';
						portrait.portraitPrefix = 'gf maze portrait';
					case 'probability':
						portrait.portraitPath = 'dialogue/GF_Dialogue';
						portrait.portraitPrefix = 'gf splitathon portrait';
					case 'fancy' | 'fnaf is real':
						portrait.portraitPath = 'dialogue/GF_Dialogue';
						portrait.portraitPrefix = 'gf blocked portrait';
				}
				portrait.left = false;
		}
		return portrait;
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curMod = splitName[0];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[0].length + 2).trim();
	}
}
class Portrait
{
	public var portraitPath:String;
	public var portraitLibraryPath:String = '';
	public var portraitPrefix:String;
	public var left:Bool;
	public function new (portraitPath:String, portraitLibraryPath:String = '', portraitPrefix:String, left:Bool)
	{
		this.portraitPath = portraitPath;
		this.portraitLibraryPath = portraitLibraryPath;
		this.portraitPrefix = portraitPrefix;
		this.left = left;
	}
}