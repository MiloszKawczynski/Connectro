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
					var wrappedFlash = wrapAroundGrid(xx + flashNext[i]._x, yy + flashNext[i]._y);
					if (flashNext[i]._power == 1)
					{
						break;
					}
					
					with(ds_grid_get(o_connectro.grid, wrappedFlash._x, wrappedFlash._y))
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
	return string(tileCoords.x) + "_" + string(tileCoords.y);
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
	
	if (aStar)
	{
		runAStar();
	}
	else
	{
		runDFS();
	}
}

function runAStar()
{
	var tilesToRevealCount = global.width * global.height;
	var startingTile = getStartingTile();
	
	var revealedTiles = ds_map_create();
	ds_map_add(revealedTiles, toMapKey(startingTile), false);
	
	for (var column = 0; column < global.height; column++)
	{
		for (var row = 0; row < global.width; row++)
		{
			var tile = ds_grid_get(grid, row, column);
			if (tile.type == TilesTypes.block)
			{
				ds_map_add(revealedTiles, toMapKey({x: row, y: column}), false);
			}
		}
	}

	var queue = [];
	array_push(queue, {
		tileCoord: startingTile,
		availableTiles: [startingTile],
		revealedTiles: revealedTiles,
		g: 0,
		priority: 0,
		path: [startingTile]
	});

	while (array_length(queue) > 0)
	{
		array_sort(queue, function(a, b) {
			return a.priority - b.priority;
		});

		var state = queue[0];
		array_delete(queue, 0, 1);

		var revealedCount = ds_map_size(state.revealedTiles);
		if (revealedCount == tilesToRevealCount)
		{
			show_debug_message("SOLUTION FOUND:");
			for (var i = 0; i < array_length(state.path); i++) {
				var step = state.path[i];
				show_debug_message("  " + string(step.x) + "," + string(step.y));
			}
			ds_map_destroy(state.revealedTiles);
			return;
		}

		var len = array_length(state.availableTiles);
		for (var i = 0; i < len; i++)
		{
			var currentCoord = state.availableTiles[i];
			var tile = ds_grid_get(grid, currentCoord.x, currentCoord.y);

			var newRevealed = ds_map_create();
			ds_map_copy(newRevealed, state.revealedTiles);

			var newAvailable = getRevealedTiles(tile, currentCoord, newRevealed);

			var nextAvailable = [];
			array_copy(nextAvailable, 0, state.availableTiles, 0, array_length(state.availableTiles));
			array_delete(nextAvailable, i, 1);
			var lenOld = array_length(nextAvailable);
			var lenNew = array_length(newAvailable);
			array_copy(nextAvailable, lenOld, newAvailable, 0, lenNew);

			nextAvailable = arrayUniqueStructByKey(nextAvailable);
			var actualNewAvailableCount = array_length(nextAvailable) - lenOld;

			var nextPath = [];
			array_copy(nextPath, 0, state.path, 0, array_length(state.path));
			array_push(nextPath, currentCoord);

			var g = state.g + 1;
			var h = (tilesToRevealCount - ds_map_size(newRevealed));
			var priority = g + h;

			array_push(queue, {
				tileCoord: currentCoord,
				availableTiles: nextAvailable,
				revealedTiles: newRevealed,
				g: g,
				priority: priority,
				path: nextPath
			});
		}

		ds_map_destroy(state.revealedTiles);
	}

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
				ds_map_add(revealedTiles, toMapKey({x: row, y: column}), false);
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
	// Check every available tile.
	var availableTilesLength = array_length(availableTiles);
	for (var i = 0; i < availableTilesLength; i++)
	{
		// Get current tile.
		var tile = ds_grid_get(grid, availableTiles[i].x, availableTiles[i].y);
		var tileCoords = {x: availableTiles[i].x, y: availableTiles[i].y};
		
		// Get which tiles current tile reveals (through newRevealedTiles passed by reference)
		// and which tiles current tile activates (through the returned newAvailableTiles array).
		var newRevealedTiles = ds_map_create();
		ds_map_copy(newRevealedTiles, revealedTiles);
		var newAvailableTiles = getRevealedTiles(tile, tileCoords, newRevealedTiles);
		
		ds_stack_push(solution, tileCoords);
		
		// Check for success.
		var revealedTilesCount = ds_map_size(newRevealedTiles);
		if (tilesToRevealCount == revealedTilesCount)
		{
			return true;
		}
		
		var nextAvailableTiles = [];
		var len = array_length(availableTiles);
		array_copy(nextAvailableTiles, 0, availableTiles, 0, len);
		
		array_delete(nextAvailableTiles, i, 1);
		
		var newAvailableTilesLen = array_length(newAvailableTiles);
		array_copy(nextAvailableTiles, len - 1, newAvailableTiles, 0, newAvailableTilesLen);
		
		nextAvailableTiles = arrayUniqueStructByKey(nextAvailableTiles);
		
		if (!areAllReachableNaive(nextAvailableTiles, newRevealedTiles))
		{
			ds_map_destroy(newRevealedTiles);
			ds_stack_pop(solution);
			continue;
		}

		if (checkTileRecursive(nextAvailableTiles, newRevealedTiles, tilesToRevealCount, solution))
		{
			ds_map_destroy(newRevealedTiles);
			return true;
		}
		
		ds_stack_pop(solution);
		
		ds_map_destroy(newRevealedTiles);
		show_debug_message("test {0}", revealedTilesCount);
	}

	return false;
}

