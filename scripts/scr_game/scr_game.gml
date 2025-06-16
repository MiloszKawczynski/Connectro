function isAllRevealed()
{
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
            
            if (tile == 0)
            {
                return false;
            }
			
			if (!tile.isRevealed)
			{
				return false;
			}
		}
	}
	
	return true;
}

function removeDirections()
{
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
			tile.lineDirection = -1;
			tile.isLineDiag = false
			tile.sourceTile = noone;
		}
	}
	
	gameState = normal;
}

function removeTarget()
{
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
            if (tile.isTargeted)
            {
    			tile.isTargeted = false;
                tile.showScale = 0;
    			tile.sourceTile = noone;
            }
		}
	}
	
	gameState = normal;
}

function removePotential()
{
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
			tile.potential = 0;
		}
	}
}

function removeHover()
{
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
			
			tile.isHovered = false;
		}
	}
    
    hoveredX = -1;
    hoveredY = -1;
}

function getState()
{
    var state = ds_grid_create(global.width, global.height);
    
    for(var ix = 0; ix < global.width; ix++)
    {
        for(var iy = 0; iy < global.height; iy++)
        {
            var tile = ds_grid_get(grid, ix, iy);
            ds_grid_set(state, ix, iy, tile.isAvailable || tile.isRevealed);
        }
    }
    
    return state;
}

function normalTileEffect(showPotential = false)
{
	var tile = ds_grid_get(grid, hoveredX, hoveredY);
	if (tile == undefined)
    {
        return;
    }
    
	if (tile.isAvailable)
	{
        var state = getState();
        
		if (!showPotential)
		{
			tile.isRevealed = true;
			tile.isAvailable = false;
		}
		
		switch(tile.type)
		{
			case(TilesTypes.plus):
			{
                revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY + tile.value, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY - tile.value, tile.color, state, showPotential, tile.type);
                
				if (!showPotential)
				{
					audio_play_sound(sn_lvl2, 0, false);
					moves++;
				}
				
				break;
			}
			case(TilesTypes.cross):
			{
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY + tile.value, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY + tile.value, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY - tile.value, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY - tile.value, tile.color, state, showPotential, tile.type);
				
				if (!showPotential)
				{
					audio_play_sound(sn_lvl2, 0, false);
					moves++;
				}
				
				break;
			}
			case(TilesTypes.diamond):
			{
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY + tile.value, tile.color, state, showPotential, tile.type);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY - tile.value, tile.color, state, showPotential, tile.type);
				
				if (!showPotential)
				{
					audio_play_sound(sn_lvl3, 0, false);
					moves++;
				}
				
				break;
			}
			case(TilesTypes.line):
			{
				var rightDown = wrapAroundGrid(global.width, global.height, hoveredX + 1, hoveredY + 1);
				var leftUp = wrapAroundGrid(global.width, global.height, hoveredX - 1, hoveredY - 1);
				
				with(ds_grid_get(grid, rightDown.x, hoveredY))
				{
					if (type != TilesTypes.block)
					{
						lineDirection = 0;
                        showScale = 0;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, hoveredX, rightDown.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 1;
                        showScale = 0;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, hoveredY))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 2;
                        showScale = 0;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, hoveredX, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 3;
                        showScale = 0;
						sourceTile = tile;
					}
				}
				
				gameState = mustPickDirection;
				tile.isAvailable = true;
				break;
			}
			case(TilesTypes.lineDiag):
			{
				var rightDown = wrapAroundGrid(global.width, global.height, hoveredX + 1, hoveredY + 1);
				var leftUp = wrapAroundGrid(global.width, global.height, hoveredX - 1, hoveredY - 1);
				
				with(ds_grid_get(grid, rightDown.x, rightDown.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 0;
                        showScale = 0;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, rightDown.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 1;
                        showScale = 0;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 2;
                        showScale = 0;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, rightDown.x, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 3;
                        showScale = 0;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				gameState = mustPickDirection;
				tile.isAvailable = true;
				break;
			}
			case(TilesTypes.target):
			{
				for(var yy = 0; yy < global.height; yy++)
				{
					for(var xx = 0; xx < global.width; xx++)
					{
						with(ds_grid_get(grid, xx, yy))
						{
							if (!isRevealed)
							{
								isTargeted = true;
								sourceTile = tile;
							}
						}
					}
				}
				
				tile.isAvailable = true;
				gameState = mustPickTarget;
				break;
			}
		}
	}
}

