
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
    show_debug_message(string("x: {0}, y: {1}, z: {2}, r: {3}", x, y, z, r));
}