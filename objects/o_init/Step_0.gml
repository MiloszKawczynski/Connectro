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
    
    if (resetAllButton.press)
    {
        resetAllButton.setScale(1.1, 1.1);
        resetAllButtonText.setScale(1.1, 1.1);
    }
    else 
    {
    	resetAllButton.setScale(1, 1);
        resetAllButtonText.setScale(1, 1);
    }
    
    if (unlockAllButton.press)
    {
        unlockAllButton.setScale(1.1, 1.1);
        unlockAllButtonText.setScale(1.1, 1.1);
    }
    else 
    {
    	unlockAllButton.setScale(1, 1);
        unlockAllButtonText.setScale(1, 1);
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

if (mouse_check_button(mb_left))
{
    debugPress++;
}
else 
{
    if (debugPress >= 60 * 3)
    {
        with(ui)
        {
            mainLayer.addComponent(1.5, 12, resetButton);
            mainLayer.addComponent(3, 12, resetAllButton);
            mainLayer.addComponent(4.5, 12, unlockAllButton);
            mainLayer.addComponent(1.5, 12, resetButtonText);
            mainLayer.addComponent(3, 12, resetAllButtonText);
            mainLayer.addComponent(4.5, 12, unlockAllButtonText);
        }
    }
	debugPress = 0;
}

if (keyboard_check_pressed(vk_backspace))
{
    game_end();
}