initialize();

LootLockerInitialize("dev_4b98ea0634db46dc9241a22ca7cb012a", "0.0.0.1", "true", "31457")
LootLockerTurnOffAutoRefresh();

if (!file_exists("playerId.ini"))
{
    var guid = generateUniquePlayerId();
    ini_open("playerId.ini");
    ini_write_string("player", "id", guid);
    ini_close();
}

{
	ini_open("playerId.ini");
	var playerId = ini_read_string("player", "id", "UNKNOWN");
	ini_close();
	
	LootLockerSetPlayerName(playerId);
}

global.seed = 0;

global.isEditorOn = false;
global.level = "";
global.typeOfLoad = 0;

global.isSolverOn = false;
global.gamesToSolve = 0;
global.debugStars = 0;

debugPress = 0;

global.isRoguelikeMode = false;
if (file_exists(global.savedRoguelikeFilename))
{
    loadGame();
}
else 
{
    global.roguelikeLevelNumber = 0;
}

if (!variable_global_exists("roguelikeBest"))
{
    global.roguelikeBest = 0;
}

event_inherited();

randomize();

ui = new UI();

fadeAlpha = 1;
fade = false;
fadeFunction = undefined;

paintFunctionFade = function()
{ 
    global.isRoguelikeMode = false;
    room_goto(r_map);
}

rogueFunctionFade = function()
{ 
    global.isRoguelikeMode = true;
	global.shouldLoadRoguelike = true;
    room_goto(r_game);
}

with(ui)
{
    logoTimer = 0;
    init = true;
    
	mainLayer = new Layer();
	mainLayer.setGrid(6, 13);
    
    iconBarArray = [];
    
    for (var i = 0; i < 6; i++)
    {
        var iconBar = new Output();
        var rand = irandom(sprite_get_number(s_menuIconBar));
        with(iconBar)
        {
            randomVariant = rand;
            drawVariant = function() 
            { 
                draw_sprite_ext(s_menuIconBar, randomVariant, posX, posY, scaleX, scaleY, rotation, color, alpha);
            };
            
            setDrawFunction(drawVariant, sprite_get_width(s_menuIconBar), sprite_get_height(s_menuIconBar));
            
        }
        
        var iconBarBck = new Output();
        with(iconBarBck)
        {
            randomVariant = rand;
            drawVariant = function() 
            { 
                draw_sprite_ext(s_menuIconBar, randomVariant, posX, posY, scaleX, scaleY, rotation, color, alpha);
            };
            
            setDrawFunction(drawVariant, sprite_get_width(s_menuIconBar), sprite_get_height(s_menuIconBar));
            setShift(-width, 0);
        }
        
        array_push(iconBarArray, iconBar, iconBarBck);
        
        mainLayer.addComponent(0, 3 + i, iconBar);
        mainLayer.addComponent(0, 3 + i, iconBarBck);
    }
    
    vignetteL = new Output();
    vignetteL.setSprite(s_menuVignette);
    
    vignetteR = new Output();
    vignetteR.setSprite(s_menuVignette);
    vignetteR.setScale(-1, 1);
    
    logo = new Output();
    logo.setSprite(s_logo);
    
    var paintFunction = function()
	{
        o_init.fade = true;
        o_init.fadeFunction = o_init.paintFunctionFade;
	}
    
    var rogueFunction = function()
	{ 
        o_init.fade = true;
        o_init.fadeFunction = o_init.rogueFunctionFade;
	}
    
    var resetFunction = function()
	{
		deleteSavedData();
	}
	
	var resetAllFunction = function()
	{
		deleteSavedData();
		deleteSavedRoguelike();
		global.roguelikeLevelNumber = 0;
		global.paints = [undefined, undefined, undefined];
	}
    
    var unlockFunction = function()
	{
		global.debugStars = 100;
	}
    
    paintButton = new Button(paintFunction);
    paintButton.setSprites(s_button);
    paintButtonText = new Text("City", f_menu);
    paintButtonText.setShift(0, 4);
    paintButtonText.setColor(c_black);
    
    rogueButton = new Button(rogueFunction);
    rogueButton.setSprites(s_button);
    rogueButtonText = new Text("Roguelike", f_menu);
    rogueButtonText.setShift(0, 4);
    rogueButtonText.setColor(c_black);
    
    var scoreText = string("Current: {0}     Best: {1}", global.roguelikeLevelNumber, global.roguelikeBest);
    
    if (global.roguelikeLevelNumber == 0)
    {
        scoreText = string("Best: {0}", global.roguelikeBest);
    }
    
    rogueScoreText = new Text(scoreText, f_menu);
    rogueScoreText.setColor(c_white);
    rogueScoreText.setScale(0.65, 0.65);
    
    resetButton = new Button(resetFunction);
    resetButton.setSprites(s_buttonMini);
    resetButtonText = new Text("Reset", f_menu);
    resetButtonText.setShift(0, 4);
    resetButtonText.setColor(c_black);
    
    resetButton = new Button(resetFunction);
    resetButton.setSprites(s_buttonMini);
    resetButtonText = new Text("R", f_menu);
    resetButtonText.setShift(0, 4);
    resetButtonText.setColor(c_black);
    
    resetAllButton = new Button(resetAllFunction);
    resetAllButton.setSprites(s_buttonMini);
    resetAllButtonText = new Text("rall", f_menu);
    resetAllButtonText.setShift(0, 4);
    resetAllButtonText.setColor(c_black);
    
    unlockAllButton = new Button(unlockFunction);
    unlockAllButton.setSprites(s_buttonMini);
    unlockAllButtonText = new Text("uall", f_menu);
    unlockAllButtonText.setShift(0, 4);
    unlockAllButtonText.setColor(c_black);
    
    mainLayer.addComponent(0, 0, vignetteL);
    mainLayer.addComponent(6, 0, vignetteR);
    mainLayer.addComponent(0, -5, logo);
    mainLayer.addComponent(3, 9.75, paintButton);
    mainLayer.addComponent(3, 11, rogueButton);
    mainLayer.addComponent(3, 12, rogueScoreText);
    mainLayer.addComponent(3, 9.75, paintButtonText);
    mainLayer.addComponent(3, 11, rogueButtonText);
	
	pushLayer(mainLayer);
}