plane = createPlane(90, 160);
texture = sprite_get_texture(s_background, 0);

buildingTexture = sprite_get_texture(s_block, 0);

building = createWall(20);

tilt = 0;
r = 0;

worldUp = new vector3(0, 0, 1);

function vector3(_x, _y, _z) constructor 
{
    x = _x;
    y = _y;
    z = _z;
}

function cross(a, b) 
{
    var cx = a.y * b.z - a.z * b.y;
    var cy = a.z * b.x - a.x * b.z;
    var cz = a.x * b.y - a.y * b.x;
    return new vector3(cx, cy, cz);
}

function subtract(a, b)
{
    return new vector3(a.x - b.x, a.y - b.y, a.x - b.y);
}

function normalize(a)
{
    var length = point_distance_3d(0, 0, 0, a.x, a.y, a.z);
    return new vector3(a.x / length, a.y / length, a.z / length);
}

z = 0;