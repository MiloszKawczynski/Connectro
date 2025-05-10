for(var yy = 0; yy < global.height; yy++)
{
	for(var xx = 0; xx < global.width; xx++)
	{
		if (mouse_x > xx * global.cellSize and mouse_x < xx * global.cellSize + global.cellSize)
		{
			if (mouse_y > yy * global.cellSize and mouse_y < yy * global.cellSize + global.cellSize)
			{
				hoveredX = xx;
				hoveredY = yy;
			}
		}
	}
}

if (mouse_check_button(mb_left))
{
	longPress++;
}
else 
{
	longPress = 0;
}

if (longPress > 5)
{
	gameState();

	if (isAllRevealed() and gameState == normal)
	{
		drawSurface = true;
		gameState = gameEnd;
		drawState = endScreenTransitionDraw;
		audio_play_sound(sn_score, 0, true);
	}
}

if (keyboard_check_pressed(ord("R")))
{
	audio_stop_all();
	room_restart();
}

if (keyboard_check_pressed(vk_escape))
{
	audio_stop_all();
	game_restart();
}