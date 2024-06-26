package;

#if sys
import sys.FileSystem;
#end
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef SongHeading = {
	var path:String;
	var antiAliasing:Bool;
	var ?animation:Animation;
	var iconOffset:Float;
}
class CreditsPopUp extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var bgHeading:FlxSprite;

	public var funnyText:FlxText;
	public var funnyIcon:FlxSprite;
	var iconOffset:Float;
	var curHeading:SongHeading;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		add(bg);
		var songCreator:String = '';
		var songCreatorIcon:String = '';
		var headingPath:SongHeading = null;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'probability' | 'electronic' | 'carnivore' | 'pooped' | 'kawai!1!' | 'tech' | 'trains' | 'lightning' | 'dealings' | 'untitled' | 'p' | 'style' | 'mustard' | 'nice and cool':
				songCreator = 'geby';
			case 'motocycle' | 'fancy' | 'pipebomb' | 'summer' | 'agronomist' | 'subversive' | 'spin dashin' | 'asfalto' | 'falsify' | 'eighteen' | 'agronomist v71961' | 'icsa3aahcmaj' | 'cookie dough' | 'jollytastic!':
				songCreator = 'poopypants839';
			case 'lore':
				songCreator = 'Kiwiquest' + '\n' + LanguageManager.getTextString('credits_remixby') + ' ' + 'poopypants839';
			case 'phantasm':
				songCreator = 'Biddle3' + '\n' + LanguageManager.getTextString('credits_remixby') + ' ' + 'poopypants839';
			case 'in the trap':
				songCreator = 'Valerange' + '\n' + LanguageManager.getTextString('credits_remixby') + ' ' + 'poopypants839';
			case 'agronomo':
				songCreator = 'poopypants839' + '\n' + LanguageManager.getTextString('credits_garbageby') + ' ' + 'Praga Infernal & Noname';
                if(!ClientPrefs.cursing)
				{
					songCreator = 'poopypants839' + '\n' + LanguageManager.getTextString('credits_garbageby-censored') + ' ' + 'Praga Infernal & Noname';
				}
			case 'oblique' | 'rage' | 'miss ass hold' | 'talkative' | 'fnaf is real' | 'deez nuts v2':
				songCreator = 'JooJ Dumwell';
			case 'maize' | 'confrontation' | 'insane corn' | 'reminiscence' | 'dangerous':
				songCreator = 'Luan';
			case '123.12.1234.123':
				songCreator = 'Ben';
			case 'cake':
				songCreator = 'D-Plushies';
			case 'power' | 'fun spooky battle' | 'vacation':
				songCreator = 'Espla';
		}
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				headingPath = {path: 'songHeadings/daveHeading', antiAliasing: false, iconOffset: 0};
			case 'probability' | 'electronic' | 'carnivore' | 'pooped' | 'kawai!1!' | 'tech' | 'trains' | 'lightning' | 'dealings' | 'untitled', 'style' | 'mustard' | 'p' | 'nice and cool':
				headingPath = {path: 'songHeadings/gbHeading', antiAliasing: false, iconOffset: 0};
			case 'lore':
				headingPath = {path: 'songHeadings/kiwiHeading', antiAliasing: false, iconOffset: 0};
			case 'phantasm':
			    headingPath = {path: 'songHeadings/biddleHeading', antiAliasing: false, iconOffset: 0};
			case 'in the trap':
			    headingPath = {path: 'songHeadings/valerangeHeading', antiAliasing: false, iconOffset: 0};
			case 'agronomo':
			    headingPath = {path: 'songHeadings/kiwiHeading', antiAliasing: false, iconOffset: 0};
			case 'oblique' | 'rage' | 'miss ass hold' | 'talkative' | 'fnaf is real' | 'deez nuts v2':
				headingPath = {path: 'songHeadings/joojHeading', antiAliasing: false, iconOffset: 0};
			case 'maize' | 'confrontation' | 'insane corn' | 'reminiscence' | 'dangerous':
				headingPath = {path: 'songHeadings/luanHeading', antiAliasing: false, iconOffset: 0};
			case '123.12.1234.123':
				headingPath = {path: 'songHeadings/benHeading', antiAliasing: false, iconOffset: 0};
			case 'cake' | 'motocycle' | 'fancy' | 'pipebomb' | 'summer' | 'agronomist' | 'subversive' | 'spin dashin' | 'asfalto' | 'falsify' | 'jollytastic!' | 'agronomist v71961' | 'icsa3aahcmaj' | 'cookie dough':
				headingPath = {path: 'songHeadings/dplushiesHeading', antiAliasing: false, iconOffset: 0};
			case 'power' | 'fun spooky battle' | 'vacation':
				headingPath = {path: 'songHeadings/esplaHeading', antiAliasing: false, iconOffset: 0};
		}

		if (headingPath != null)
		{
			if (headingPath.animation == null)
			{
				bg.loadGraphic(Paths.image(headingPath.path));
			}
			else
			{
				var info = headingPath.animation;
				bg.frames = Paths.getSparrowAtlas(headingPath.path);
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
			}
			bg.antialiasing = headingPath.antiAliasing;
			curHeading = headingPath;
		}
		createHeadingText(LanguageManager.getTextString("credits_songby") + ' ' + '${songCreatorIcon != '' ? songCreatorIcon : songCreator}');

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'in the trap':
				funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/Valerange'));
			case 'phantasm':
				funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/Biddle3'));
			case 'lore':
				funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/Kiwiquest'));
			case 'agronomo':
			    funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/Praga x Noname Shipping Cute'));
			default:
				funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/' + songCreator));
		}
		rescaleIcon();
		add(funnyIcon);

		rescaleBG();

		var yValues = CoolUtil.getMinAndMax(bg.height, funnyText.height);
		funnyText.y = funnyText.y + ((yValues[0] - yValues[1]) / 2);
	}
	public function switchHeading(newHeading:SongHeading)
	{
		if (bg != null)
		{
			remove(bg);
		}
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		if (newHeading != null)
		{
			if (newHeading.animation == null)
			{
				bg.loadGraphic(Paths.image(newHeading.path));
			}
			else
			{
				var info = newHeading.animation;
				bg.frames = Paths.getSparrowAtlas(newHeading.path);
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
			}
		}
		bg.antialiasing = newHeading.antiAliasing;
		curHeading = newHeading;
		add(bg);
		
		rescaleBG();
	}
	public function changeText(newText:String, newIcon:String, rescaleHeading:Bool = true)
	{
		createHeadingText(newText);
		
		if (funnyIcon != null)
		{
			remove(funnyIcon);
		}
		funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/' + newIcon, 'shared'));
		rescaleIcon();
		add(funnyIcon);

		if (rescaleHeading)
		{
			rescaleBG();
		}
	}
	public function createHeadingText(text:String)
	{
		if (funnyText != null)
		{
			remove(funnyText);
		}
		funnyText = new FlxText(1, 0, 650, text, 16);
		funnyText.setFormat('Comic Sans MS Bold', 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyText.borderSize = 2;
		funnyText.antialiasing = true;
		add(funnyText);
	}
	public function rescaleIcon()
	{
		var offset = (curHeading == null ? 0 : curHeading.iconOffset);

		var scaleValues = CoolUtil.getMinAndMax(funnyIcon.height, funnyText.height);
		funnyIcon.setGraphicSize(Std.int(funnyIcon.height / (scaleValues[1] / scaleValues[0])));
		funnyIcon.updateHitbox();

		var heightValues = CoolUtil.getMinAndMax(funnyIcon.height, funnyText.height);
		funnyIcon.setPosition(funnyText.textField.textWidth + offset, (heightValues[0] - heightValues[1]) / 2);
	}
	public function rescaleBG()
	{
		bg.setGraphicSize(Std.int((funnyText.textField.textWidth + funnyIcon.width + 0.5)), Std.int(funnyText.height + 0.5));
		bg.updateHitbox();
	}
}