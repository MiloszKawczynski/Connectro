#macro SOLUTION_PRINT_PATH true
#macro SOLUTION_PRINT_STARS false

function defineTiles()
{
	enum TilesTypes 
	{
		plus,
		diamond,
		line,
		lineDiag,
		cross,
		target,
		block,
		lineDirection,
	}
}

function Tile(_type) constructor 
{
	type = _type;
	isRevealed = false;
	isAvailable = false;
	lineDirection = -1;
	isLineDiag = false;
	sourceTile = noone;
	color = noone;
	potential = 0;
	isTargeted = false;
	flash = 0;
	flashTimer = -1;
	flashNext = array_create(0);
    isHovered = false;
	
	switch(type)
	{
		case(TilesTypes.plus):
		{
			value = irandom_range(2, 5);
			color = make_color_rgb(115, 74, 219);
			break;
		}
		
		case(TilesTypes.cross):
		{
			value = irandom_range(2, 5);
			color = make_color_rgb(136, 203, 237);
			break;
		}
		
		case(TilesTypes.diamond):
		{
			value = choose(1, 1, 1, 2, 2, 3);
			color = make_color_rgb(222, 98, 172);
			break;
		}
		
		case(TilesTypes.line):
		{
			value = irandom_range(3, 5);
			color = make_color_rgb(255, 205, 17);
			break;
		}
		
		case(TilesTypes.lineDiag):
		{
			value = irandom_range(2, 4);
			color = make_color_rgb(191, 245, 56);
			break;
		}
		
		case(TilesTypes.target):
		{
			value = 0;
			color = make_color_rgb(255, 0, 0);
			break;
		}
		
		case(TilesTypes.block):
		{
			value = 0;
			color = c_black;
			isRevealed = true;
			break;
		}
	}
    
    setColorFromType();
    
    static setColorFromType = function()
    { 
        switch(type)
    	{
    		case(TilesTypes.plus):
    		{
    			color = make_color_rgb(115, 74, 219);
    			break;
    		}
    		
    		case(TilesTypes.cross):
    		{
    			color = make_color_rgb(136, 203, 237);
    			break;
    		}
    		
    		case(TilesTypes.diamond):
    		{
    			color = make_color_rgb(222, 98, 172);
    			break;
    		}
    		
    		case(TilesTypes.line):
    		{
    			color = make_color_rgb(255, 205, 17);
    			break;
    		}
    		
    		case(TilesTypes.lineDiag):
    		{
    			color = make_color_rgb(191, 245, 56);
    			break;
    		}
    		
    		case(TilesTypes.target):
    		{
    			color = make_color_rgb(255, 0, 0);
    			break;
    		}
    		
    		case(TilesTypes.block):
    		{
    			color = c_black;
    			break;
    		}
    	}
    }
	
	static drawColor = function(xx, yy) 
	{
		if (isRevealed)
		{
			if (type == TilesTypes.block)
			{
				draw_sprite_stretched(s_icon, type, xx * global.cellSize, yy * global.cellSize + other.gameOffset, global.cellSize, global.cellSize); 
			}
			else 
			{
				draw_set_color(color);
				draw_set_alpha(0.45);	
				draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
				draw_set_alpha(1);
			}
		}
		
		if (flashTimer >= 0)
		{
			flash = animcurve_get_point(ac_start, 0, flashTimer);
			flashTimer += 0.01;
			
			if (flashTimer >= 0.1)
			{
				for(var i = 0; i < array_length(flashNext); i++)
				{
					var wrappedFlash = wrapAroundGrid(global.width, global.height, xx + flashNext[i]._x, yy + flashNext[i]._y);
					if (flashNext[i]._power == 1)
					{
						break;
					}
					
					with(ds_grid_get(o_connectro.grid, wrappedFlash.x, wrappedFlash.y))
					{
						array_push(flashNext, { _x: other.flashNext[i]._x, _y: other.flashNext[i]._y, _power: other.flashNext[i]._power - 1});
						flash = 0;
						flashTimer = 0;
					}
				}
				
				array_delete(flashNext, 0, array_length(flashNext));
			}
			
			if (flashTimer >= 1)
			{
				flashTimer = -1;
				flash = 0;
			}
		}
		
		if (flash > 0 and !isRevealed)
		{
			draw_set_color(color);
			draw_set_alpha(flash);	
			draw_sprite_stretched(s_icon, type, xx * global.cellSize, yy * global.cellSize + other.gameOffset, global.cellSize, global.cellSize); 
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
			draw_set_alpha(1);
		}
	}
	
	static drawMural = function(xx, yy) 
	{
        if (type == TilesTypes.target)
        {
            draw_set_color(make_color_rgb(214, 75, 34));
        }
        else 
        {
        	draw_set_color(color);
        }
		draw_set_alpha(1);	
		draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
		draw_set_alpha(1);
	}
	
	static drawButton = function(xx, yy)
	{
        var float = 1;
        var blink = 0;
            
        if (isHovered)
        {
            float = power(sin(current_time / 500), 2) * 0.25 + 1;
        }
        
        var scale = global.cellSize * float;
        var xPos = xx * global.cellSize - scale / 2 + global.cellSize / 2;
        var yPos = yy * global.cellSize + other.gameOffset - scale / 2 + global.cellSize / 2;
        
		if (isAvailable)
		{
            draw_set_color(color);
			draw_set_alpha(0.25);	
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
			draw_set_alpha(1);
            
            if (lineDirection == -1)
            {
    			draw_sprite_stretched(s_icon, type, xPos, yPos, scale, scale); 
			    draw_sprite_stretched(s_value, value, xPos, yPos, scale, scale);
            }
		}
		
		if (lineDirection != -1)
		{
            if (isHovered)
            {
                blink = 1;
            }
            else 
            {
                if (sourceTile.isHovered)
                {
                    blink = sin(current_time / 500 - (pi / 2) * lineDirection);
                }
            }
            
            draw_set_color(sourceTile.color);
			draw_set_alpha(0.25 + blink * 0.5);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
            draw_set_alpha(1);
            
            var spr = s_arrowStreight;
            
			if (isLineDiag)
			{
				spr = s_arrowDiagonal;
			}
            
            draw_sprite_stretched(spr, lineDirection, xPos, yPos, scale, scale); 
		}
		
		if (isTargeted)
		{
			draw_set_color(c_red);
			draw_sprite_stretched(s_target, 0, xx * global.cellSize, yy * global.cellSize + other.gameOffset, global.cellSize, global.cellSize);
			draw_set_alpha(0.25 + power(sin(current_time / 500), 2) * 0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
			draw_set_alpha(1);
		}
	}
	
	static drawPotential = function(xx, yy)
	{
		if (potential != 0)
		{
			draw_set_color(c_white);
			draw_set_alpha(0.3 * potential * power(sin(current_time / 500), 2) + 0.1);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
			draw_set_alpha(1);
		}
	}
	
	static drawHover = function(xx, yy)
	{
		if (isHovered and isAvailable)
		{
			draw_set_color(c_white);
			draw_set_alpha(0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, false);
			draw_set_alpha(1);
		}
	}
    
    static drawGrid = function(xx, yy)
    {
        draw_set_color(c_black);
		draw_rectangle(xx * global.cellSize, yy * global.cellSize + other.gameOffset, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize + other.gameOffset, true);
    }
}

function populateGrid()
{
	tileChances = array_create(0);
	
	repeat(global.crossRatio)
	{
		array_push(tileChances, TilesTypes.cross);
	}
	
	repeat(global.plusRatio)
	{
		array_push(tileChances, TilesTypes.plus);
	}
	
	repeat(global.diamondRatio)
	{
		array_push(tileChances, TilesTypes.diamond);
	}
	
	repeat(global.lineRatio)
	{
		array_push(tileChances, TilesTypes.line);
	}
	
	repeat(global.diagRatio)
	{
		array_push(tileChances, TilesTypes.lineDiag);
	}
	
	repeat(global.blockRatio)
	{
		array_push(tileChances, TilesTypes.block);
	}
	
	repeat(global.targetRatio)
	{
		array_push(tileChances, TilesTypes.target);
	}
	
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var type = array_shuffle(tileChances)[0];
			ds_grid_add(grid, xx, yy, new Tile(type));
		}
	}
	
	var tile = ds_grid_get(grid, floor(global.width / 2), floor(global.height / 2));
	if (tile.type == TilesTypes.block)
	{
		var arr = array_shuffle(tileChances);
		var i = 0;
		while(arr[i] == TilesTypes.block)
		{
			i++;
		}
		
		ds_grid_add(grid, floor(global.width / 2), floor(global.height / 2), new Tile(arr[i]));
	}
	
	tile = ds_grid_get(grid, floor(global.width / 2), floor(global.height / 2));
	tile.isRevealed = true;
	tile.isAvailable = true;
}

