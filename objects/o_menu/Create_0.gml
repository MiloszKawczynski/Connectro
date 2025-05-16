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

global.isEditorOn = false;
global.level = "save";
global.gamesToSolve = 0;

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
	
	var onTypeGamesToSolve = function(_value)
	{
		if (_value != "")
		{
			global.gamesToSolve = real(_value);
		}
	}
	
	widthInput = new InputText(onTypeWidth, 3, "11");
	widthInput.setSpriteSheet(ats_input);
	widthInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	widthText = new Text("Width", f_base, fa_left);
	
	heightInput = new InputText(onTypeHeight, 3, "11");
	heightInput.setSpriteSheet(ats_input);
	heightInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	heightText = new Text("Height", f_base, fa_left);
	
	crossRatio = new InputText(onTypeCrossRatio, 2, string(global.crossRatio));
	crossRatio.setSpriteSheet(ats_input);
	crossRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	crossRatioText = new Text(string("Cross ratio: {0}%", global.crossRatio / global.allRatio * 100), f_base, fa_left);
	
	diamondRatio = new InputText(onTypeDiamondRatio, 2, string(global.diamondRatio));
	diamondRatio.setSpriteSheet(ats_input);
	diamondRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	diamondRatioText = new Text(string("Diamond ratio: {0}%", global.diamondRatio / global.allRatio * 100), f_base, fa_left);
	
	lineRatio = new InputText(onTypeLineRatio, 2, string(global.lineRatio));
	lineRatio.setSpriteSheet(ats_input);
	lineRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	lineRatioText = new Text(string("Line ratio: {0}%", global.lineRatio / global.allRatio * 100), f_base, fa_left);
	
	diagRatio = new InputText(onTypeDiagRatio, 2, string(global.diagRatio));
	diagRatio.setSpriteSheet(ats_input);
	diagRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	diagRatioText = new Text(string("Diag ratio: {0}%", global.diagRatio / global.allRatio * 100), f_base, fa_left);
	
	plusRatio = new InputText(onTypePlusRatio, 2, string(global.plusRatio));
	plusRatio.setSpriteSheet(ats_input);
	plusRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	plusRatioText = new Text(string("Plus ratio: {0}%", global.plusRatio / global.allRatio * 100), f_base, fa_left);
	
	blockRatio = new InputText(onTypeBlockRatio, 2, string(global.blockRatio));
	blockRatio.setSpriteSheet(ats_input);
	blockRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	blockRatioText = new Text(string("Block ratio: {0}%", global.blockRatio / global.allRatio * 100), f_base, fa_left);
	
	targetRatio = new InputText(onTypeTargetRatio, 2, string(global.targetRatio));
	targetRatio.setSpriteSheet(ats_input);
	targetRatio.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	targetRatioText = new Text(string("Target ratio: {0}%", global.targetRatio / global.allRatio * 100), f_base, fa_left);
	
	seedInput = new InputText(onTypeSeed, 10, string(global.seed));
	seedInput.setSpriteSheet(ats_input);
	seedInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	seedInput.setScale(2, 1);
    seedText = new Text("Seed RMB to paste", f_base, fa_left);
	
	gameToSolveInput = new InputText(onTypeGamesToSolve, 2, string(global.gamesToSolve));
	gameToSolveInput.setSpriteSheet(ats_input);
	gameToSolveInput.setAcceptableCharacters(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
	gameToSolveInput.setScale(2, 1);
	
	var goNextFunction = function()
	{
		with(o_menu)
		{
            if (!global.isEditorOn)
            {
                if (global.level != "")
                {
                    var file = file_text_open_read(global.level + ".txt");

                    global.width = file_text_read_real(file);
                    global.height = file_text_read_real(file);

                    file_text_close(file);
                }	
            }
            
			room_set_width(r_game, global.width * global.cellSize);
			room_set_height(r_game, global.height * global.cellSize);
			
			random_set_seed(global.seed);
			
			alarm[0] = 1;
		}
	}
	
	goButton = new Button(goNextFunction);
	goButton.setSpriteSheet(ats_button);
    goButtonText = new Text("Play!", f_base);
    goButtonText.color = c_black;
	
	mainLayer.addComponent(0.5, 0.5, widthInput);
	mainLayer.addComponent(0.75, 0.5, widthText);
	mainLayer.addComponent(0.5, 1, heightInput);
	mainLayer.addComponent(0.75, 1, heightText);
    
	mainLayer.addComponent(0.5, 2, crossRatio);
	mainLayer.addComponent(1.2, 2, crossRatioText);	
	mainLayer.addComponent(0.5, 2.5, diamondRatio);
	mainLayer.addComponent(1.2, 2.5, diamondRatioText);	
	mainLayer.addComponent(0.5, 3, lineRatio);
	mainLayer.addComponent(1.2, 3, lineRatioText);	
	mainLayer.addComponent(0.5, 3.5, diagRatio);
	mainLayer.addComponent(1.2, 3.5, diagRatioText);	
	mainLayer.addComponent(0.5, 4, plusRatio);
	mainLayer.addComponent(1.2, 4, plusRatioText);	
	mainLayer.addComponent(0.5, 4.5, blockRatio);
	mainLayer.addComponent(1.2, 4.5, blockRatioText);	
	mainLayer.addComponent(0.5, 5, targetRatio);
	mainLayer.addComponent(1.2, 5, targetRatioText);	
    
	mainLayer.addComponent(0.5, 6.0, seedInput);	
	mainLayer.addComponent(1.0, 6.0, seedText);	
    
	mainLayer.addComponent(1.5, 6, gameToSolveInput);	
	mainLayer.addComponent(2, 6.5, goButton);
	mainLayer.addComponent(2, 6.5, goButtonText);
	
	pushLayer(mainLayer);
}