function isReachableWith(tileToReachCoord, tileToUseCoord)
{
	var tile = ds_grid_get(grid, tileToUseCoord.x, tileToUseCoord.y);
	var revealedTiles = ds_map_create();
	
	getRevealedTiles(tile, tileToUseCoord, revealedTiles);
	
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
			var tileCoord = {x: row, y: column};
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
			var tileCoord = {x: row, y: column};
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

function getRevealedTiles(tile, tileCoords, revealedTiles)
{
	var newRevealedTiles = [];
	
	switch(tile.type)
	{
		case(TilesTypes.plus):
		{
			var arr1 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x + tile.value, tileCoords.y);
			var arr2 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x - tile.value, tileCoords.y);
			var arr3 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x, tileCoords.y + tile.value);
			var arr4 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x, tileCoords.y - tile.value);
			newRevealedTiles = array_concat(arr1, arr2, arr3, arr4);
			
			break;
		}
		case(TilesTypes.cross):
		{
			var arr1 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x + tile.value, tileCoords.y + tile.value);
			var arr2 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x - tile.value, tileCoords.y + tile.value);
			var arr3 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x - tile.value, tileCoords.y - tile.value);
			var arr4 = getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x + tile.value, tileCoords.y - tile.value);
			newRevealedTiles = array_concat(arr1, arr2, arr3, arr4);
			
			break;
		}
		case(TilesTypes.diamond):
		{
			getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x + tile.value, tileCoords.y, true);
			getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x - tile.value, tileCoords.y, true);
			getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x, tileCoords.y + tile.value, true);
			getRevealedLine(revealedTiles, tileCoords.x, tileCoords.y, tileCoords.x, tileCoords.y - tile.value, true);

			break;
		}
		case(TilesTypes.line):
		{
			break;
			var rightDown = wrapAroundGrid(tileCoords.x + 1, tileCoords.y + 1);
			var leftUp = wrapAroundGrid(tileCoords.x - 1, tileCoords.y - 1);

			with(ds_grid_get(grid, rightDown._x, tileCoords.y))
			{
				lineDirection = 0;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, tileCoords.x, rightDown._y))
			{
				lineDirection = 1;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, leftUp._x, tileCoords.y))
			{
				lineDirection = 2;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, tileCoords.x, leftUp._y))
			{
				lineDirection = 3;
				sourceTile = tile;
			}
				
			gameState = mustPickDirection;
			tile.isAvailable = true;
			break;
		}
		case(TilesTypes.lineDiag):
		{
			break;
			
			var rightDown = wrapAroundGrid(tileCoords.x + 1, tileCoords.y + 1);
			var leftUp = wrapAroundGrid(tileCoords.x - 1, tileCoords.y - 1);
				
			with(ds_grid_get(grid, rightDown._x, rightDown._y))
			{
				lineDirection = 0;
				isLineDiag = true;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, leftUp._x, rightDown._y))
			{
				lineDirection = 1;
				isLineDiag = true;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, leftUp._x, leftUp._y))
			{
				lineDirection = 2;
				isLineDiag = true;
				sourceTile = tile;
			}
				
			with(ds_grid_get(grid, rightDown._x, leftUp._y))
			{
				lineDirection = 3;
				isLineDiag = true;
				sourceTile = tile;
			}
				
			gameState = mustPickDirection;
			tile.isAvailable = true;
			break;
		}
		case(TilesTypes.target):
		{
			break;
			
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
	
	return newRevealedTiles;
}

function getRevealedLine(revealedTiles, x1, y1, x2, y2, isDiamond = false)
{
	var newAvailableTiles = [];
	
	var length = point_distance(x1, y1, x2, y2);
	
	if (frac(length) != 0)
	{
		length /= sqrt(2);
	}
	
	var xStep = sign(x2 - x1);
	var yStep = sign(y2 - y1);
	
	var xx = x1;
	var yy = y1;
	
	var wrapped = wrapAroundGrid(x2, y2);
	var wrappedX2 = wrapped._x;
	var wrappedY2 = wrapped._y;
	
	for (var i = 0; i < length; i ++) 
	{
		xx += xStep;
		yy += yStep;
		
		var position = wrapAroundGrid(xx, yy);
		
		xx = position._x;
		yy = position._y;
		
		with (ds_grid_get(grid, xx, yy))
		{
			if (type == TilesTypes.block)
			{
				// Return empty array
				return newAvailableTiles;
			}
			
			if (xx = wrappedX2 and yy = wrappedY2)
			{
				if (!ds_map_exists(revealedTiles, toMapKey({x: xx, y: yy})))
				{
					array_push(newAvailableTiles, {x: xx, y: yy});
				}
			}
			
			ds_map_add(revealedTiles, toMapKey({x: xx, y: yy}), false);
		}
		
		if (isDiamond)
		{
			var newTiles = [];
			newTiles = getRevealedLine(revealedTiles, xx, yy, xx + yStep * (length - i - 1), yy + xStep * (length - i - 1));
			var newTilesCount = array_length(newTiles);
			
			for (var k = 0; k < newTilesCount; k++)
			{
				array_push(newAvailableTiles, newTiles[k]);
			}
			
			newTiles = getRevealedLine(revealedTiles, xx, yy, xx - yStep * (length - i - 1), yy - xStep * (length - i - 1));
			newTilesCount = array_length(newTiles);
			
			for (var k = 0; k < newTilesCount; k++)
			{
				if (!ds_map_exists(revealedTiles, toMapKey(newTiles[k])))
				{
					array_push(newAvailableTiles, newTiles[k]);
				}
			}
		}
	}
	
	return newAvailableTiles;
}

function generateGame()
{
	windowSetup();
	defineTiles();
	populateGrid();
	checkSolvability();
}