function applayLevelIntro()
{
    enum IntroTypes 
	{
		horizontalLines,
		verticalLines,
	}
    
    var introType = choose(IntroTypes.horizontalLines, IntroTypes.verticalLines)
	
	switch(introType)
	{
		case(IntroTypes.horizontalLines):
		{
			for(var i = 0; i < global.height; i++)
			{
				if (i mod 2 == 0)
				{
					tile = ds_grid_get(grid, 0, i);
					tile.flashTimer = 0;
					array_push(tile.flashNext, { _x: 1, _y: 0, _power: global.width});
				}
				else 
				{
					tile = ds_grid_get(grid, global.width - 1, i);
					tile.flashTimer = 0;
					array_push(tile.flashNext, { _x: -1, _y: 0, _power: global.width});
				}
			}
			break;
		}
		
		case(IntroTypes.verticalLines):
		{
			for(var i = 0; i < global.width; i++)
			{
				if (i mod 2 == 0)
				{
					tile = ds_grid_get(grid, i, 0);
					tile.flashTimer = 0;
					array_push(tile.flashNext, { _x: 0, _y: 1, _power: global.height});
				}
				else 
				{
					tile = ds_grid_get(grid, i, global.height - 1);
					tile.flashTimer = 0;
					array_push(tile.flashNext, { _x: 0, _y: -1, _power: global.height});
				}
			}
			break;
		}
	}
}

function toMapKey(tileCoords)
{
	return global.mapKeys[tileCoords.x][tileCoords.y];
}

function arrayUniqueStructByKey(arr)
{
	var seen = ds_map_create();
	var result = [];

	for (var i = 0; i < array_length(arr); i++) {
		var key = toMapKey(arr[i]);
		if (!ds_map_exists(seen, key)) {
			ds_map_add(seen, key, true);
			array_push(result, arr[i]);
		}
	}

	ds_map_destroy(seen);
	return result;
}

function printStackAndClear(stack)
{
	show_debug_message("STACK (top to bottom):");

	while (!ds_stack_empty(stack))
	{
		var val = ds_stack_pop(stack);
		show_debug_message("  " + string(val));
	}
}

enum HeuristicType
{
	Naive,
	GetRevealed3,
}

function checkSolvability(heuristic)
{
	if (!SOLUTION_PRINT_STARS)
	{
		global.solutionFile = file_text_open_append("solutions.txt");
	}
	
	var aStar = true;
	global.solveTimeStart = get_timer();
	
	var solution = undefined;
	
	if (aStar)
	{
		solution = runAStar(heuristic);
	}
	else
	{
		runDFS();
	}
	
	if (!SOLUTION_PRINT_STARS)
	{
		file_text_close(global.solutionFile);
	}
	
	return solution;
}

