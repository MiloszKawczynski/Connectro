
debugManipulation();

if (mouse_check_button(mb_left))
{
    if (longPress < 5)
    {
        longPress++;
    }
}

if (longPress >= 4)
{
    if (longPress == 4)
    {
        lastMousePositionPressed = mouse_y - (scrollPosition + global.scrollFingerPosition);
    }
    
    global.scrollFingerPosition = mouse_y - lastMousePositionPressed;
    scrollSpeed = 0;
    scrollPosition = 0;
    isSnapping = false;
}
else 
{
    if (isSnapping)
    {
        scrollPosition = lerp(scrollPosition, -global.levels[scrollSnap].y, 0.1);
    }
    else 
    {
        if (abs(scrollSpeed) < 1)
        {
            if (scrollSpeed != 0)
            {
                scrollSpeed = 0;
                checkForSnap = true;
            }
        }
        else 
        {
        	scrollSpeed = lerp(scrollSpeed, 0, 0.02);
        }
    }
    
    if (checkForSnap)
    {
        checkForSnap = false;
        if (global.scrollFingerPosition != 0 or scrollSpeed != 0)
        {
            scrollPosition += global.scrollFingerPosition;
            scrollSpeed = 0;
            global.scrollFingerPosition = 0;
            
            var negSrollPosition = -scrollPosition;
            
            var lengthToSnap = abs(negSrollPosition - global.levels[0].y);
            
            for (var i = 0; i < array_length(global.levels); i++)
            {
                if (!global.levels[i].hasMural)
                {
                    continue;
                }
                
                var lengthToBuilding = abs(negSrollPosition - global.levels[i].y);
                if (lengthToBuilding < lengthToSnap)
                {
                    lengthToSnap = lengthToBuilding;
                    scrollSnap = i;
                }
            }
        }
        
        if (abs(scrollPosition - -global.levels[scrollSnap].y) < 300)
        {
            isSnapping = true;
        }
    }
}

if (mouse_check_button_released(mb_left))
{
    scrollSpeed += mouse_y - lastMousePosition;
    longPress = 0;
    
    if (abs(scrollSpeed) < 1)
    {
        checkForSnap = true;
    }
}

scrollPosition += scrollSpeed;

lastMousePosition = lerp(lastMousePosition, mouse_y, 0.5);

scrollPositionFinal = scrollPosition + global.scrollFingerPosition;

if (activeBarier == -1)
{
    scrollPositionFinal = max(scrollPositionFinal, scrollMin);
}
else 
{
	scrollPositionFinal = clamp(scrollPositionFinal, scrollMin, scrollMax);
}

if (scrollPositionFinal == scrollMin or scrollPositionFinal == scrollMax)
{
    scrollSpeed = 0;
    global.scrollFingerPosition = 0;
    scrollPosition = scrollPositionFinal;
    lastMousePositionPressed = mouse_y - (scrollPosition + global.scrollFingerPosition);
    
    var negSrollPosition = -scrollPosition;
            
    var lengthToSnap = abs(negSrollPosition - global.levels[0].y);
    for (var i = 0; i < array_length(global.levels); i++)
    {
        if (!global.levels[i].hasMural)
        {
            continue;
        }
        
        var lengthToBuilding = abs(negSrollPosition - global.levels[i].y);
        if (lengthToBuilding < lengthToSnap)
        {
            lengthToSnap = lengthToBuilding;
            scrollSnap = i;
        }
    }
}

buildingShout = timer(buildingShout, 0.02);