if (global.isEditorOn)
{
    for(var yy = 0; yy < global.height; yy++)
    {
    	for(var xx = 0; xx < global.width; xx++)
    	{
    		if (mouse_x > xx * global.cellSize and mouse_x < xx * global.cellSize + global.cellSize)
    		{
    			if (mouse_y - other.gameOffset > yy * global.cellSize and mouse_y - other.gameOffset < yy * global.cellSize + global.cellSize)
    			{
    				hoveredX = xx;
    				hoveredY = yy;
    			}
    		}
    	}
    }

    gameState();
}
else
{
    if (mouse_check_button_pressed(mb_left))
    {
        if (mouse_y < other.gameOffset or mouse_y > other.gameOffset + global.cellSize * global.height)
        {
            hoveredX = -1;
            hoveredY = -1;
            removeDirections();
            removePotential();
            removeTarget();
        }
    }
    
    for(var yy = 0; yy < global.height; yy++)
    {
        for(var xx = 0; xx < global.width; xx++)
        {
            if (mouse_x > xx * global.cellSize and mouse_x < xx * global.cellSize + global.cellSize)
            {
                if (mouse_y - other.gameOffset > yy * global.cellSize and mouse_y - other.gameOffset < yy * global.cellSize + global.cellSize)
                {
                    var newHoverTile = ds_grid_get(grid, xx, yy);
                    var hoverTile = ds_grid_get(grid, hoveredX, hoveredY);
                    
                    if (gameState == mustPickDirection)
                    {
                        if (hoverTile == undefined or newHoverTile == hoverTile.sourceTile)
                        {
                            break;
                        }
                    }
                    
                    if (mouse_check_button_pressed(mb_left))
                    {
                        if (newHoverTile != hoverTile)
                        {
                            if (gameState == mustPickDirection and newHoverTile.lineDirection == -1)
                            {
                                removeDirections();
                            }
                            
                            if (gameState == mustPickTarget and newHoverTile.isTargeted == false)
                            {
                                removeTarget();
                            }
                        }   
                        
                        if ((hoveredX == xx and hoveredY == yy))
                        {
                            gameState();
                        }
                        
                        hoveredX = xx;
                        hoveredY = yy;
                        
                        var hoverTile = ds_grid_get(grid, hoveredX, hoveredY);
                        if (gameState == mustPickTarget and hoverTile.isTargeted)
                        {
                            gameState();
                        }
                    }
                }
            }
        }
    }
}

if (isAllRevealed() and gameState == normal)
{
	drawSurface = true;
	gameState = gameEnd;
	drawState = endScreenTransitionDraw;
	audio_play_sound(sn_score, 0, true);
}

if (keyboard_check_pressed(ord("R")))
{
	audio_stop_all();
	room_restart();
}

if (keyboard_check_pressed(vk_escape))
{
	audio_stop_all();
	game_restart();
}