function getAvailableOrRevealedCount(tileCount, buffer)
{
	buffer_seek(buffer, buffer_seek_start, 0);
	var sum = 0;
	for (var i = 0; i < tileCount; i++)
	{
		if (buffer_read(buffer, buffer_u8))
		{
			sum += 1;
		}
	}
	
	return sum;
}

function solveGame()
{
	var gamesToSolve = global.gamesToSolve;
	var gamesToSolveOriginal = gamesToSolve;
	
	var foundNaive = false;
	var foundRevealed3 = false;
	
	var revealed3Solution = checkSolvability(HeuristicType.GetRevealed3);
	
	if (global.gamesToSolve != gamesToSolve)
	{
		foundRevealed3 = true;
	}
	
	gamesToSolve = global.gamesToSolve;
	
	var naiveSolution = checkSolvability(HeuristicType.Naive);
	
	if (global.gamesToSolve != gamesToSolve)
	{
		foundNaive = true;
	}

	if (foundNaive && foundRevealed3)
	{
		global.gamesToSolve = gamesToSolveOriginal - 1;
		
		if (SOLUTION_PRINT_STARS)
		{
			global.solutionFile = file_text_open_append("solutions.txt");
			var msg = revealed3Solution + naiveSolution;
			file_text_write_string(global.solutionFile, msg);
			show_debug_message(msg);
			file_text_close(global.solutionFile);
		}
	}
	else
	{
		global.gamesToSolve = gamesToSolveOriginal;
	}

	room_restart();
}

function getLinearTileIndex(width, xx, yy)
{
	return yy * width + xx;
}

function getXYFromLinearIndex(width, index)
{
	var xx = index % width;
	var yy = floor(index / width);
	return global.mapObjects[xx][yy];
}

enum TileType
{
	Unrevealed = 0,
	Revealed = 1,
	Active = 2,
}

function getWhichTilesRevealWhich(tilesToRevealCount, width, height, gridState, tilesRevealedTiles, tilesUsedTiles)
{
	var gridStateTemp = buffer_create(tilesToRevealCount, buffer_fast, 1);
	buffer_copy(gridState, 0, tilesToRevealCount, gridStateTemp, 0);
	
	for (var column = 0; column < height; column++)
	{
		for (var row = 0; row < width; row++)
		{
			var index = getLinearTileIndex(width, row, column);
			var tile = ds_grid_get(grid, row, column);
			
			if (tile.type == TilesTypes.block)
			{
				continue;
			}

			var decisions = 1;
				
			if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
			{
				decisions = 4;
			}
			else if (tile.type == TilesTypes.target)
			{
				decisions = tilesToRevealCount;
			}
			
			for (var d = 0; d < decisions; d++)
			{
				var newGridState = buffer_create(tilesToRevealCount, buffer_fast, 1);
				buffer_copy(gridStateTemp, 0, tilesToRevealCount, newGridState, 0);

				var usedTile = getRevealedTiles(width, height, tile, row, column, newGridState, d);
				tilesUsedTiles[row][column][d] = usedTile;

				buffer_seek(newGridState, buffer_seek_start, index);
				buffer_write(newGridState, buffer_u8, TileType.Revealed);
				
				buffer_seek(newGridState, buffer_seek_start, 0);
				buffer_seek(gridStateTemp, buffer_seek_start, 0);
				
				var newTile = 0;
				for (var i = 0; i < tilesToRevealCount; i++)
				{
					var previousState = buffer_read(gridStateTemp, buffer_u8);
					var newState = buffer_read(newGridState, buffer_u8);
					if (newState != previousState and previousState != TileType.Active and index != i)
					{
						tilesRevealedTiles[row][column][d][newTile] = {index: i, state: newState};
						newTile += 1;
					}
				}
				
				buffer_delete(newGridState);
			}
		}
	}
}

function greedyMinimalMoves(width, height, tilesToRevealCount, unreaveledCount, tilesRevealedTiles, gridState, tilesSortedByRevealCount, tilesSortedByRevealCountLength)
{
	var uncovered = buffer_create(tilesToRevealCount, buffer_fast, 1);
	buffer_copy(gridState, 0, tilesToRevealCount, uncovered, 0);
	
	var moveCount = 0;
	
	while (unreaveledCount > 0)
	{
		var bestCoverage = 0;
		var bestTile = undefined;
		var bestDecision = 0;
		
		for (var t = 0; t < tilesSortedByRevealCountLength; t++)
		{
			if (bestCoverage > tilesSortedByRevealCount[t].revealCount + 1)
			{
				break;
			}
			
			var index = tilesSortedByRevealCount[t].index;
			var tileCoords = tilesSortedByRevealCount[t].tileCoords;
				
			// This tile cannot be used anymore.
			buffer_seek(uncovered, buffer_seek_start, index);
			if (buffer_read(uncovered, buffer_u8) == TileType.Revealed)
			{
				continue;
			}
				
			var tile = ds_grid_get(grid, tileCoords.x, tileCoords.y);
				
			var decisions = 1;
				
			if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
			{
				decisions = 4;
			}
			else if (tile.type == TilesTypes.target)
			{	
				decisions = tilesToRevealCount;
			}
				
			for (var i = 0; i < decisions; i++)
			{
				var revealedCount = getRevealedTilesCountFromCache(tileCoords.x, tileCoords.y, tilesRevealedTiles, uncovered, i);
				revealedCount += 1; // Itself
				
				if (revealedCount > bestCoverage)
				{
					bestCoverage = revealedCount;
					bestTile = tileCoords;
					bestDecision = i;
				}
			}
		}
		
		moveCount += 1;
		unreaveledCount -= bestCoverage;
		
		getRevealedTilesFromCacheSetActive(bestTile.x, bestTile.y, tilesRevealedTiles, uncovered, bestDecision);
		
		var index = getLinearTileIndex(width, bestTile.x, bestTile.y);
		buffer_seek(uncovered, buffer_seek_start, index);
		buffer_write(uncovered, buffer_u8, TileType.Revealed);
	}
	
	buffer_delete(uncovered);
	
	return moveCount;
}

