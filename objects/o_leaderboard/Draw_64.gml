ui.draw();

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