
debugManipulation();

if (mouse_check_button_pressed(mb_left))
{
    lastMousePositionPressed = mouse_y - (scrollPosition + scrollFingerPosition);
}

if (mouse_check_button(mb_left))
{
    scrollFingerPosition = mouse_y - lastMousePositionPressed;
    scrollSpeed = 0;
    scrollPosition = 0;
}
else 
{
    if (abs(scrollSpeed) < 1)
    {
        isSnapInRange = false;
        if (scrollFingerPosition != 0 or scrollSpeed != 0)
        {
            scrollPosition += scrollFingerPosition;
            scrollSpeed = 0;
            scrollFingerPosition = 0;
            
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
            isSnapInRange = true;
        }
        
        if (isSnapInRange)
        {
            scrollPosition = lerp(scrollPosition, -global.levels[scrollSnap].y, 0.1);
        }
    }
    else 
    {
    	scrollSpeed = lerp(scrollSpeed, 0, 0.02);
    }
}

if (mouse_check_button_released(mb_left))
{
    scrollSpeed += mouse_y - lastMousePosition;
}

scrollPosition += scrollSpeed;

lastMousePosition = lerp(lastMousePosition, mouse_y, 0.5);

scrollPositionFinal = scrollPosition + scrollFingerPosition;
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
    scrollFingerPosition = 0;
    scrollPosition = scrollPositionFinal;
    lastMousePositionPressed = mouse_y - (scrollPosition + scrollFingerPosition);
    
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