function getMostRevealed(tilesToRevealCount, tilesSortedByRevealCount, gridState)
{
	for (var i = 0; i < tilesToRevealCount; i++)
	{
		buffer_seek(gridState, buffer_seek_start, tilesSortedByRevealCount[i].index);
		if (buffer_read(gridState, buffer_u8) != TileType.Revealed)
		{
			return tilesSortedByRevealCount[i].revealCount; 
		}
	}
}

function getMostRevealed2(tilesToRevealCount, currentTilesToRevealCount, tilesSortedByRevealCount, gridState)
{
	var tilesLeft = currentTilesToRevealCount;
	var numberOfMoves = 0;
	for (var i = 0; i < tilesToRevealCount; i++)
	{
		buffer_seek(gridState, buffer_seek_start, tilesSortedByRevealCount[i].index);
		if (buffer_read(gridState, buffer_u8) != TileType.Revealed)
		{
			tilesLeft -= tilesSortedByRevealCount[i].revealCount;
			
			numberOfMoves += 1;
			
			if (tilesLeft <= 0)
			{
				return numberOfMoves;
			}
		}
	}
	
	return 999;
}

function getMostRevealed3(tilesToRevealCount, currentTilesToRevealCount, tilesSortedByRevealCount, gridState, tilesRevealedTiles)
{
	var tilesLeft = currentTilesToRevealCount;
	var bestTileLeft = tilesLeft;
	
	var len = array_length(tilesSortedByRevealCount);
	for (var i = 0; i < len; i++)
	{
		var tileCoords = tilesSortedByRevealCount[i].tileCoords;
		buffer_seek(gridState, buffer_seek_start, tilesSortedByRevealCount[i].index);
		if (buffer_read(gridState, buffer_u8) == TileType.Active)
		{
			var tile = ds_grid_get(grid, tileCoords.x, tileCoords.y);
				
			var decisions = 1;
				
			if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
			{
				decisions = 4;
			}
			else if (tile.type == TilesTypes.target)
			{	
				decisions = tilesToRevealCount;
			}
				
			for (var d = 0; d < decisions; d++)
			{
				var tilesLeftAfterMove = tilesLeft - getRevealedTilesCountFromCache(tileCoords.x, tileCoords.y, tilesRevealedTiles, gridState, d);
				
				if (tilesLeftAfterMove < bestTileLeft)
				{
					bestTileLeft = tilesLeftAfterMove;
				}
			}
		}
	}
	
	return bestTileLeft;
}

