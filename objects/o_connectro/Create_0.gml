global.width = global.levels[global.choosedLevel].width;
global.height = global.levels[global.choosedLevel].height;

if (string_digits(global.levels[global.choosedLevel].seed) == "")
{
    global.typeOfLoad = 2;
    global.level = global.levels[global.choosedLevel].seed;
}
else 
{
	global.typeOfLoad = 0;
}

event_inherited();

camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);

ui = new UI();

with(ui)
{
    mainLayer = new Layer();
    mainLayer.setGrid(7, 14, false);
    
    var goBackFunction = function()
	{
		room_goto(r_map);
	}
    
    goBackButton = new Button(goBackFunction);
    goBackButton.setSpriteSheet(s_uiGoBack);
    goBackButton.setScale(4, 4);
    
    var restartFunction = function()
	{ 
        audio_stop_all();
	    room_restart();
	}
    
    restartButton = new Button(restartFunction);
    restartButton.setSpriteSheet(s_uiRestart);
    restartButton.setScale(4, 4);
    
    add = new Output();
    add.setSprite(s_uiAdd);
    add.setScale(4, 4);
    
    with(add)
    {
        with(state)
        {
            draw = function()
            {
                draw_sprite_ext(s_uiAdd, 1, component.posX, component.posY, component.scaleX, component.scaleY, component.rotation, c_white, component.alpha);
            }
        }
    }
    
    movesCount = new Text(0, f_base);
    movesCount.setScale(4, 4);
    
    movesBar = new GradientBar(1);
    movesBar.setScale(8, 1);
    
    firstStarRing = new Output();
    firstStarRing.setSprite(s_uiLimitGold);
    firstStarRing.setScale(4, 4);
    
    secondStarRing = new Output();
    secondStarRing.setSprite(s_uiLimitGold);
    secondStarRing.setScale(4, 4);
    
    thirdStarRing = new Output();
    thirdStarRing.setSprite(s_uiLimitGold);
    thirdStarRing.setScale(4, 4);
    
    movesToFirstStar = new Text(global.levels[global.choosedLevel].movesToStar[0], f_game);
    movesToFirstStar.setScale(0.55, 0.55);
    
    movesToSecondStar = new Text(global.levels[global.choosedLevel].movesToStar[1], f_game);
    movesToSecondStar.setScale(0.55, 0.55);
    
    movesToThirdStar = new Text(global.levels[global.choosedLevel].movesToStar[2], f_game);
    movesToThirdStar.setScale(0.55, 0.55);
    
    firstStar = new Output();
    
    secondStar = new Output();
    
    thirdStar = new Output();
    
    var starsMoves = [movesToFirstStar, movesToSecondStar, movesToThirdStar]
    var stars = [firstStar, secondStar, thirdStar]
    
    for (var i = 0; i < 3; i ++)
    {
        with(stars[i])
        {
            isGold = true;
            time = 0;
            
            step = function()
            {
                if (!isGold) 
                {
                    if (scaleX != 0)
                    {
                        time = timer(time, 0.02);
                    }
                    var scale = animcurve_get_point(ac_loseStar, 0, time);
                    scaleX = scale;
                    scaleY = scale;
                    alpha = scale;
                    rotation = (1 - scale) * 180;
                }
            }
            
            with(state)
            {
                draw = function()
                {
                    draw_sprite_ext(s_uiBigStar, 0, component.posX, component.posY, 1, 1, 0, c_white, 1);
                    draw_sprite_ext(s_uiBigStar, 1, component.posX, component.posY, component.scaleX, component.scaleY, component.rotation, c_white, component.alpha);
                }
            }
        }
        
        with(starsMoves[i])
        {
            draw = function() 
    		{
    			draw_set_color(color);
    			draw_set_alpha(alpha);
    			draw_set_font(font);
    			draw_set_halign(horizontalAlign);
    			draw_set_valign(verticalAlign);
                
                font_enable_effects(f_game, true, 
                {
                    outlineEnable: true,
                    outlineDistance: 5,
                    outlineColour: c_black
                });
    			
    			draw_text_transformed(posX, posY, content, scaleX, scaleY, rotation);
    			 
    			draw_set_alpha(1);
    		};
    		
    		state.draw = draw;
        }
    }
    
    with(movesBar)
    {
        width = sprite_get_width(s_uiBarFill);
        
        with(state)
        {
            draw = function()
            {
                draw_sprite_ext(s_uiBar, 0, component.posX, component.posY, component.scaleX, component.scaleY, 0, c_white, 1);
                if (component.value < 1)
                {
                    draw_sprite_ext(s_uiBarFillNotFull, 0, component.posX - component.scaleX * component.width / 2, component.posY, component.scaleX * component.value, component.scaleY, 0, c_white, 1);
                }
                else 
                {
                	draw_sprite_ext(s_uiBarFill, 0, component.posX - component.scaleX * component.width / 2, component.posY, component.scaleX * component.value, component.scaleY, 0, c_white, 1);
                }
            }
        }
    }
    
    mainLayer.addComponent(1, 13.25, goBackButton);
    mainLayer.addComponent(6, 13.25, restartButton);
    
    mainLayer.addComponent(3.5, 13.25, movesCount);
    
    mainLayer.addComponent(3.5, 0.5, add);
    
    mainLayer.addComponent(3.5, 2.25, movesBar);
    
    mainLayer.addComponent(3.5, 2.25, firstStarRing);
    mainLayer.addComponent(3.5, 2.25, secondStarRing);
    mainLayer.addComponent(3.5, 2.25, thirdStarRing);
    
    mainLayer.addComponent(3.5, 2.25, movesToFirstStar);
    mainLayer.addComponent(3.5, 2.25, movesToSecondStar);
    mainLayer.addComponent(3.5, 2.25, movesToThirdStar);
    
    mainLayer.addComponent(1.5, 1.35, firstStar);
    mainLayer.addComponent(3.5, 1.35, secondStar);
    mainLayer.addComponent(5.5, 1.35, thirdStar);

    pushLayer(mainLayer);
}

if (global.seed == 0)
{
	randomize();
}

device_mouse_dbclick_enable(false);

global.cellSize = room_width / global.width;

gameOffset = camera_get_view_height(view_camera[0]) / 14 * 2.9;

grid = ds_grid_create(global.width, global.height);

generateGame();

hoveredX = 0;
hoveredY = 0;

moves = 0;

drawSurface = false;
is3DCreated = false;

var buildingSprite = global.levels[global.choosedLevel].sprite;
var spriteWidth = sprite_get_width(buildingSprite);
var spriteHeight = sprite_get_height(buildingSprite);

muralSurface = surface_create(global.width * global.cellSize, global.height * global.cellSize);
blockSurface = surface_create(spriteWidth, spriteHeight);

buildingRotation = 0;
buildingFingerRotation = 0;
buildingRotationSpeed = 1;
buildingScale = 1;
buildingTilt = 0;

lastMousePosition = mouse_x;
lastMousePositionPressed = mouse_x;

gameState = normal;
drawState = normalDraw;

editorType = 0;
editorValue = 1;
editorStartingTileX = -1;
editorStartingTileY = -1;

if (global.isEditorOn)
{
    gameState = editor;
    drawState = editorDraw;
}
else 
{
	gameState = normal;
    drawState = normalDraw;
}
