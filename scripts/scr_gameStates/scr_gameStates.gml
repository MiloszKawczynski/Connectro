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
			audio_stop_all();
            
            var gainedStars = 3;
            
            if (moves > global.levels[global.choosedLevel].movesToStar[0])
            {
                gainedStars = 0;
            }    
            else if (moves > global.levels[global.choosedLevel].movesToStar[1])
            {
                gainedStars = 1;
            }
            else if (moves > global.levels[global.choosedLevel].movesToStar[2])
            {
                gainedStars = 2;
            }
            
            if (moves <= global.levels[global.choosedLevel].moves)
            {
                global.levels[global.choosedLevel].stars = gainedStars;
                global.levels[global.choosedLevel].texture = surfaceTexture;
                global.levels[global.choosedLevel].moves = moves;
            }
            
			room_goto(r_map);
		}
	}
}

function editor()
{
	if (mouse_check_button_pressed(mb_left))
    {
        if (keyboard_check(vk_lcontrol))
        {
            editorStartingTileX = hoveredX;
            editorStartingTileY = hoveredY;
        }
        else 
        {
            var newTile = new Tile(editorType);
            newTile.isAvailable = true;
            newTile.isRevealed = true;
            if (editorType != TilesTypes.block and editorType != TilesTypes.target)
            {
                newTile.value = editorValue;
            }
            ds_grid_set(grid, hoveredX, hoveredY, newTile);
        }
        
        if (isAllRevealed())
        {
            saveMap();
        }
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
            if (hoveredX == xx and hoveredY == yy)
            {
                continue;
            }
            
			var tile = ds_grid_get(grid, xx, yy);
			
			tile.drawColor(xx, yy);
			tile.drawButton(xx, yy);
            tile.drawHover(xx, yy);   
            tile.drawPotential(xx, yy);
            tile.drawGrid(xx, yy);
		}
	}
    
    if (hoveredX != -1 and hoveredY != -1)
    {
        var tile = ds_grid_get(grid, hoveredX, hoveredY);
        
        tile.drawColor(hoveredX, hoveredY);
        tile.drawGrid(hoveredX, hoveredY);
        tile.drawButton(hoveredX, hoveredY);
        tile.drawHover(hoveredX, hoveredY);   
        tile.drawPotential(hoveredX, hoveredY);
    }
	
	removePotential();
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
		}
	}
    
    draw_sprite_stretched(s_icon, editorType, hoveredX * global.cellSize, hoveredY * global.cellSize + gameOffset, global.cellSize, global.cellSize);
    draw_sprite_stretched(s_value, editorValue, hoveredX * global.cellSize, hoveredY * global.cellSize + gameOffset, global.cellSize, global.cellSize);
    
    draw_set_color(c_lime);
    draw_set_alpha(0.25);
    draw_rectangle(editorStartingTileX * global.cellSize, editorStartingTileY * global.cellSize + gameOffset, editorStartingTileX * global.cellSize + global.cellSize, editorStartingTileY * global.cellSize + global.cellSize + gameOffset, false);
    draw_set_alpha(1);
}

//---

function drawEndScreen()
{ 
	gpu_set_zwriteenable(true);
	gpu_set_ztestenable(true);
	gpu_set_alphatestenable(true);
	gpu_set_cullmode(cull_clockwise);
	
	var buildingSizeWidth = global.width * global.cellSize * buildingScale;
	var buildingSizeHeight = global.height * global.cellSize * buildingScale;
	
	var shiftH = ((global.width * global.cellSize) - buildingSizeWidth) / 2;
	var shiftV = ((global.height * global.cellSize) - buildingSizeHeight) / 2;
	
	var centerX = shiftH + buildingSizeWidth/2;
	var centerY = shiftV + buildingSizeHeight/2 + gameOffset;
	
	matrix_set(matrix_world, matrix_build(centerX, centerY, 0, buildingTilt, 180 + buildingRotation + buildingFingerRotation, 0, buildingScale, buildingScale, buildingScale));
	vertex_submit(front, pr_trianglelist, surfaceTexture);
	matrix_set(matrix_world, matrix_build_identity());
	
	gpu_set_zwriteenable(false);
	gpu_set_ztestenable(false);
	gpu_set_alphatestenable(false);
	gpu_set_cullmode(cull_noculling);
}

//---

function saveMap()
{
    var file = file_text_open_write(global.level + ".txt");
    
    file_text_write_real(file, global.width);
    file_text_write_real(file, global.height);
    file_text_writeln(file);
    
    file_text_write_real(file, editorStartingTileX);
    file_text_write_real(file, editorStartingTileY);
    file_text_writeln(file);
    
    for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
            file_text_write_real(file, tile.type);
            file_text_write_real(file, tile.value);
            file_text_writeln(file);
        }
    }
    
    file_text_close(file);
}

function loadMap(lvl = global.level)
{
    var file = file_text_open_read(lvl + ".txt");
    
    global.width = file_text_read_real(file);
    global.height = file_text_read_real(file);
    
    grid = ds_grid_create(global.width, global.height);
    
    editorStartingTileX = file_text_read_real(file);
    editorStartingTileY = file_text_read_real(file);
    
    for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{ 
            var type = file_text_read_real(file);
            var value = file_text_read_real(file);
            
            var newTile = new Tile(type);
            newTile.value = value;
            ds_grid_set(grid, xx, yy, newTile);
        }
    }
    
    file_text_close(file);
    
    var tile;
    
    if (editorStartingTileX == -1 and editorStartingTileY == -1)
    {
        tile = ds_grid_get(grid, floor(global.width / 2), floor(global.height / 2));
    }
    else 
    {
    	tile = ds_grid_get(grid, editorStartingTileX, editorStartingTileY);
    }
	tile.isRevealed = true;
	tile.isAvailable = true;
}