function runAStar(heuristic)
{
	var width = global.width;
	var height = global.height;
	var tilesToRevealCount = width * height;

	var startingTile = getStartingTile();
	
	var tilesSortedByRevealCount = [];
	var tilesSortedByRevealCountLength = 0;
	var tilesRevealedTiles = array_create();
	
    for (var _x = 0; _x < global.width; _x++)
    {
        var tr = array_create();
        
        for (var _y = 0; _y < global.height; _y++)
        {
            array_push(tr, []);
        }
        
        array_push(tilesRevealedTiles, tr);
    }
	
	var gridState = buffer_create(tilesToRevealCount, buffer_fast, 1);
	buffer_fill(gridState, 0, buffer_u8, TileType.Unrevealed, tilesToRevealCount);
	
	buffer_seek(gridState, buffer_seek_start, getLinearTileIndex(width, startingTile.x, startingTile.y));
	buffer_write(gridState, buffer_u8, TileType.Active);
	
	for (var column = 0; column < height; column++)
	{
		for (var row = 0; row < width; row++)
		{
			var index = getLinearTileIndex(width, row, column);
			var tile = ds_grid_get(grid, row, column);
			
			if (tile.type == TilesTypes.block)
			{
				buffer_seek(gridState, buffer_seek_start, index);
				buffer_write(gridState, buffer_u8, TileType.Revealed);
			}
			else if (tile.type == TilesTypes.cross or tile.type == TilesTypes.plus)
			{
				var revealCount = tile.value * 4;
				
				array_push(tilesSortedByRevealCount, {tileCoords: global.mapObjects[row][column], index: index, revealCount: revealCount, hasDecision: false});
				
				array_push(tilesRevealedTiles[row][column], []);
			}
			else if (tile.type == TilesTypes.diamond)
			{
				var revealCount = ceil(tile.value / 2.0) * 4 + ((tile.value - 1) * 8);
				
				array_push(tilesSortedByRevealCount, {tileCoords: global.mapObjects[row][column], index: index, revealCount: revealCount, hasDecision: false});
				
				array_push(tilesRevealedTiles[row][column], []);
			}
			else if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
			{
				var revealCount = tile.value;
				
				array_push(tilesSortedByRevealCount, {tileCoords: global.mapObjects[row][column], index: index, revealCount: revealCount, hasDecision: true});
				
				for (var i = 0; i < 4; i++)
				{
					array_push(tilesRevealedTiles[row][column], []);
				}
				
			}
			else if (tile.type == TilesTypes.target)
			{
				var revealCount = 1;
				
				array_push(tilesSortedByRevealCount, {tileCoords: global.mapObjects[row][column], index: index, revealCount: revealCount, hasDecision: true});
				
				for (var i = 0; i < tilesToRevealCount; i++)
				{
					array_push(tilesRevealedTiles[row][column], []);
				}
			}
		}
	}
	
	array_sort(tilesSortedByRevealCount, function(a, b)
	{
		var diff = b.revealCount - a.revealCount;
		if (diff != 0)
		{
			return diff;
		}
		
		if (b.hasDecision and not a.hasDecision)
		{
			return -1;
		}
		else if (a.hasDecision and not b.hasDecision)
		{
			return 1;
		}
		
		return 0;
	});

	tilesSortedByRevealCountLength = array_length(tilesSortedByRevealCount);

	var tilesUsedTiles = variable_clone(tilesRevealedTiles);
	getWhichTilesRevealWhich(tilesToRevealCount, width, height, gridState, tilesRevealedTiles, tilesUsedTiles);
	
	var initiallyRevealedCount = getAvailableOrRevealedCount(tilesToRevealCount, gridState);

	var queue = ds_priority_create();
	
	if (SOLUTION_PRINT_PATH)
	{
		var initialState = {
			gridState: gridState,
			revealedCount: initiallyRevealedCount,
			g: 0,
			path: []
		};
		ds_priority_add(queue, initialState, 0);
	}
	else
	{
		var initialState = {
			gridState: gridState,
			revealedCount: initiallyRevealedCount,
			g: 0,
		};
		ds_priority_add(queue, initialState, 0);
	}

	while (!ds_priority_empty(queue))
	{
		var time = get_timer();
		if ((time - global.solveTimeStart) > (maxSearchTime * 60000000))
		{
			var msg = string("SEARCH FOR OVER {0} MINUTES\n", maxSearchTime);
			msg += "\n---\n";
			file_text_write_string(global.solutionFile, msg);
			show_debug_message(msg);
			// TODO: Clear buffers
			ds_priority_destroy(queue);
			return;
		}
		
		var state = ds_priority_delete_min(queue);

		var revealedCount = state.revealedCount;
		if (revealedCount == tilesToRevealCount)
		{
			var msg = "";
			if (!SOLUTION_PRINT_STARS)
			{
				msg = "SOLUTION FOUND:\n";
				msg += string("seed: {0}\n", getSeed());
			
				if (SOLUTION_PRINT_PATH)
				{
					for (var i = 0; i < array_length(state.path); i++)
					{
						if (state.path[i] == "Decision")
						{
							msg += "  Decision: ";
							continue;
						}
				
						var step = state.path[i];
						msg += "  " + string(step.x) + "," + string(step.y) + "\n";
					}
				}
		

				msg += string("Number of moves {0}\n", state.g);
				msg += string("time: {0}\n", (get_timer() - global.solveTimeStart) / 60000000);
				msg += "\n---\n";
				file_text_write_string(global.solutionFile, msg);
				show_debug_message(msg);
			}
			else
			{
				if (heuristic == HeuristicType.Naive)
				{
					var star1 = floor((state.g + 10) / 5.0) * 5.0;
					msg += string("{0}, {1}])),", state.g, star1);
					
					
					msg += "\n---\n";
				}
				else if (heuristic == HeuristicType.GetRevealed3)
				{
					msg = "SOLUTION FOUND:\n";
					msg += string("new level(\"{0}\", , , [{1}, ", getSeed(), state.g);
				}
				
			}
			
			buffer_delete(state.gridState);
			ds_priority_destroy(queue);
			global.gamesToSolve--;
			
			if (SOLUTION_PRINT_STARS)
			{
				return msg;
			}
			
			return;
		}

		for (var column = 0; column < height; column++)
		{
			for (var row = 0; row < width; row++)
			{
				var index = getLinearTileIndex(width, row, column);
				
				buffer_seek(state.gridState, buffer_seek_start, index);

				if (buffer_read(state.gridState, buffer_u8) != TileType.Active)
				{
					continue;
				}
				
				var tile = ds_grid_get(grid, row, column);
				
				var decisions = 1;
				
				if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
				{
					decisions = 4;
				}
				else if (tile.type == TilesTypes.target)
				{
					decisions = tilesToRevealCount;
				}
				
				for (var d = 0; d < decisions; d++)
				{
					var newGridState = buffer_create(tilesToRevealCount, buffer_fast, 1);
					buffer_copy(state.gridState, 0, tilesToRevealCount, newGridState, 0);

					//var usedTile = getRevealedTiles(width, height, tile, row, column, newGridState, d);
					var newlyRevealedCount = getRevealedTilesFromCache(row, column, tilesRevealedTiles, newGridState, d);
					
					if (newlyRevealedCount == 0)
					{
						continue;
					}

					buffer_seek(newGridState, buffer_seek_start, index);
					buffer_write(newGridState, buffer_u8, TileType.Revealed);
					
					var newRevealedCount = newlyRevealedCount + revealedCount;

					var nextPath;
					if (SOLUTION_PRINT_PATH)
					{
						nextPath = [];
						array_copy(nextPath, 0, state.path, 0, array_length(state.path));
						array_push(nextPath, global.mapObjects[row][column]);
					
						var usedTile = tilesUsedTiles[row][column][d];
						if (usedTile != undefined)
						{
							array_push(nextPath, global.decisionString);
							array_push(nextPath, usedTile);
						}
					}

					var g = state.g + 1;

					//var numberOfMoves = getMostRevealed2(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState);
					
					//if (numberOfMoves == 999)
					//{
						//continue;
					//}
					
					//var h = numberOfMoves;
					
					//var mostPossiblyRevealed = getMostRevealed(tilesToRevealCount, tilesSortedByRevealCount, newGridState);	
					//var h = getMostRevealed3(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState, tilesRevealedTiles);
					//var h = ceil(getMostRevealed3(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState, tilesRevealedTiles) / 24.0);
					//var h = ceil(((tilesToRevealCount - newRevealedCount) / mostPossiblyRevealed));
					//var h = ceil(((tilesToRevealCount - newRevealedCount) / mostPossiblyRevealed) - mostPossiblyRevealed);
					//var h = ceil((tilesToRevealCount - newRevealedCount) / 24.0);
					//var h = greedyMinimalMoves(width, height, tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesRevealedTiles, gridState, tilesSortedByRevealCount, tilesSortedByRevealCountLength);
					//var h = tilesToRevealCount - newRevealedCount;
                    //var h = round((tilesToRevealCount - newRevealedCount) / 24.0);
                    //var h = ceil((tilesToRevealCount - newRevealedCount) / 24.0) + ceil(getMostRevealed3(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState, tilesRevealedTiles) / 24.0);
                    //var h = ceil((tilesToRevealCount - newRevealedCount) / 24.0);
                    
                    
                    // NOTE: Heuristic that matters
                    
                    // NAIVE
					var h = 0;
					
					if (heuristic == HeuristicType.Naive)
					{
						h = tilesToRevealCount - newRevealedCount;
					}
					else if (heuristic == HeuristicType.GetRevealed3)
					{
						h = ceil((tilesToRevealCount - newRevealedCount) / 24.0) + getMostRevealed3(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState, tilesRevealedTiles);
					}
					
					var priority = g + h;

					if (SOLUTION_PRINT_PATH)
					{
						ds_priority_add(queue, {
							gridState: newGridState,
							revealedCount: newRevealedCount,
							g: g,
							path: nextPath
						}, priority);
					}
					else
					{
						ds_priority_add(queue, {
							gridState: newGridState,
							revealedCount: newRevealedCount,
							g: g,
						}, priority);
					}
				}
			}
		}
		
		buffer_delete(state.gridState);
	}

	ds_priority_destroy(queue);
	var msg = "No solution found.";
	msg += "\n---\n";
	file_text_write_string(global.solutionFile, msg);
	show_debug_message(msg);
}

