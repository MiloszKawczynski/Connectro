
var cameraSpeed = 0.1;

if (keyboard_check(vk_lshift))
{
    cameraSpeed = 2;
}

x += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * cameraSpeed;
y += (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * cameraSpeed;
z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * cameraSpeed;
r += (keyboard_check(ord("I")) - keyboard_check(ord("O"))) * cameraSpeed;

if (keyboard_check_pressed(ord("R")))
{
    x = 0;
    y = 0;
    z = 0;
    r = 0;
}

if (keyboard_check_pressed(vk_lcontrol))
{
    x = floor(x);
    y = floor(y);
    z = floor(z);
    r = floor(r);
}

if (keyboard_check_pressed(ord("P")))
{
    show_debug_message(string("x: {0}, y: {1}, z: {2}, r: {3}, s: {4}", x, y, z, r, scrollPositionFinal));
}

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
        scrollPosition = lerp(scrollPosition, -global.levels[scrollSnap].y, 0.1);
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
scrollPositionFinal = clamp(scrollPositionFinal, scrollMin, scrollMax);
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