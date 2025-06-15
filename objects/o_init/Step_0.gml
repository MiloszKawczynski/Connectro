ui.step();
var barSpeed = 0.5;

with(ui)
{
    if (paintButton.press)
    {
        paintButton.setScale(1.1, 1.1);
        paintButtonText.setScale(1.1, 1.1);
    }
    else 
    {
    	paintButton.setScale(1, 1);
        paintButtonText.setScale(1, 1);
    }
    
    if (rogueButton.press)
    {
        rogueButton.setScale(1.1, 1.1);
        rogueButtonText.setScale(1.1, 1.1);
    }
    else 
    {
    	rogueButton.setScale(1, 1);
        rogueButtonText.setScale(1, 1);
    }
    
    if (resetButton.press)
    {
        resetButton.setScale(1.1, 1.1);
        resetButtonText.setScale(1.1, 1.1);
    }
    else 
    {
    	resetButton.setScale(1, 1);
        resetButtonText.setScale(1, 1);
    }
    
    if (fade)
    {
        fadeCover.setAlpha(lerp(fadeCover.alpha, 1, 0.2));
        
        if (fadeCover.alpha >= 0.95)
        {
            room_goto(r_map);
        }
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
    
    for (var i = 0; i < array_length(iconBarArray); i += 2)
    {
        var dir = lerp(-1, 1, (i / 2) mod 2);
        
        with(iconBarArray[i])
        {
            setShift(shiftX + barSpeed * dir, 0);
            
            if (shiftX > width)
            {
                setShift(-width, 0);
            }
            
            if (shiftX < -width)
            {
                setShift(width, 0);
            }
        }
        
        with(iconBarArray[i + 1])
        {
            setShift(shiftX + barSpeed * dir, 0);
            
            if (shiftX > width)
            {
                setShift(-width, 0);
            }
            
            if (shiftX < -width)
            {
                setShift(width, 0);
            }
        }
    }
}