function runDFS()
{
	var tilesToRevealCount = global.width * global.height;
	var revealedTiles = ds_map_create();
	ds_map_add(revealedTiles, toMapKey(getStartingTile()), false);
	
	var solution = ds_stack_create();
	
	for (var column = 0; column < global.height; column++)
	{
		for (var row = 0; row < global.width; row++)
		{
			var tile = ds_grid_get(grid, row, column);
			
			if (tile.type == TilesTypes.block)
			{
				ds_map_add(revealedTiles, toMapKey(global.mapObjects[row][column]), false);
			}
		}
	}
	
	var found = checkTileRecursive([getStartingTile()], revealedTiles, tilesToRevealCount, solution);
	
	show_debug_message(found);
	
	printStackAndClear(solution);
	
	ds_stack_destroy(solution);
	
	ds_map_destroy(revealedTiles);
}

function checkTileRecursive(availableTiles, revealedTiles, tilesToRevealCount, solution)
{
	//// Check every available tile.
	//var availableTilesLength = array_length(availableTiles);
	//for (var i = 0; i < availableTilesLength; i++)
	//{
	//	// Get current tile.
	//	var tile = ds_grid_get(grid, availableTiles[i].x, availableTiles[i].y);
	//	var tileCoords = global.mapObjects[availableTiles[i].x][availableTiles[i].y];
		
	//	// Get which tiles current tile reveals (through newRevealedTiles passed by reference)
	//	// and which tiles current tile activates (through the returned newAvailableTiles array).
	//	var newRevealedTiles = ds_map_create();
	//	ds_map_copy(newRevealedTiles, revealedTiles);
	//	var newAvailableTiles = getRevealedTiles(tile, tileCoords, newRevealedTiles);
		
	//	ds_stack_push(solution, tileCoords);
		
	//	// Check for success.
	//	var revealedTilesCount = ds_map_size(newRevealedTiles);
	//	if (tilesToRevealCount == revealedTilesCount)
	//	{
	//		return true;
	//	}
		
	//	var nextAvailableTiles = [];
	//	var len = array_length(availableTiles);
	//	array_copy(nextAvailableTiles, 0, availableTiles, 0, len);
		
	//	array_delete(nextAvailableTiles, i, 1);
		
	//	var newAvailableTilesLen = array_length(newAvailableTiles);
	//	array_copy(nextAvailableTiles, len - 1, newAvailableTiles, 0, newAvailableTilesLen);
		
	//	nextAvailableTiles = arrayUniqueStructByKey(nextAvailableTiles);
		
	//	if (!areAllReachableNaive(nextAvailableTiles, newRevealedTiles))
	//	{
	//		ds_map_destroy(newRevealedTiles);
	//		ds_stack_pop(solution);
	//		continue;
	//	}

	//	if (checkTileRecursive(nextAvailableTiles, newRevealedTiles, tilesToRevealCount, solution))
	//	{
	//		ds_map_destroy(newRevealedTiles);
	//		return true;
	//	}
		
	//	ds_stack_pop(solution);
		
	//	ds_map_destroy(newRevealedTiles);
	//	show_debug_message("test {0}", revealedTilesCount);
	//}

	return false;
}

function isReachableWith(tileToReachCoord, tileToUseCoord)
{
	var tile = ds_grid_get(grid, tileToUseCoord.x, tileToUseCoord.y);
	var revealedTiles = ds_map_create();
	
	//getRevealedTiles(tile, tileToUseCoord, revealedTiles);
	
	var revealed = ds_map_exists(revealedTiles, toMapKey(tileToReachCoord));
	
	ds_map_destroy(revealedTiles);
	
	return revealed;
}

