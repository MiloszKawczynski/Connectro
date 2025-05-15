function normal(showPotential = false)
{
	normalTileEffect(showPotential);
}

function mustPickDirection(showPotential = false)
{
	mustPickDirectionTileEffect(showPotential);
}

function mustPickTarget(showPotential = false)
{
	mustPickTargetTileEffect(showPotential);
}

function gameEnd(showPotential = false)
{
	if (!showPotential)
	{
		if (mouse_check_button_pressed(mb_left))
		{
			//audio_stop_all();
			//room_restart();
		}
	}
}

function editor()
{
	if (mouse_check_button_pressed(mb_left))
    {
        var newTile = new Tile(editorType);
        newTile.isAvailable = true;
        if (editorType != TilesTypes.block and editorType != TilesTypes.target)
        {
            newTile.value = editorValue;
        }
        ds_grid_set(grid, hoveredX, hoveredY, newTile);
    }
    
    if (mouse_check_button_pressed(mb_right))
    {
        ds_grid_set(grid, hoveredX, hoveredY, 0);
    }
    
    if (keyboard_check(vk_lshift))
    {
        editorValue += mouse_wheel_down() - mouse_wheel_up();
        
        if (editorValue < 1)
        {
            editorValue = 5;
        }
        
        if (editorValue > 5)
        {
            editorValue = 1;
        }
    }
    else 
    {
        editorType += mouse_wheel_down() - mouse_wheel_up();
        
        if (editorType < 0)
        {
            editorType = 6;
        }
        
        if (editorType > 6)
        {
            editorType = 0;
        }
    }
}

//---

function normalDraw()
{
	gameState(true);
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
			tile.drawColor(xx, yy);
			tile.drawButton(xx, yy);
			tile.drawHover(xx, yy, hoveredX, hoveredY);
			tile.drawPotential(xx, yy);
		}
	}
	
	removePotential();
	drawLines();
}

function endScreenTransitionDraw()
{
	buildingScale = lerp(buildingScale, 0.25, 0.03);
	buildingTilt = lerp(buildingTilt, -20, 0.03);
	
	if (abs(buildingScale - 0.25) < 1 and abs(buildingTilt + 20) < 1) 
	{
		drawState = gameEndDraw;
	}
	
	drawEndScreen();
}

function gameEndDraw()
{
	if (mouse_check_button_pressed(mb_left))
	{
		lastMousePositionPressed = mouse_x - (buildingRotation + buildingFingerRotation);
	}
	
	if (mouse_check_button(mb_left))
	{
		buildingFingerRotation = mouse_x - lastMousePositionPressed;
		buildingRotationSpeed = 0;
		buildingRotation = 0;
	}
	else 
	{
		buildingRotationSpeed = lerp(buildingRotationSpeed, 1, 0.01);
	}
	
	if (mouse_check_button_released(mb_left))
	{
		buildingRotationSpeed += mouse_x - lastMousePosition;
	}
	
	buildingRotation += buildingRotationSpeed;
	if (buildingRotation >= 360) 
	{
		buildingRotation = 0;
	}
	
	lastMousePosition = lerp(lastMousePosition, mouse_x, 0.5);
	
	drawEndScreen();
}

function editorDraw()
{
    for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
            if (tile != 0)
            {
                tile.drawColor(xx, yy);
                tile.drawButton(xx, yy);
            }
			//tile.drawHover(xx, yy, hoveredX, hoveredY);
			//tile.drawPotential(xx, yy);
		}
	}
	
	drawLines();
}

//---

function drawEndScreen()
{ 
	drawLines();
	
	gpu_set_zwriteenable(true);
	gpu_set_ztestenable(true);
	gpu_set_alphatestenable(true);
	gpu_set_cullmode(cull_clockwise);
	
	var buildingSizeWidth = global.width * global.cellSize * buildingScale;
	var buildingSizeHeight = global.height * global.cellSize * buildingScale;
	
	var shiftH = ((global.width * global.cellSize) - buildingSizeWidth) / 2;
	var shiftV = ((global.height * global.cellSize) - buildingSizeHeight) / 2;
	
	var centerX = shiftH + buildingSizeWidth/2;
	var centerY = shiftV + buildingSizeHeight/2;
	
	matrix_set(matrix_world, matrix_build(centerX, centerY, 0, buildingTilt, 180 + buildingRotation + buildingFingerRotation, 0, buildingScale, buildingScale, buildingScale));
	vertex_submit(front, pr_trianglelist, surfaceTexture);
	matrix_set(matrix_world, matrix_build_identity());
	
	gpu_set_zwriteenable(false);
	gpu_set_ztestenable(false);
	gpu_set_alphatestenable(false);
	gpu_set_cullmode(cull_noculling);
	
	draw_set_color(c_white);
	draw_text(room_width / 2, room_height * 0.1, moves);
}

function drawLines()
{
	draw_set_color(c_black);
	draw_set_alpha(1);
	for(var yy = 0; yy < global.height; yy++)
	{
		draw_line_width(0, yy * global.cellSize, room_width, yy * global.cellSize, 2);
	}
	
	for(var xx = 0; xx < global.width; xx++)
	{
		draw_line_width(xx * global.cellSize, 0, xx * global.cellSize, room_height, 2);
	}
}