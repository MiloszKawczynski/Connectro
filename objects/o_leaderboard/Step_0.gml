ui.step();
var barSpeed = 0.5;

with(ui)
{
    if (goBackButton.press)
    {
        goBackButton.setScale(1.2, 1.2);
    }
    else 
    {
    	goBackButton.setScale(1, 1);
    }
    
    if (logoTimer != 0 or init)
    {
        logoTimer = timer(logoTimer, 0.02);
        init = false;
        
        if (logoTimer == 0)
        {
            logoTimer = 1;
        }
    }
    
    logo.setPositionInGrid(0, animcurve_get_point(ac_logo, 0, logoTimer));
}

if (keyboard_check_pressed(vk_backspace))
{
    room_goto(r_init);
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
