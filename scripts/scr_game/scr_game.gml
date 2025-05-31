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
			
			tile.isTargeted = false;
			tile.sourceTile = noone;
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
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY + tile.value, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY - tile.value, tile.color, state, showPotential);
				
				if (!showPotential)
				{
					audio_play_sound(sn_lvl2, 0, false);
					moves++;
				}
				
				break;
			}
			case(TilesTypes.cross):
			{
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY + tile.value, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY + tile.value, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY - tile.value, tile.color, state, showPotential);
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY - tile.value, tile.color, state, showPotential);
				
				if (!showPotential)
				{
					audio_play_sound(sn_lvl2, 0, false);
					moves++;
				}
				
				break;
			}
			case(TilesTypes.diamond):
			{
				revealLine(hoveredX, hoveredY, hoveredX + tile.value, hoveredY, tile.color, state, showPotential, true);
				revealLine(hoveredX, hoveredY, hoveredX - tile.value, hoveredY, tile.color, state, showPotential, true);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY + tile.value, tile.color, state, showPotential, true);
				revealLine(hoveredX, hoveredY, hoveredX, hoveredY - tile.value, tile.color, state, showPotential, true);
				
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
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, hoveredX, rightDown.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 1;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, hoveredY))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 2;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, hoveredX, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 3;
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
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, rightDown.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 1;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, leftUp.x, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 2;
						isLineDiag = true;
						sourceTile = tile;
					}
				}
				
				with(ds_grid_get(grid, rightDown.x, leftUp.y))
				{
					if (type != TilesTypes.block) 
					{
						lineDirection = 3;
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
					revealLine(hoveredX - 1, hoveredY - 1, hoveredX + tile.sourceTile.value - 1, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(1):
				{
					revealLine(hoveredX + 1, hoveredY - 1, hoveredX - tile.sourceTile.value + 1, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(2):
				{
					revealLine(hoveredX + 1, hoveredY + 1, hoveredX - tile.sourceTile.value + 1, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(3):
				{
					revealLine(hoveredX - 1, hoveredY + 1, hoveredX + tile.sourceTile.value - 1, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential);
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
					revealLine(hoveredX - 1, hoveredY, hoveredX + tile.sourceTile.value - 1, hoveredY, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(1):
				{
					revealLine(hoveredX, hoveredY - 1, hoveredX, hoveredY + tile.sourceTile.value - 1, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(2):
				{
					revealLine(hoveredX + 1, hoveredY, hoveredX - tile.sourceTile.value + 1, hoveredY, tile.sourceTile.color, state, showPotential);
					break;
				}
				case(3):
				{
					revealLine(hoveredX, hoveredY + 1, hoveredX, hoveredY - tile.sourceTile.value + 1, tile.sourceTile.color, state, showPotential);
					break;
				}
			}
		}
		
		if (!showPotential)
		{
			tile.sourceTile.isAvailable = false;
		
			removeDirections();
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
		
		revealDot(hoveredX, hoveredY, tile.sourceTile.color, showPotential);
		
		if (!showPotential)
		{
			tile.sourceTile.isAvailable = false;
			
			removeTarget();
		}
		
		return;
	}
}

function revealLine(x1, y1, x2, y2, _color, state, showPotential, isDiamond = false)
{
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
				return;
			}
			
			if (xx = wrappedX2 and yy = wrappedY2)
			{
				if (!stateTile)
				{
					if (showPotential)
					{
						potential = 3;
					}
					else 
					{
						isAvailable = true;
					}
				}
			}
				
			if (!isRevealed and !isAvailable)
			{
				if (!showPotential)
				{
					color = _color;
				}
			}
			
			if (showPotential)
			{
				if (potential == 0 and !isRevealed)
				{
					potential = 1;
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
		
		if (isDiamond)
		{
			revealLine(xx, yy, xx + yStep * (length - i - 1), yy + xStep * (length - i - 1), _color, state, showPotential);
			revealLine(xx, yy, xx - yStep * (length - i - 1), yy - xStep * (length - i - 1), _color, state, showPotential);
		}
	}
}

function revealDot(xx, yy, _color, showPotential)
{
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
				potential = 3;
			}
			else 
			{
				isAvailable = true;
			}
		}
			
		if (!isRevealed and !isAvailable)
		{
			if (!showPotential)
			{
				color = _color;
			}
		}
		
		if (showPotential)
		{
			if (potential == 0 and !isRevealed)
			{
				potential = 1;
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
}

function wrapAroundGrid(width, height, xx, yy)
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
	
	return global.mapObjects[xx][yy];
}