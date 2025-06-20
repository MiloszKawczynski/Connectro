if (keyboard_check_pressed(vk_f6))
{
    moves++;
}

if (keyboard_check_pressed(vk_f7))
{
    with(ui)
    {
        createPaintsCards(1);
        pushLayer(paintsLayer);
    }
}

with(ui)
{
    if (goBackButton.press)
    {
        goBackButton.setScale(1.2, 1.2);
    }
    else 
    {
    	goBackButton.setScale(1, 1);
    }
    
    if (restartButton.press)
    {
        restartButton.setScale(1.2, 1.2);
    }
    else 
    {
    	restartButton.setScale(1, 1);
    }
    
    var numberOfMoves = clamp(1 - (other.moves / other.levelToPlay.movesToStar[0]), 0, 1);
    var numberOfMovesToFirst = clamp(1 - (other.levelToPlay.movesToStar[0] / other.levelToPlay.movesToStar[0]), 0, 1);
    var numberOfMovesToSecond = clamp(1 - (other.levelToPlay.movesToStar[1] / other.levelToPlay.movesToStar[0]), 0, 1);
    var numberOfMovesToThird = clamp(1 - (other.levelToPlay.movesToStar[2] / other.levelToPlay.movesToStar[0]), 0, 1);
    
    movesCount.setContent(string(other.moves));
    movesBar.setValue(numberOfMoves);
    
    firstStarRing.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToFirst * movesBar.scaleX * movesBar.width);
    secondStarRing.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToSecond * movesBar.scaleX * movesBar.width - 8);
    thirdStarRing.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToThird * movesBar.scaleX * movesBar.width - 8);
    
    movesToFirstStar.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToFirst * movesBar.scaleX * movesBar.width + 3, 12);
    movesToSecondStar.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToSecond * movesBar.scaleX * movesBar.width - 5, 12);
    movesToThirdStar.setShift(-movesBar.scaleX * movesBar.width / 2 + numberOfMovesToThird * movesBar.scaleX * movesBar.width - 5, 12);
    
    if (other.moves > other.levelToPlay.movesToStar[0])
    {
        firstStarRing.setSprite(s_uiLimit);
        firstStar.isGold = false;
    }
    
    if (other.moves > other.levelToPlay.movesToStar[1])
    {
        secondStarRing.setSprite(s_uiLimit);
        secondStar.isGold = false;
    }
    
    if (other.moves > other.levelToPlay.movesToStar[2])
    {
        thirdStarRing.setSprite(s_uiLimit);
        thirdStar.isGold = false;
    }
}

ui.step();

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
    if (gameState != gameEnd)
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
                removeHover();
            }
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
                            if (gameState != gameEnd)
                            {
                                gameState();
                            }
                            break;
                        }
                        
                        removeHover();
                        hoveredX = xx;
                        hoveredY = yy;
                        
                        var hoverTile = ds_grid_get(grid, hoveredX, hoveredY);
                        hoverTile.isHovered = true;
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

if (isAllRevealed())
{
    if (gameState == normal)
    {
        if (!global.isRoguelikeMode)
        {
        	drawSurface = true;
    	    gameState = gameEnd;
    	    drawState = endScreenTransitionDraw;
            audio_play_sound(sn_score, 0, true);
            audio_sound_gain(sn_town, 0, 1000);
        }
        else 
        {
        	room_restart();
        }
    }
    
    if (gameState == gameEnd and !isDataSaved and !drawSurface)
    {
        isDataSaved = true;
        saveProgress();
    }
}

if (keyboard_check_pressed(ord("R")))
{
	audio_stop_sound(sn_score);
	room_restart();
}

if (keyboard_check_pressed(vk_escape))
{
	audio_stop_sound(sn_score);
	game_restart();
}

if (keyboard_check_pressed(vk_backspace))
{
    fade = true;
    fadeFunction = goBackFunctionFade;
}