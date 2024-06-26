package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
	    ['Developers'],
		['Webby',		       'webby',		    'Mod Creator, Artist, Animator, Composer and Director',                           'https://www.youtube.com/@apocositilin717',	                0xFF7D48BD],
		['Noname',		       'noname',		'Idea of the Mod, Jon Creator and Supporter',		                              'https://twitter.com/NonamePiadas',                           0xFFFF7F26],
		['Ben',                'ben',		    'Director, Coder, Composer, Artist, Animator , Charter and Portuguese Translator','https://twitter.com/PipocaAventuras',                        0xFF4494E6],
		['poopypants839',	   'taw',           'Director, Composer, Artist, Animator and Charter',	                              '',                                                           0xFF0026FF],
		['geby',		       'gb',		    'Composer, Artist, Animator and Charter',		                                  'https://twitter.com/estevs66',	                            0xFF53B7D8],
        ['Spike',		       'spike',         'Animator and Ideas',		                                                      'https://twitter.com/SHdgehog',	                            0xFFFFBF00],	
        ['Praga Infernal',     'beanz',         'Leo Creator, Modeler and Portuguese Translator',	                              'https://twitter.com/PragaInfernal',	                        0xFF803DC4],	
		['Noxius',	           'anzol',	        'Ideas and Niles Creator',				                                          'https://twitter.com/noxius1301',	                            0xFF4827A5],
		['Xolote',		       'xgui',	        'Plambi Creator and Ideas',				                                          'https://twitter.com/XGuilherme100',	                        0xFF0058FF],
		['Ice cube',	       'icecube',       'Asfalto Idea, Sprites and Background Maker',				                      'https://twitter.com/a_peguin',	                            0xFF66B0F4],
        ['chrixtmas',          'pythonreed',    'Danevy & Bombles Creator, 3D Background Maker and Artist',                       'https://twitter.com/chrixtmas0',	                            0xFF00814D],
		['JooJ Dumwell',	   'jooj',	        'Composer, Icons, Chromatics and Artist',				                          'https://twitter.com/JooJ_Dumwell',	                        0xFFFFFFFF],
		['Espla',		       'espla',	        'Composer, Ideas and Artist',		                                              'https://twitter.com/oEsplayan',	                            0xFFFF7B00],
		['Luan',               'luan',          'Composer and Artist',		                                                      'https://twitter.com/russextreme',	                        0xFF00FFAA],
		[''],
		['Contributors'],
		['Perk',		       'perk',		    'Contribuitor, Supporter and Spanish Translator',		  		  		  		  'https://twitter.com/DarezPeroEsDra1',                        0xFFFFFFFF],
		['HF',		           'hf185',	        'Some 3D Sprites',		                                  		  		  		  'https://twitter.com/hf85_',	                                0xFF566AFF],
		['Memoria',		       'memoria',		'Lore Sprites',		        		                      		  		  		  'https://twitter.com/Toad00253255',                           0xFF844B1C],
		['Rembulous',	       'rembulous',		'Samny Sprites',		                      	          		  		  		  'https://twitter.com/rembulous',	                            0xFFEFE9F1],
	    ['D-Plushies',	       'dplushies',     'Cake Composer',		                                  		  		  		  'https://youtube.com/@d-plushies',                            0xFF0038A8],
		['Syberyen',		   'syberyen',		'Minecraft Vanderley Sketch',		        		      		  		  		  'https://www.youtube.com/@syberyen',                          0xFFFF0005],
		['Vis0iden',	       'vis0iden',		'Maildave Creator',		                                 		   		  		  'https://twitter.com/vis0iden',	                            0xFFB87C33],
		['Raul Antuns',	       'raulants22',	'Supporter Coder and Tester',		                                 	  		  'https://twitter.com/RaulAnts',	                            0xFFFF0000],
		['Yan Pizza',	       'yanpizza',		'Supporter and Pizza God Creator',		                		  		  		  'https://www.youtube.com/@yanpizzapiadas699',	                0xFFBA905E],
		['Mosto',		       'sunik',		    'Supporter',		        		        		      		  		  		  'https://www.youtube.com/channel/UC7oedG-wtZdc7UjJz5jN3HA',   0xFF457E68],
		['JogG4DX',		       'jog',		    'Supporter',		        		        		      		  		  		  'https://twitter.com/JogG4DX',                                0xFFFF0041],
		[''],
		["Discord"],
		['Discord Server',     'discord',       'Join in the Discord Server',		                     		  		  		  'https://discord.gg/XbTzZ5JHmd',	                            0xFF5165F6]
	];

	var bg:FlxSprite = new FlxSprite();
	// var overlay:FlxSprite = new FlxSprite();
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg.loadGraphic(MainMenuState.randomizeBG());
		add(bg);

        /*
		overlay.loadGraphic(Paths.image('CoolOverlay'));
		add(overlay);
		*/

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = LanguageManager.getTextString('credits_' + creditsStuff[curSelected][0]);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
