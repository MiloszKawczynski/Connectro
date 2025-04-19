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

function generateGame()
{
	windowSetup();
	defineTiles();
	populateGrid();
}