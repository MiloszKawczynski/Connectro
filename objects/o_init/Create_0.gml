initialize();

global.seed = 0;

global.isEditorOn = false;
global.level = "";
global.typeOfLoad = 0;

global.isSolverOn = false;
global.gamesToSolve = 0;

event_inherited();

randomize();

ui = new UI();

fadeAlpha = 1;
fade = false;
fadeFunction = undefined;

paintFunctionFade = function()
{ 
    room_goto(r_map);
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
        o_init.fadeFunction = o_init.paintFunctionFade;
	}
    
    var resetFunction = function()
	{
		deleteSavedData();
	}
    
    paintButton = new Button(paintFunction);
    paintButton.setSprites(s_button);
    paintButtonText = new Text("Paint", f_menu);
    paintButtonText.setShift(0, 4);
    paintButtonText.setColor(c_black);
    
    rogueButton = new Button(rogueFunction);
    rogueButton.setSprites(s_button);
    rogueButtonText = new Text("Rogue", f_menu);
    rogueButtonText.setShift(0, 4);
    rogueButtonText.setColor(c_black);
    
    resetButton = new Button(resetFunction);
    resetButton.setSprites(s_button);
    resetButtonText = new Text("Reset", f_menu);
    resetButtonText.setShift(0, 4);
    resetButtonText.setColor(c_black);
    
    mainLayer.addComponent(0, 0, vignetteL);
    mainLayer.addComponent(6, 0, vignetteR);
    mainLayer.addComponent(0, -5, logo);
    mainLayer.addComponent(3, 9.5, paintButton);
    mainLayer.addComponent(3, 10.75, rogueButton);
    mainLayer.addComponent(3, 12, resetButton);
    mainLayer.addComponent(3, 9.5, paintButtonText);
    mainLayer.addComponent(3, 10.75, rogueButtonText);
    mainLayer.addComponent(3, 12, resetButtonText);
	
	pushLayer(mainLayer);
}