function mustPickDirectionTileEffect(showPotential = false)
{
	var tile = ds_grid_get(grid, hoveredX, hoveredY);
    if (tile == undefined)
    {
        return;
    }
		
	if (tile.lineDirection == -1)
	{
		if (!showPotential)
		{
			removeDirections();
			return;
		}
	}
	else 
	{
        var state = getState();
        
		if (!showPotential)
		{
			moves++;
			audio_play_sound(sn_lvl1, 0, false);
		}
		
		if (tile.isLineDiag)
		{
			switch(tile.lineDirection)
			{
				case(0):
				{
					revealLine(hoveredX - 1, hoveredY - 1, hoveredX + tile.sourceTile.value - 1, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(1):
				{
					revealLine(hoveredX + 1, hoveredY - 1, hoveredX - tile.sourceTile.value + 1, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(2):
				{
					revealLine(hoveredX + 1, hoveredY + 1, hoveredX - tile.sourceTile.value + 1, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(3):
				{
					revealLine(hoveredX - 1, hoveredY + 1, hoveredX + tile.sourceTile.value - 1, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
			}
		}
		else 
		{
			switch(tile.lineDirection)
			{
				case(0):
				{
					revealLine(hoveredX - 1, hoveredY, hoveredX + tile.sourceTile.value - 1, hoveredY, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(1):
				{
					revealLine(hoveredX, hoveredY - 1, hoveredX, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(2):
				{
					revealLine(hoveredX + 1, hoveredY, hoveredX - tile.sourceTile.value + 1, hoveredY, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
				case(3):
				{
					revealLine(hoveredX, hoveredY + 1, hoveredX, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential, tile.sourceTile.type);
					break;
				}
			}
		}
		
		if (!showPotential)
		{
			tile.sourceTile.isAvailable = false;
		
			removeDirections();
            removeHover();
		}
		
		return;
	}
}

function mustPickTargetTileEffect(showPotential = false)
{
	var tile = ds_grid_get(grid, hoveredX, hoveredY);
	if (tile == undefined)
    {
        return;
    }	
    
	if (tile.isTargeted == false)
	{
		if (!showPotential)
		{
			removeTarget();
			return;
		}
	}
	else 
	{
		if (!showPotential)
		{
			moves++;
			audio_play_sound(sn_lvl1, 0, false);
		}
		
		revealDot(hoveredX, hoveredY, tile.sourceTile.color, showPotential, tile.sourceTile.type);
		
		if (!showPotential)
		{
			tile.sourceTile.isAvailable = false;
			
			removeTarget();
            removeHover();
		}
		
		return;
	}
}

function checkForUselessness(showPotential)
{
    if (showPotential)
    {
        return;
    }
    
    for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
    
        	if (tile == undefined)
            {
                continue;
            }
            
            var state = getState();
            var potential = 0;
    
    		switch(tile.type)
    		{
                case(TilesTypes.line):
    			{
    			}
                
    			case(TilesTypes.plus):
    			{
                    potential += revealLine(xx, yy, xx + tile.value, yy, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx - tile.value, yy, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx, yy + tile.value, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx, yy - tile.value, tile.color, state, 2, tile.type);
    				
    				break;
    			}
                
                case(TilesTypes.lineDiag):
    			{
                }
                
    			case(TilesTypes.cross):
    			{
    				potential += revealLine(xx, yy, xx + tile.value, yy + tile.value, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx - tile.value, yy + tile.value, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx - tile.value, yy - tile.value, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx + tile.value, yy - tile.value, tile.color, state, 2, tile.type);

    				break;
    			}
                
    			case(TilesTypes.diamond):
    			{
    				potential += revealLine(xx, yy, xx + tile.value, yy, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx - tile.value, yy, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx, yy + tile.value, tile.color, state, 2, tile.type);
    				potential += revealLine(xx, yy, xx, yy - tile.value, tile.color, state, 2, tile.type);
    				
    				break;
    			}
                
                case(TilesTypes.target):
    			{
    				potential = 1;
    				
    				break;
    			}
    		}
            
            if (potential == 0)
            {
                tile.isUseless = true;
            }
    	}
    }
}

function revealLine(x1, y1, x2, y2, _color, state, showPotential, revealingType, isDiamondRecursion = false)
{
    var sumOfPotential = 0;
	var length = point_distance(x1, y1, x2, y2);
	
	if (frac(length) != 0)
	{
		length /= sqrt(2);
	}
	
	var xStep = sign(x2 - x1);
	var yStep = sign(y2 - y1);
	
	var xx = x1;
	var yy = y1;
	
	var wrapped = wrapAroundGrid(global.width, global.height, x2, y2);
	var wrappedX2 = wrapped.x;
	var wrappedY2 = wrapped.y;
	
	for(var i = 0; i < length; i ++) 
	{
		xx += xStep;
		yy += yStep;
		
		position = wrapAroundGrid(global.width, global.height, xx, yy);
		
		xx = position.x;
		yy = position.y;
		
        var stateTile = ds_grid_get(state, xx, yy);
        
		with(ds_grid_get(grid, xx, yy))
		{
			if (type == TilesTypes.block)
			{
				return sumOfPotential;
			}
			
			if (xx = wrappedX2 and yy = wrappedY2)
			{
				if (!stateTile)
				{
					if (showPotential)
					{
                        if (showPotential == 2)
					    {
                            sumOfPotential = 3;
                        }
                        else 
                        {
                        	potential = 3;
                        }
					}
					else 
					{
						isAvailable = true;
                        setColorFromType();
						revealedByType = type;
					}
				}
			}
				
			if (!isRevealed and !isAvailable)
			{
				if (!showPotential)
				{
					color = _color;
					revealedByType = revealingType;
				}
			}
			
			if (showPotential)
			{
				if (potential == 0 and !isRevealed)
				{
                    if (showPotential == 2)
                    {
                        sumOfPotential = 1;
                    }
                    else 
                    {
					    potential = 1;
                    }
				}
			}
			else 
			{
				isRevealed = true; 
                
				//flashTimer = 0;
				
				//if (abs(xStep) == abs(yStep))
				//{
					//array_push(flashNext, { _x: -1, _y: 0, _power: 2});
					//array_push(flashNext, { _x: 1, _y: 0, _power: 2});
					//array_push(flashNext, { _x: 0, _y: -1, _power: 2});
					//array_push(flashNext, { _x: 0, _y: 1, _power: 2});
				//}
				//else 
				//{
					//array_push(flashNext, { _x: yStep, _y: xStep, _power: 2});
					//array_push(flashNext, { _x: -yStep, _y: -xStep, _power: 2});
				//}
			}
		}
		
		if (!isDiamondRecursion and revealingType == TilesTypes.diamond)
		{
			sumOfPotential += revealLine(xx, yy, xx + yStep * (length - i - 1), yy + xStep * (length - i - 1), _color, state, showPotential, revealingType, true);
			sumOfPotential += revealLine(xx, yy, xx - yStep * (length - i - 1), yy - xStep * (length - i - 1), _color, state, showPotential, revealingType, true);
		}
	}
    
    return sumOfPotential;
}

function revealDot(xx, yy, _color, showPotential, revealingType)
{
    var sumOfPotential = 0;
	with(ds_grid_get(grid, xx, yy))
	{
		if (type == TilesTypes.block)
		{
			return;
		}
		
		if (!isRevealed)
		{
			if (showPotential)
			{
                if (showPotential == 2)
                {
                    sumOfPotential = 3;
                }
                else 
                {
				    potential = 3;
                }
			}
			else 
			{
				isAvailable = true;
				setColorFromType();
				revealedByType = type;
			}
		}
			
		if (!isRevealed and !isAvailable)
		{
			if (!showPotential)
			{
				color = _color;
				revealedByType = revealingType;
			}
		}
		
		if (showPotential)
		{
			if (potential == 0 and !isRevealed)
			{
                if (showPotential == 2)
                {
                    sumOfPotential = 1;
                }
                else 
                {
				    potential = 1;
                }
			}
		}
		else 
		{
			isRevealed = true; 
			
			//flashTimer = 0;
			//array_push(flashNext, { _x: 0, _y: 1, _power: 2});
			//array_push(flashNext, { _x: 0, _y: -1, _power: 2});
			//array_push(flashNext, { _x: 1, _y: 0, _power: 2});
			//array_push(flashNext, { _x: -1, _y: 0, _power: 2});
			//
			//array_push(flashNext, { _x: 1, _y: 1, _power: 2});
			//array_push(flashNext, { _x: -1, _y: 1, _power: 2});
			//array_push(flashNext, { _x: -1, _y: -1, _power: 2});
			//array_push(flashNext, { _x: 1, _y: -1, _power: 2});
		}
	}
    
    return sumOfPotential;
}

#macro MAX_ITERATIONS 100

function wrapAroundGrid(width, height, xx, yy)
{
	var iterations = 0;

	while (true)
	{
		if (xx > width - 1)
		{
			var xxMod = xx mod width;
			xx = xxMod;
		}
		else if (xx < 0)
		{
			var xxMod = xx mod width;
			xx = width + xxMod;
		}
		else
		{
			break;
		}
		
		iterations += 1;
		
		if (iterations > MAX_ITERATIONS)
		{
			show_debug_message("Something went wrong with move wrapping. Iterations exceeded.");
			break;
		}
	}
	
	iterations = 0;
	
	while (true)
	{
		if (yy > height - 1)
		{
			var yyMod = yy mod height;
			yy = yyMod;
		}
		else if (yy < 0)
		{
			var yyMod = yy mod height;
			yy = height + yyMod;
		}
		else
		{
			break;
		}
		
		iterations += 1;
		
		if (iterations > MAX_ITERATIONS)
		{
			show_debug_message("Something went wrong with move wrapping. Iterations exceeded.");
			break;
		}
	}
	
	return global.mapObjects[xx][yy];
}

function readNumberFromSavedLevel(levelString, iterator)
{
	var value = "";
	for (; iterator < string_length(levelString); iterator++)
	{
		var char = string_char_at(levelString, iterator + 1);
		
		if (char == " " or char == "\n")
		{
			return { number: real(value), iterator: iterator + 1 };
		}
		
		value += char;
	}
}

function skipLineFromSavedLevel(levelString, iterator)
{
	for (; iterator < string_length(levelString); iterator++)
	{
		var char = string_char_at(levelString, iterator + 1);
		
		if (char == "\n")
		{
			return iterator + 1;
		}
	}
}

function skipHeaderFromSavedLevel(levelString, iterator)
{
	for (; iterator < string_length(levelString); iterator++)
	{
		var char = string_char_at(levelString, iterator + 1);
		
		if (char == ":")
		{
			return iterator + 1;
		}
	}
}

function deleteSavedData()
{
	if (file_exists(global.savedDataFilename))
	{
		file_delete(global.savedDataFilename);
	}
}

function saveLevel()
{
	var level = "";
	
	var height = global.height;
	var width = global.width;
	
	level += "l:" + string(global.choosedLevel) + "\n";
	level += "s:" + string(global.levels[global.choosedLevel].stars) + "\n";
	level += "m:" + string(global.levels[global.choosedLevel].moves) + "\n";
	level += string(width) + " " + string(height) + "\n";

	for (var yy = 0; yy < height; yy++)
	{
		for (var xx = 0; xx < width; xx++)
		{
			var tile = ds_grid_get(grid, xx, yy);
            
            level += string(tile.revealedByType);
			level += " ";
		}
	}
	
	level += "\n";
	
	// Load the buffer if it exists
	
	if (file_exists(global.savedDataFilename))
	{
		var buffer = buffer_load(global.savedDataFilename);
		var levelString = buffer_read(buffer, buffer_string);
		
		var levelPos = string_pos("l:" + string(global.choosedLevel), levelString);
			
		var bufferSize = buffer_get_size(buffer);
	
		var newBuffer = buffer_create(bufferSize + string_byte_length(level) + 1, buffer_fixed, 1);
			
		if (levelPos == 0)
		{
			buffer_seek(newBuffer, buffer_seek_start, 0);
			buffer_write(newBuffer, buffer_string, levelString + level);
			buffer_save(newBuffer, global.savedDataFilename);
			buffer_delete(newBuffer);
		}
		else
		{
		    // Find the next "l:" occurrence after this one
		    var offset = levelPos + 1;
		    var rest = string_copy(levelString, offset, string_length(levelString));
		    var relativeNextPos = string_pos("l:", rest);
    
		    var nextLevelPos;
		    if (relativeNextPos > 0)
			{
		        nextLevelPos = offset + relativeNextPos - 1;
		    }
			else
			{
		        nextLevelPos = string_length(levelString) + 1;
		    }

		    // Replace existing level data
		    var before = string_copy(levelString, 1, levelPos - 1);
		    var after = string_copy(levelString, nextLevelPos, string_length(levelString));
		    levelString = before + level + after;
			
			buffer_seek(buffer, buffer_seek_start, 0);
			buffer_write(buffer, buffer_string, levelString);
			buffer_save(buffer, global.savedDataFilename);
		}
		
		buffer_delete(buffer);
	}
	else
	{
		var buffer = buffer_create(string_byte_length(level) + 1, buffer_fixed, 1);
		buffer_write(buffer, buffer_string, level);
		buffer_save(buffer, global.savedDataFilename);
		buffer_delete(buffer);
	}
}

function loadLevels()
{
	var savedDataFilename = global.savedDataFilename;
	
	// There is nothing to load.
	if (!file_exists(savedDataFilename))
	{
		return;
	}
	
	var buffer = buffer_load(savedDataFilename);
	var levelString = buffer_read(buffer, buffer_string);
	
	// TODO: We should probably do the reverse - read the file and detect which levels are in.
	//       But for now that we have a small amount of levels it should be fine...
	var levelsCount = array_length(global.levels);
	for (var i = 0; i < levelsCount; i++)
	{
		loadLevel(levelString, i);
	}
}

function loadLevel(levelString, levelId)
{
	// Find the level in the file.
	var levelPos = string_pos("l:" + string(levelId), levelString);
	
	// The level is not saved.
	if (levelPos == 0)
	{
		return;
	}
	
	var iterator = levelPos - 1;
	
	iterator = skipLineFromSavedLevel(levelString, iterator);
	
	// Skip the star 's:' header.
	iterator = skipHeaderFromSavedLevel(levelString, iterator);
	
	var starsNumber = readNumberFromSavedLevel(levelString, iterator);
	iterator = starsNumber.iterator;
	global.levels[levelId].stars = starsNumber.number;
	
	// Skip the moves "m:" header.
	iterator = skipHeaderFromSavedLevel(levelString, iterator);
	
	var movesNumber = readNumberFromSavedLevel(levelString, iterator);
	iterator = movesNumber.iterator;
	global.levels[levelId].moves = movesNumber.number;
	
	var widthNumber = readNumberFromSavedLevel(levelString, iterator);
	var width = widthNumber.number;
	iterator = widthNumber.iterator;
	
	var heightNumber = readNumberFromSavedLevel(levelString, iterator);
	var height = heightNumber.number;
	iterator = heightNumber.iterator;
	
	// NOTE: This is hardcoded game room size
	var cellSize = 400 / width;

	var muralSurface = surface_create(width * cellSize, height * cellSize);
	
	surface_set_target(muralSurface);
	draw_clear_alpha(c_white, 1);
	
	var idx = 0;
	var value = "";
	for (; iterator < string_length(levelString); iterator++)
	{
		var currentValue = string_char_at(levelString, iterator + 1);
		
		if (currentValue == "\n")
		{
			break;
		}
		
		if (currentValue == " ")
		{
			var coords = getXYFromLinearIndex(width, idx);
			idx += 1;
			
			var newTile = new Tile(real(value));
			newTile.setColorFromType();
			newTile.drawMural(coords.x, coords.y, cellSize);
			
			value = "";
			continue;
		}
		
		value += currentValue;
	}
	
	surface_reset_target();
	
	var buildingSprite = global.levels[levelId].sprite;
    var spriteWidth = sprite_get_width(buildingSprite);
    var spriteHeight = sprite_get_height(buildingSprite);

	var blockSurface = surface_create(spriteWidth, spriteHeight);
	
	surface_set_target(blockSurface);
	draw_clear_alpha(c_white, 0);
	
	draw_surface_stretched(muralSurface, (width + 2) * 3 * 4 + 3, 3, width * 3, height * 3);
	draw_sprite(global.levels[levelId].sprite, 0, 0, 0);
	surface_reset_target();
	
	var surfaceTexture = sprite_get_texture(sprite_create_from_surface(blockSurface, 0, 0, spriteWidth, spriteHeight, false, false, 0, 0), 0);
	global.levels[levelId].texture = surfaceTexture;
}

function saveProgress()
{
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
        saveLevel();
    }
}