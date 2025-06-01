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
    
    secondStarRing = new Output();
    secondStarRing.setSprite(s_uiLimitGold);
    secondStarRing.setScale(4, 4);
    
    thirdStarRing = new Output();
    thirdStarRing.setSprite(s_uiLimitGold);
    thirdStarRing.setScale(4, 4);
    
    movesToSecondStar = new Text(global.levels[global.choosedLevel].movesToStar[1], f_base);
    movesToSecondStar.setScale(2, 2);
    
    movesToThirdStar = new Text(global.levels[global.choosedLevel].movesToStar[2], f_base);
    movesToThirdStar.setScale(2, 2);
    
    firstStar = new Output();
    
    secondStar = new Output();
    
    thirdStar = new Output();
    
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
    
    mainLayer.addComponent(3.5, 2.5, movesBar);
    
    mainLayer.addComponent(3.5, 2.5, secondStarRing);
    mainLayer.addComponent(3.5, 2.5, thirdStarRing);
    mainLayer.addComponent(3.5, 2.5, movesToSecondStar);
    mainLayer.addComponent(3.5, 2.5, movesToThirdStar);
    
    mainLayer.addComponent(1.5, 1.55, firstStar);
    mainLayer.addComponent(3.5, 1.55, secondStar);
    mainLayer.addComponent(5.5, 1.55, thirdStar);

    pushLayer(mainLayer);
}

if (global.seed == 0)
{
	randomize();
}

device_mouse_dbclick_enable(false);

global.cellSize = room_width / global.width;

gameOffset = camera_get_view_height(view_camera[0]) / 14 * 3.5;

grid = ds_grid_create(global.width, global.height);

generateGame();

hoveredX = 0;
hoveredY = 0;

moves = 0;

drawSurface = false;
is3DCreated = false;

muralSurface = surface_create(global.width * global.cellSize, global.height * global.cellSize);
blockSurface = surface_create(39 * 5, 39);

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
