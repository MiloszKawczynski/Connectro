#macro SOLUTION_PRINT_PATH false

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
			color = make_color_rgb(214, 75, 34);;
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
	
	static drawColor = function(xx, yy) 
	{
		if (isRevealed)
		{
			if (type == TilesTypes.block)
			{
				draw_sprite_stretched(s_icon, type, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			}
			else 
			{
				draw_set_color(color);
				draw_set_alpha(0.45);	
				draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
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
			draw_sprite_stretched(s_icon, type, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
	}
	
	static drawMural = function(xx, yy) 
	{
		draw_set_color(color);
		draw_set_alpha(1);	
		draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
		draw_set_alpha(1);
	}
	
	static drawButton = function(xx, yy)
	{
		if (isAvailable)
		{
			draw_set_color(c_red);
			draw_sprite_stretched(s_icon, type, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			draw_sprite_stretched(s_value, value, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize);
			
			draw_set_color(color);
			draw_set_alpha(0.25);	
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
		
		if (lineDirection != -1)
		{
			draw_set_color(c_red);
			if (isLineDiag)
			{
				draw_sprite_stretched(s_arrowDiagonal, lineDirection, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			}
			else 
			{
				draw_sprite_stretched(s_arrowStreight, lineDirection, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			}
			draw_sprite_stretched(s_value, sourceTile.value, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize); 
			draw_set_alpha(0.25 + power(sin(current_time / 500), 2) * 0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
		
		if (isTargeted)
		{
			draw_set_color(c_red);
			draw_sprite_stretched(s_target, 0, xx * global.cellSize, yy * global.cellSize, global.cellSize, global.cellSize);
			draw_set_alpha(0.25 + power(sin(current_time / 500), 2) * 0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
	}
	
	static drawPotential = function(xx, yy)
	{
		if (potential != 0)
		{
			draw_set_color(c_white);
			draw_set_alpha(0.3 * potential * power(sin(current_time / 500), 2) + 0.1);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
	}
	
	static drawHover = function(xx, yy, hx, hy)
	{
		if (hx == xx and hy == yy)
		{
			draw_set_color(c_white);
			draw_set_alpha(0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
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

function checkSolvability()
{
	global.solutionFile = file_text_open_append("solutions.txt");
	
	var aStar = true;
	global.solveTimeStart = get_timer();
	
	if (aStar)
	{
		runAStar();
	}
	else
	{
		runDFS();
	}
	
	file_text_close(global.solutionFile);
	
	room_restart();	
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

function getLinearTileIndex(width, xx, yy)
{
	return yy * width + xx;
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
						tilesUsedTiles[row][column][d] = usedTile;
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

function runAStar()
{
	var width = global.width;
	var height = global.height;
	var tilesToRevealCount = width * height;

	var startingTile = getStartingTile();
	
	var tilesSortedByRevealCount = [];
	var tilesSortedByRevealCountLength = 0;
	
	var tilesRevealedTiles = [
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], []],
	];
	
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
			var msg = "SOLUTION FOUND:\n";
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
			buffer_delete(state.gridState);
			ds_priority_destroy(queue);
			global.gamesToSolve--;
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
                    //var h = tilesToRevealCount - newRevealedCount;
                    
                    // getMostRevealed3
                    //var h = ceil((tilesToRevealCount - newRevealedCount) / 24.0) + getMostRevealed3(tilesToRevealCount, tilesToRevealCount - newRevealedCount, tilesSortedByRevealCount, newGridState, tilesRevealedTiles);

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
			var xx = decision % width;
			var yy = decision / width;
			
			var index = getLinearTileIndex(width, xx, yy);
			buffer_seek(gridState, buffer_seek_start, index);
			if (buffer_read(gridState, buffer_u8) == TileType.Unrevealed)
			{
				buffer_seek(gridState, buffer_seek_start, index);
				buffer_write(gridState, buffer_u8, TileType.Active);
				usedTile = global.mapObjects[xx][yy];
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

	global.mapKeys = [
		["0_0", "0_1", "0_2", "0_3", "0_4", "0_5", "0_6", "0_7", "0_8", "0_9", "0_10", "0_11"],
		["1_0", "1_1", "1_2", "1_3", "1_4", "1_5", "1_6", "1_7", "1_8", "1_9", "1_10", "1_11"],
		["2_0", "2_1", "2_2", "2_3", "2_4", "2_5", "2_6", "2_7", "2_8", "2_9", "2_10", "2_11"],
		["3_0", "3_1", "3_2", "3_3", "3_4", "3_5", "3_6", "3_7", "3_8", "3_9", "3_10", "3_11"],
		["4_0", "4_1", "4_2", "4_3", "4_4", "4_5", "4_6", "4_7", "4_8", "4_9", "4_10", "4_11"],
		["5_0", "5_1", "5_2", "5_3", "5_4", "5_5", "5_6", "5_7", "5_8", "5_9", "5_10", "5_11"],
		["6_0", "6_1", "6_2", "6_3", "6_4", "6_5", "6_6", "6_7", "6_8", "6_9", "6_10", "6_11"],
		["7_0", "7_1", "7_2", "7_3", "7_4", "7_5", "7_6", "7_7", "7_8", "7_9", "7_10", "7_11"],
		["8_0", "8_1", "8_2", "8_3", "8_4", "8_5", "8_6", "8_7", "8_8", "8_9", "8_10", "8_11"],
		["9_0", "9_1", "9_2", "9_3", "9_4", "9_5", "9_6", "9_7", "9_8", "9_9", "9_10", "9_11"],
		["10_0", "10_1", "10_2", "10_3", "10_4", "10_5", "10_6", "10_7", "10_8", "10_9", "10_10", "10_11"],
		["11_0", "11_1", "11_2", "11_3", "11_4", "11_5", "11_6", "11_7", "11_8", "11_9", "11_10", "11_11"]
	];
	
	global.mapObjects = [
		[{x: 0, y: 0}, {x: 0, y: 1}, {x: 0, y: 2}, {x: 0, y: 3}, {x: 0, y: 4}, {x: 0, y: 5}, {x: 0, y: 6}, {x: 0, y: 7}, {x: 0, y: 8}, {x: 0, y: 9}, {x: 0, y: 10}, {x: 0, y: 11}],
		[{x: 1, y: 0}, {x: 1, y: 1}, {x: 1, y: 2}, {x: 1, y: 3}, {x: 1, y: 4}, {x: 1, y: 5}, {x: 1, y: 6}, {x: 1, y: 7}, {x: 1, y: 8}, {x: 1, y: 9}, {x: 1, y: 10}, {x: 1, y: 11}],
		[{x: 2, y: 0}, {x: 2, y: 1}, {x: 2, y: 2}, {x: 2, y: 3}, {x: 2, y: 4}, {x: 2, y: 5}, {x: 2, y: 6}, {x: 2, y: 7}, {x: 2, y: 8}, {x: 2, y: 9}, {x: 2, y: 10}, {x: 2, y: 11}],
		[{x: 3, y: 0}, {x: 3, y: 1}, {x: 3, y: 2}, {x: 3, y: 3}, {x: 3, y: 4}, {x: 3, y: 5}, {x: 3, y: 6}, {x: 3, y: 7}, {x: 3, y: 8}, {x: 3, y: 9}, {x: 3, y: 10}, {x: 3, y: 11}],
		[{x: 4, y: 0}, {x: 4, y: 1}, {x: 4, y: 2}, {x: 4, y: 3}, {x: 4, y: 4}, {x: 4, y: 5}, {x: 4, y: 6}, {x: 4, y: 7}, {x: 4, y: 8}, {x: 4, y: 9}, {x: 4, y: 10}, {x: 4, y: 11}],
		[{x: 5, y: 0}, {x: 5, y: 1}, {x: 5, y: 2}, {x: 5, y: 3}, {x: 5, y: 4}, {x: 5, y: 5}, {x: 5, y: 6}, {x: 5, y: 7}, {x: 5, y: 8}, {x: 5, y: 9}, {x: 5, y: 10}, {x: 5, y: 11}],
		[{x: 6, y: 0}, {x: 6, y: 1}, {x: 6, y: 2}, {x: 6, y: 3}, {x: 6, y: 4}, {x: 6, y: 5}, {x: 6, y: 6}, {x: 6, y: 7}, {x: 6, y: 8}, {x: 6, y: 9}, {x: 6, y: 10}, {x: 6, y: 11}],
		[{x: 7, y: 0}, {x: 7, y: 1}, {x: 7, y: 2}, {x: 7, y: 3}, {x: 7, y: 4}, {x: 7, y: 5}, {x: 7, y: 6}, {x: 7, y: 7}, {x: 7, y: 8}, {x: 7, y: 9}, {x: 7, y: 10}, {x: 7, y: 11}],
		[{x: 8, y: 0}, {x: 8, y: 1}, {x: 8, y: 2}, {x: 8, y: 3}, {x: 8, y: 4}, {x: 8, y: 5}, {x: 8, y: 6}, {x: 8, y: 7}, {x: 8, y: 8}, {x: 8, y: 9}, {x: 8, y: 10}, {x: 8, y: 11}],
		[{x: 9, y: 0}, {x: 9, y: 1}, {x: 9, y: 2}, {x: 9, y: 3}, {x: 9, y: 4}, {x: 9, y: 5}, {x: 9, y: 6}, {x: 9, y: 7}, {x: 9, y: 8}, {x: 9, y: 9}, {x: 9, y: 10}, {x: 9, y: 11}],
		[{x: 10, y: 0}, {x: 10, y: 1}, {x: 10, y: 2}, {x: 10, y: 3}, {x: 10, y: 4}, {x: 10, y: 5}, {x: 10, y: 6}, {x: 10, y: 7}, {x: 10, y: 8}, {x: 10, y: 9}, {x: 10, y: 10}, {x: 10, y: 11}],
		[{x: 11, y: 0}, {x: 11, y: 1}, {x: 11, y: 2}, {x: 11, y: 3}, {x: 11, y: 4}, {x: 11, y: 5}, {x: 11, y: 6}, {x: 11, y: 7}, {x: 11, y: 8}, {x: 11, y: 9}, {x: 11, y: 10}, {x: 11, y: 11}]
	];
	
	maxSearchTime = 0.1; // minutes
	
	defineTiles();
    
    if (!global.isEditorOn)
    {
        if (global.level != "")
        {
            loadMap();
        }	
        else 
        {
            populateGrid();	
        }
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
    	if (global.gamesToSolve != 0)
    	{
    		checkSolvability();	
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