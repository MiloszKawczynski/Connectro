event_inherited();

ui = new UI();

global.width = 11;
global.height = 11;
global.cellSize = 30;
global.cellWindowSize = 72.72;

global.crossRatio = 2;
global.diamondRatio = 4;
global.lineRatio = 2;
global.diagRatio = 2;
global.plusRatio = 2;
global.blockRatio = 1;
global.targetRatio = 1;

global.seed = 0;

calculateAllRatio();

with(ui)
{
	mainLayer = new Layer();
	mainLayer.setGrid(4, 7);
	
	var onTypeWidth = function(_value)
	{
		if (_value != "")
		{
			global.width = real(_value);
		}
	}
	
	var onTypeHeight = function(_value)
	{
		if (_value != "")
		{
			global.height = real(_value);
		}
	}
	
	var onTypeScale = function(_value)
	{
		if (_value != "")
		{
			global.cellWindowSize = 72.72 * real(_value);
		}
	}
	
	var onTypeCrossRatio = function(_value)
	{
		if (_value != "")
		{
			global.crossRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeDiamondRatio = function(_value)
	{
		if (_value != "")
		{
			global.diamondRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeLineRatio = function(_value)
	{
		if (_value != "")
		{
			global.lineRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeDiagRatio = function(_value)
	{
		if (_value != "")
		{
			global.diagRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypePlusRatio = function(_value)
	{
		if (_value != "")
		{
			global.plusRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeBlockRatio = function(_value)
	{
		if (_value != "")
		{
			global.blockRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeTargetRatio = function(_value)
	{
		if (_value != "")
		{
			global.targetRatio = real(_value);
			updateAllRatio();
		}
	}
	
	var onTypeSeed = function(_value)
	{
		if (_value != "")
		{
			global.seed = real(_value);
		}
	}
	
	widthInput = new InputText(onTypeWidth, 3, "11");
	widthInput.setSpriteSheet(ats_input);
	widthInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	widthText = new Text("Width", f_base);
	
	heightInput = new InputText(onTypeHeight, 3, "11");
	heightInput.setSpriteSheet(ats_input);
	heightInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	heightText = new Text("Height", f_base);
	
	scaleInput = new InputText(onTypeScale, 3, "1");
	scaleInput.setSpriteSheet(ats_input);
	scaleInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]);
	scaleText = new Text("Scale", f_base);
	
	crossRatio = new InputText(onTypeCrossRatio, 2, string(global.crossRatio));
	crossRatio.setSpriteSheet(ats_input);
	crossRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	crossRatioText = new Text(string("Cross ratio: {0}%", global.crossRatio / global.allRatio * 100), f_base);
	
	diamondRatio = new InputText(onTypeDiamondRatio, 2, string(global.diamondRatio));
	diamondRatio.setSpriteSheet(ats_input);
	diamondRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	diamondRatioText = new Text(string("Diamond ratio: {0}%", global.diamondRatio / global.allRatio * 100), f_base);
	
	lineRatio = new InputText(onTypeLineRatio, 2, string(global.lineRatio));
	lineRatio.setSpriteSheet(ats_input);
	lineRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	lineRatioText = new Text(string("Line ratio: {0}%", global.lineRatio / global.allRatio * 100), f_base);
	
	diagRatio = new InputText(onTypeDiagRatio, 2, string(global.diagRatio));
	diagRatio.setSpriteSheet(ats_input);
	diagRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	diagRatioText = new Text(string("Diag ratio: {0}%", global.diagRatio / global.allRatio * 100), f_base);
	
	plusRatio = new InputText(onTypePlusRatio, 2, string(global.plusRatio));
	plusRatio.setSpriteSheet(ats_input);
	plusRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	plusRatioText = new Text(string("Plus ratio: {0}%", global.plusRatio / global.allRatio * 100), f_base);
	
	blockRatio = new InputText(onTypeBlockRatio, 2, string(global.blockRatio));
	blockRatio.setSpriteSheet(ats_input);
	blockRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	blockRatioText = new Text(string("Block ratio: {0}%", global.blockRatio / global.allRatio * 100), f_base);
	
	targetRatio = new InputText(onTypeTargetRatio, 2, string(global.targetRatio));
	targetRatio.setSpriteSheet(ats_input);
	targetRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	targetRatioText = new Text(string("Target ratio: {0}%", global.targetRatio / global.allRatio * 100), f_base);
	
	seedInput = new InputText(onTypeSeed, 10, string(global.seed));
	seedInput.setSpriteSheet(ats_input);
	seedInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	seedInput.setScale(2, 1);
	
	var goNextFunction = function()
	{
		with(o_menu)
		{
			room_set_width(r_game, global.width * global.cellSize);
			room_set_height(r_game, global.height * global.cellSize);
			
			random_set_seed(global.seed);
			
			alarm[0] = 1;
		}
	}
	
	goButton = new Button(goNextFunction);
	goButton.setSpriteSheet(ats_button);
	
	mainLayer.addComponent(1.5, 0.5, widthInput);
	mainLayer.addComponent(2.5, 0.5, widthText);
	mainLayer.addComponent(1.5, 1, heightInput);
	mainLayer.addComponent(2.5, 1, heightText);
	mainLayer.addComponent(1.5, 1.5, scaleInput);
	mainLayer.addComponent(2.5, 1.5, scaleText);
	mainLayer.addComponent(1.5, 2, crossRatio);
	mainLayer.addComponent(2.5, 2, crossRatioText);	
	mainLayer.addComponent(1.5, 2.5, diamondRatio);
	mainLayer.addComponent(2.5, 2.5, diamondRatioText);	
	mainLayer.addComponent(1.5, 3, lineRatio);
	mainLayer.addComponent(2.5, 3, lineRatioText);	
	mainLayer.addComponent(1.5, 3.5, diagRatio);
	mainLayer.addComponent(2.5, 3.5, diagRatioText);	
	mainLayer.addComponent(1.5, 4, plusRatio);
	mainLayer.addComponent(2.5, 4, plusRatioText);	
	mainLayer.addComponent(1.5, 4.5, blockRatio);
	mainLayer.addComponent(2.5, 4.5, blockRatioText);	
	mainLayer.addComponent(1.5, 5, targetRatio);
	mainLayer.addComponent(2.5, 5, targetRatioText);	
	mainLayer.addComponent(1.5, 5.5, seedInput);	
	mainLayer.addComponent(2, 6, goButton);
	
	pushLayer(mainLayer);
}