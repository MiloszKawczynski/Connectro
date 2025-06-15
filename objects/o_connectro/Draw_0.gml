ui.draw();

draw_set_font(f_base);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (drawSurface)
{
	drawSurface = false;
	removePotential();
    
    var buildingSprite = global.levels[global.choosedLevel].sprite;
    var spriteWidth = sprite_get_width(buildingSprite);
    var spriteHeight = sprite_get_height(buildingSprite);
	
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
			tile.drawMural(xx, yy, global.cellSize);
		}
	}
	
	surface_reset_target();
    
	if (!surface_exists(blockSurface))
	{
		blockSurface = surface_create(spriteWidth, spriteHeight);
	}
	
	surface_set_target(blockSurface);
	draw_clear_alpha(c_white, 0);
	
	draw_surface_stretched(muralSurface, (global.width + 2) * 3 * 4 + 3, 3, global.width * 3, global.height * 3);
	draw_sprite(global.levels[global.choosedLevel].sprite, 0, 0, 0);
	surface_reset_target();
	
    surfaceTexture = sprite_get_texture(sprite_create_from_surface(blockSurface, 0, 0, spriteWidth, spriteHeight, false, false, 0, 0), 0);
	front = createWall(global.width, global.height, global.width * global.cellSize);
}

drawState();

if (mouse_check_button_pressed(mb_right))
{
	getSeed();
}

if (fade)
{
    fadeAlpha = lerp(fadeAlpha, 1, 0.2);
    
    if (fadeAlpha >= 0.95)
    {
        fadeFunction();
    }
}
else 
{
	fadeAlpha = lerp(fadeAlpha, 0, 0.2);
    
    if (fadeAlpha <= 0.05)
    {
        fadeAlpha = 0;
    }
}


draw_set_alpha(fadeAlpha);
draw_set_color(c_black);
draw_rectangle(-room_width, -room_height, room_width, room_height, false);
draw_set_alpha(1);