function areAllReachableNaive(availableTiles, revealedTiles)
{
	// Get all unreached tiles.
	var unreachedTiles = [];
	for (var column = 0; column < global.height; column++)
	{
		for (var row = 0; row < global.width; row++)
		{
			var tileCoord = global.mapObjects[row][column];
			if (!ds_map_exists(revealedTiles, toMapKey(tileCoord)))
			{
				array_push(unreachedTiles, tileCoord);
			}
		}
	}
	
	var unreachedTilesLen = array_length(unreachedTiles);
	
	for (var column = 0; column < global.height; column++)
	{
		for (var row = 0; row < global.width; row++)
		{
			var tileCoord = global.mapObjects[row][column];
			// Check if it is already revealed.
			if (ds_map_exists(revealedTiles, toMapKey(tileCoord)))
			{
				continue;
			}
			
			// Check if is reachable with any available tiles.
			var len = array_length(availableTiles);
			var isReachable = false;
			for (var i = 0; i < len; i++)
			{
				if (isReachableWith(tileCoord, availableTiles[i]))
				{
					isReachable = true;
					break;
				}
			}
			
			if (isReachable)
			{
				continue;
			}
			
			// Check if it is reachable with any unreached tiles.
			for (var i = 0; i < unreachedTilesLen; i++)
			{
				if (isReachableWith(tileCoord, unreachedTiles[i]))
				{
					isReachable = true;
					break;
				}
			}
			
			if (!isReachable)
			{
				return false;
			}
		}
	}
	
	return true;
}

function getStartingTile()
{
	 return {x : floor(global.width / 2), y: floor(global.height / 2)};
}

function modulo(a, b)
{
    return ((a % b + b) % b);
}

function getRevealedTilesFromCache(tileCoordX, tileCoordY, tilesRevealedTiles, gridState, decision)
{
	var len = array_length(tilesRevealedTiles[tileCoordX][tileCoordY][decision]);
	
	var revealedCount = 0;
	for (var i = 0; i < len; i++)
	{
		var indexAndState = tilesRevealedTiles[tileCoordX][tileCoordY][decision][i];
		
		buffer_seek(gridState, buffer_seek_start, indexAndState.index);
		var currentState = buffer_read(gridState, buffer_u8);
		if (currentState == TileType.Unrevealed)
		{
			buffer_seek(gridState, buffer_seek_start, indexAndState.index);
			buffer_write(gridState, buffer_u8, indexAndState.state);
			revealedCount += 1;
		}
	}
	
	return revealedCount;
}

function getRevealedTilesFromCacheSetActive(tileCoordX, tileCoordY, tilesRevealedTiles, gridState, decision)
{
	var len = array_length(tilesRevealedTiles[tileCoordX][tileCoordY][decision]);
	
	var revealedCount = 0;
	for (var i = 0; i < len; i++)
	{
		var indexAndState = tilesRevealedTiles[tileCoordX][tileCoordY][decision][i];
		
		buffer_seek(gridState, buffer_seek_start, indexAndState.index);
		var currentState = buffer_read(gridState, buffer_u8);
		if (currentState == TileType.Unrevealed)
		{
			buffer_seek(gridState, buffer_seek_start, indexAndState.index);
			buffer_write(gridState, buffer_u8, TileType.Active);
			revealedCount += 1;
		}
	}
	
	return revealedCount;
}

function getRevealedTilesCountFromCache(tileCoordX, tileCoordY, tilesRevealedTiles, gridState, decision)
{
	var len = array_length(tilesRevealedTiles[tileCoordX][tileCoordY][decision]);
	
	var revealedCount = 0;
	for (var i = 0; i < len; i++)
	{
		var indexAndState = tilesRevealedTiles[tileCoordX][tileCoordY][decision][i];
		
		buffer_seek(gridState, buffer_seek_start, indexAndState.index);
		var currentState = buffer_read(gridState, buffer_u8);
		if (currentState == TileType.Unrevealed)
		{
			revealedCount += 1;
		}
	}
	
	return revealedCount;
}

function getRevealedTiles(width, height, tile, tileCoordX, tileCoordY, gridState, decision)
{
	var usedTile = undefined;
	switch(tile.type)
	{
		case(TilesTypes.plus):
		{
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value);

			break;
		}
		case(TilesTypes.cross):
		{
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY + tile.value);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY + tile.value);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY - tile.value);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY - tile.value);

			break;
		}
		case(TilesTypes.diamond):
		{
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY, true);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY, true);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value, true);
			getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value, true);

			break;
		}
		case(TilesTypes.line):
		{
			switch (decision)
			{
				case (0):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY);
					usedTile = global.mapObjects[modulo(tileCoordX + 1, width)][tileCoordY];
					break;
				}
				case (1):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value);
					usedTile = global.mapObjects[tileCoordX][modulo(tileCoordY + 1, height)];
					break;
				}
				case (2):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY);
					usedTile = global.mapObjects[modulo(tileCoordX - 1, width)][tileCoordY];
					break;
				}
				case (3):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value);
					usedTile = global.mapObjects[tileCoordX][modulo(tileCoordY - 1, height)];
					break;
				}
			}
			
			break;
		}
		case(TilesTypes.lineDiag):
		{
			switch(decision)
			{
				case(0):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY + tile.value);
					usedTile = global.mapObjects[modulo(tileCoordX + 1, width)][modulo(tileCoordY + 1, height)];
					break;
				}
				case(1):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY + tile.value);
					usedTile = global.mapObjects[modulo(tileCoordX - 1, width)][modulo(tileCoordY + 1, height)];
					break;
				}
				case(2):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY - tile.value);
					usedTile = global.mapObjects[modulo(tileCoordX - 1, width)][modulo(tileCoordY - 1, height)];
					break;
				}
				case(3):
				{
					getRevealedLine(width, height, gridState, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY - tile.value);
					usedTile = global.mapObjects[modulo(tileCoordX + 1, width)][modulo(tileCoordY - 1, height)];
					break;
				}
			}
			
			break;
		}
		case(TilesTypes.target):
		{
			// NOTE: Here we treat `decision` the same as linear tile index.
			var tileCoords = getXYFromLinearIndex(width, decision);
			
			if (debug_mode)
			{
				if (decision != getLinearTileIndex(width, tileCoords.x, tileCoords.y))
				{
					show_debug_message("Tile coordinates different than linear tile index, something went wrong!");
				}
			}

			buffer_seek(gridState, buffer_seek_start, decision);
			if (buffer_read(gridState, buffer_u8) == TileType.Unrevealed)
			{
				buffer_seek(gridState, buffer_seek_start, decision);
				buffer_write(gridState, buffer_u8, TileType.Active);
				usedTile = global.mapObjects[tileCoords.x][tileCoords.y];
			}

			break;
		}
	}
	
	return usedTile;
}

