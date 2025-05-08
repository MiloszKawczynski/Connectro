
draw_set_font(f_base);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (drawSurface)
{
	drawSurface = false;
	removePotential();
	
	if (!surface_exists(muralSurface))
	{
		muralSurface = surface_create(global.width * global.cellSize, global.height * global.cellSize);
	}
	
	surface_set_target(muralSurface);
	draw_clear_alpha(c_white, 1);
	
	for(var yy = 0; yy < global.height; yy++)
	{
		for(var xx = 0; xx < global.width; xx++)
		{
			var tile = ds_grid_get(grid, global.width - xx - 1, yy);
			tile.drawMural(xx, yy);
		}
	}
	
	surface_reset_target();

	if (!surface_exists(blockSurface))
	{
		blockSurface = surface_create(39 * 5, 39);
	}
	
	surface_set_target(blockSurface);
	draw_clear_alpha(c_white, 0);
	
	draw_surface_stretched(muralSurface, 159, 3, 33, 33);
	draw_sprite(s_block, 0, 0, 0);
	surface_reset_target();
	
	surfaceTexture = surface_get_texture(blockSurface);
	front = createWall(global.height * global.cellSize);
}

drawState();

if (mouse_check_button_pressed(mb_right))
{
	getSeed();
}