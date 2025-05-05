function windowSetup()
{
	window_set_size(global.width * global.cellWindowSize, global.height * global.cellWindowSize);
	camera_set_view_size(view_camera[0], global.width * global.cellSize, global.height * global.cellSize);
	surface_resize(application_surface, global.width * global.cellSize, global.height * global.cellSize);
	window_set_position(30, 30);
}

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
				draw_sprite(s_icon, type, xx * global.cellSize, yy * global.cellSize); 
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
			draw_sprite(s_icon, type, xx * global.cellSize, yy * global.cellSize); 
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
			draw_sprite(s_icon, type, xx * global.cellSize, yy * global.cellSize); 
			draw_sprite(s_value, value, xx * global.cellSize, yy * global.cellSize);
			
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
				draw_sprite(s_arrowDiagonal, lineDirection, xx * global.cellSize, yy * global.cellSize);
			}
			else 
			{
				draw_sprite(s_arrowStreight, lineDirection, xx * global.cellSize, yy * global.cellSize);
			}
			draw_sprite(s_value, sourceTile.value, xx * global.cellSize, yy * global.cellSize);
			draw_set_alpha(0.25 + power(sin(current_time / 500), 2) * 0.25);
			draw_rectangle(xx * global.cellSize, yy * global.cellSize, xx * global.cellSize + global.cellSize, yy * global.cellSize + global.cellSize, false);
			draw_set_alpha(1);
		}
		
		if (isTargeted)
		{
			draw_set_color(c_red);
			draw_sprite(s_target, 0, xx * global.cellSize, yy * global.cellSize);
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
	grid = ds_grid_create(global.width, global.height);
	
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
	var aStar = true;
	
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
	
	if (aStar)
	{
		runAStar();
	}
	else
	{
		runDFS();
	}
}

function getAvailableOrRevealedCount(array)
{
	var height = global.height;
	var width = global.width;
	var sum = 0;
	for (var i = 0; i < height; i++)
	{
		for (var j = 0; j < width; j++)
		{
			if (array[i][j])
			{
				sum += 1;
			}
		}
	}
	
	return sum;
}

function runAStar()
{
	var width = global.width;
	var height = global.height;
	var tilesToRevealCount = width * height;

	var startingTile = getStartingTile();
	
	var revealedTiles = [
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
	];
	
	var availableTiles = [
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false, false, false, false],
	];

	revealedTiles[startingTile.y][startingTile.x] = true;
	availableTiles[startingTile.y][startingTile.x] = true;
	
	for (var column = 0; column < height; column++)
	{
		for (var row = 0; row < width; row++)
		{
			var tile = ds_grid_get(grid, row, column);
			if (tile.type == TilesTypes.block)
			{
				revealedTiles[column][row] = true;
			}
		}
	}

	var queue = ds_priority_create();
	var initialState = {
		availableTiles: availableTiles,
		revealedTiles: revealedTiles,
		revealedCount: 0,
		g: 0,
		path: [startingTile]
	};
	ds_priority_add(queue, initialState, 0);

	while (!ds_priority_empty(queue))
	{
		var state = ds_priority_delete_min(queue);

		var revealedCount = state.revealedCount;
		if (revealedCount == tilesToRevealCount)
		{
			show_debug_message("SOLUTION FOUND:");
			for (var i = 0; i < array_length(state.path); i++)
			{
				var step = state.path[i];
				show_debug_message("  " + string(step.x) + "," + string(step.y));
			}
			
			show_debug_message(string("Number of moves {0}", array_length(state.path)));
			ds_priority_destroy(queue);
			return;
		}

		for (var i = 0; i < height; i++)
		{
			for (var j = 0; j < width; j++)
			{
				if (!state.availableTiles[i][j])
				{
					continue;
				}
				
				var tile = ds_grid_get(grid, j, i);
				
				var decisions = 1;
				
				if (tile.type == TilesTypes.line or tile.type == TilesTypes.lineDiag)
				{
					decisions = 4;
				}
				
				for (var d = 0; d < decisions; d++)
				{
					var newRevealed = [[],[],[],[],[],[],[],[],[],[],[]];
				
					for (var k = 0; k < height; k++)
					{
						array_copy(newRevealed[k], 0, state.revealedTiles[k], 0, width);
					}
				
					var newAvailable = [[],[],[],[],[],[],[],[],[],[],[]];
				
					for (var k = 0; k < height; k++)
					{
						array_copy(newAvailable[k], 0, state.availableTiles[k], 0, width);
					}

					getRevealedTiles(width, height, tile, j, i, newAvailable, newRevealed, d);

					newAvailable[i][j] = false;
				
					var newRevealedCount = getAvailableOrRevealedCount(newRevealed);

					if (newRevealedCount == revealedCount)
					{
						continue;
					}

					var nextPath = [];
					array_copy(nextPath, 0, state.path, 0, array_length(state.path));
					array_push(nextPath, global.mapObjects[j][i]);

					var g = state.g + 1;
					var h = tilesToRevealCount - newRevealedCount;
					var priority = g + h;

					ds_priority_add(queue, {
						availableTiles: newAvailable,
						revealedTiles: newRevealed,
						revealedCount: newRevealedCount,
						g: g,
						path: nextPath
					}, priority);
				}
			}
		}
	}

	ds_priority_destroy(queue);
	show_debug_message("No solution found.");
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

function getRevealedTiles(width, height, tile, tileCoordX, tileCoordY, availableTiles, revealedTiles, decision)
{
	switch(tile.type)
	{
		case(TilesTypes.plus):
		{
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value);

			break;
		}
		case(TilesTypes.cross):
		{
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY + tile.value);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY + tile.value);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY - tile.value);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY - tile.value);

			break;
		}
		case(TilesTypes.diamond):
		{
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY, true);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY, true);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value, true);
			getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value, true);

			break;
		}
		case(TilesTypes.line):
		{
			switch (decision)
			{
				case (0):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY);
					break;
				}
				case (1):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY + tile.value);
					break;
				}
				case (2):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY);
					break;
				}
				case (3):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX, tileCoordY - tile.value);
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
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY + tile.value);
					break;
				}
				case(1):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY + tile.value);
					break;
				}
				case(2):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX - tile.value, tileCoordY - tile.value);
					break;
				}
				case(3):
				{
					getRevealedLine(width, height, availableTiles, revealedTiles, tileCoordX, tileCoordY, tileCoordX + tile.value, tileCoordY - tile.value);
					break;
				}
			}
			
			break;
		}
		case(TilesTypes.target):
		{
			break;
			
			for(var yy = 0; yy < height; yy++)
			{
				for(var xx = 0; xx < width; xx++)
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

function getRevealedLine(width, height, availableTiles, revealedTiles, x1, y1, x2, y2, isDiamond = false)
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
			
			if (xx = wrappedX2 and yy = wrappedY2)
			{
				if (!revealedTiles[yy][xx])
				{
					availableTiles[yy][xx] = true;
				}
			}
			
			revealedTiles[yy][xx] = true;
		}
		
		if (isDiamond)
		{
			getRevealedLine(width, height, availableTiles, revealedTiles, xx, yy, xx + yStep * (length - i - 1), yy + xStep * (length - i - 1));
			getRevealedLine(width, height, availableTiles, revealedTiles, xx, yy, xx - yStep * (length - i - 1), yy - xStep * (length - i - 1));
		}
	}
}

function generateGame()
{
	windowSetup();
	defineTiles();
	populateGrid();
	checkSolvability();
}