function getRevealedLine(width, height, gridState, x1, y1, x2, y2, isDiamond = false)
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
	
	var wrapped = wrapAroundGrid(width, height, x2, y2);
	var wrappedX2 = wrapped.x;
	var wrappedY2 = wrapped.y;
	
	for (var i = 0; i < length; i ++) 
	{
		xx += xStep;
		yy += yStep;
		
		var position = wrapAroundGrid(width, height, xx, yy);
		
		xx = position.x;
		yy = position.y;
		
		with (ds_grid_get(grid, xx, yy))
		{
			if (type == TilesTypes.block)
			{
				return;
			}
			
			var index = getLinearTileIndex(width, xx, yy);
			
			if (xx = wrappedX2 and yy = wrappedY2)
			{
				buffer_seek(gridState, buffer_seek_start, index);
				
				if (buffer_read(gridState, buffer_u8) == TileType.Unrevealed)
				{
					buffer_seek(gridState, buffer_seek_start, index);
					buffer_write(gridState, buffer_u8, TileType.Active);
				}
			}
			else
			{	
				buffer_seek(gridState, buffer_seek_start, index);
				
				if (buffer_read(gridState, buffer_u8) == TileType.Unrevealed)
				{
					buffer_seek(gridState, buffer_seek_start, index);
					buffer_write(gridState, buffer_u8, TileType.Revealed);
				}
			}
		}
		
		if (isDiamond)
		{
			getRevealedLine(width, height, gridState, xx, yy, xx + yStep * (length - i - 1), yy + xStep * (length - i - 1));
			getRevealedLine(width, height, gridState, xx, yy, xx - yStep * (length - i - 1), yy - xStep * (length - i - 1));
		}
	}
}

function generateGame()
{
	global.decisionString = "Decision";
    global.mapKeys = array_create();
    global.mapObjects = array_create();
    
    for(var _x = 0; _x < global.width; _x++)
    {
        var mk = array_create();
        var mo = array_create();
        
        for(var _y = 0; _y < global.height; _y++)
        {
            array_push(mk, string("{0}_{1}", _x, _y));
            array_push(mo, {x: _x, y: _y});
        }
        
        array_push(global.mapKeys, mk);
        array_push(global.mapObjects, mo);
    }
	
	maxSearchTime = 0.15; // minutes
	
	defineTiles();
    
    if (!global.isEditorOn)
    {
        if (global.level != "")
        {
            loadMap();
        }	
        else 
        {
            setSeed(global.levels[global.choosedLevel].seed);
            populateGrid();	
        }
        applayLevelIntro();
    }
    else 
    {
    	if (global.typeOfLoad == 1)
        {
            populateGrid();
            
            for(var yy = 0; yy < global.height; yy++)
	        {
		        for(var xx = 0; xx < global.width; xx++)
		        {
			        var tile = ds_grid_get(grid, xx, yy);
                    tile.isAvailable = true;
                    tile.isRevealed = true;
                }
            }
        }
        
        if (global.typeOfLoad == 2)
        {
            loadMap();
            
            for(var yy = 0; yy < global.height; yy++)
	        {
		        for(var xx = 0; xx < global.width; xx++)
		        {
			        var tile = ds_grid_get(grid, xx, yy);
                    tile.isAvailable = true;
                    tile.isRevealed = true;
                }
            }
        }
    }
	
	if (global.isSolverOn)
	{
		if (global.gamesToSolve > 0)
		{
			solveGame();
		}
		else
		{
			//game_end();
		}
	}
}

function getSeed()
{
	var finalSeed = string("{0}_{1}_{2}_{3}_{4}_{5}_{6}_{7}_{8}_{9}", 
	global.width, global.height,
	global.crossRatio, global.diamondRatio, global.lineRatio, global.diagRatio, global.plusRatio, global.blockRatio, global.targetRatio,
	random_get_seed()
	);
	clipboard_set_text(finalSeed);
	return finalSeed;
}

function setSeed(seed)
{
    var parts = string_split(seed, "_");
		
    if (array_length(parts) == 10)
    {
        global.width        = real(parts[0]);
        global.height       = real(parts[1]);
        global.crossRatio   = real(parts[2]);
        global.diamondRatio = real(parts[3]);
        global.lineRatio    = real(parts[4]);
        global.diagRatio    = real(parts[5]);
        global.plusRatio    = real(parts[6]);
        global.blockRatio   = real(parts[7]);
        global.targetRatio  = real(parts[8]);
        global.seed         = real(parts[9]);
    }
    
    random_set_seed(global.seed);
}