createBarierSurface();

var pow = 1.2;
var positionOnMap = scrollPositionFinal + 1010 + room_width / global.aspect * pow;

draw_clear(c_black);
var eye = new vector3(15, 100, 60 * INVERT);
var target = new vector3(0, 0, 0);
var forward = normalize(subtract(target, eye))
var right = normalize(cross(forward, worldUp))
var up = cross(right, forward)
var view = matrix_build_lookat(
    eye.x, eye.y, eye.z,
    target.x, target.y, target.z,
    up.x, up.y, up.z,
);

var proj = matrix_build_projection_ortho(
    room_width * pow, room_width / global.aspect * pow,
    -1000, 1000
);
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_cullmode(cull_clockwise);
matrix_set(matrix_view, view);
matrix_set(matrix_projection, proj);

matrix_set(matrix_world, matrix_build(0, scrollPositionFinal - planeSize / 2 + 60, -2 * INVERT, 0, 0, 0, 2, 2, 1 * INVERT));
vertex_submit(plane, pr_trianglelist, road);
matrix_set(matrix_world, matrix_build(0, scrollPositionFinal - planeSize / 2 + 60, 0, 0, 0, 0, 2, 2, 1 * INVERT));
vertex_submit(plane, pr_trianglelist, ground);
matrix_set(matrix_world, matrix_build(0, scrollPositionFinal - planeSize / 2 + 60, 2 * INVERT, 0, 0, 0, 2, 2, 1 * INVERT));
vertex_submit(plane, pr_trianglelist, flowers);
if (activeBarier != -1)
{
    matrix_set(matrix_world, matrix_build(0, positionOnMap - global.bioms[activeBarier].y, 32 * INVERT, 90, 0, 0, 2, 1, 2 * INVERT));
    vertex_submit(starBarier, pr_trianglelist, star);
}
matrix_set(matrix_world, matrix_build(0, scrollPositionFinal - planeSize / 2 + 60, 0, 0, 0, 0, 2, 2, 1 * INVERT));

var current_view = matrix_get(matrix_view);
var current_proj = matrix_get(matrix_projection);

var scale = 1;
for (var i = 0; i < array_length(global.levels); i++)
{
    var lvl = global.levels[i];
    var zz = 64 / 2 * lvl.height / lvl.width * scale;
    matrix_set(matrix_world, matrix_build(lvl.x, lvl.y + scrollPositionFinal, zz * INVERT, -90, 45 + lvl.rotation, 0, -1 * scale, -1 * scale, -1 * scale * INVERT));
    vertex_submit(global.levels[i].model, pr_trianglelist, global.levels[i].texture);
}

matrix_set(matrix_world, matrix_build_identity());
matrix_set(matrix_view, matrix_build_identity());
matrix_set(matrix_projection, matrix_build_identity());

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);
gpu_set_alphatestenable(false);
gpu_set_cullmode(cull_noculling);

pow = 1;

var viewWidth = (room_width * pow)
var viewHeight = (room_width / global.aspect * pow)

var proj = matrix_build_projection_ortho(
    viewWidth, viewHeight * -INVERT,
    -100, 1000
);

matrix_set(matrix_projection, proj);

var negSrollPosition = -scrollPositionFinal;
var closestBuilding = 0;            
var lengthToSnap = abs(negSrollPosition - global.levels[0].y);

var mouseX = mouse_x - viewWidth / 2;
var mouseY = mouse_y - viewHeight / 2;

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
        closestBuilding = i;
    }
}

for (var i = -5; i <= 5; i++)
{
    if (closestBuilding + i < 0 or closestBuilding + i >= array_length(global.levels))
    {
        continue;
    }
    
    var hm = i;
    
    while (!global.levels[closestBuilding + hm].hasMural)
    {
        hm += sign(hm);
        
        if (closestBuilding + hm < 0 || closestBuilding + hm >= array_length(global.levels))
        {
            break;
        }
    }

    if (closestBuilding + hm < 0 || closestBuilding + hm >= array_length(global.levels))
    {
        continue;
    }
    
    var buildingUIId = closestBuilding + hm;
    
    var xx = lengthdir_x(global.levels[buildingUIId].y + scrollPositionFinal, -105) + lengthdir_x(global.levels[buildingUIId].x, 0) * 1.7;
    var yy = lengthdir_y(global.levels[buildingUIId].y + scrollPositionFinal, -60) + lengthdir_y(global.levels[buildingUIId].x, 0);
    
    xx *= 0.5;
    yy *= 0.5;
    
    yy -= 70;
    
    var shoutScale = animcurve_get_point(ac_buildingShout, 0, buildingShout);
    var lerpDistanceValue = clamp(1 - (abs(scrollPositionFinal + global.levels[buildingUIId].y) / 90), 0, 1);
    
    var width = lerp(35, 24, lerpDistanceValue);
    var height = lerp(12, 16, lerpDistanceValue);
    var starsHeight = lerp(0, 6, lerpDistanceValue);
    var textScale = lerp(0, 1.2, lerpDistanceValue);
    var pinTail = lerp(height * 2, height, lerpDistanceValue);
    var spike = lerp(shoutScale, 0, lerpDistanceValue);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    
    draw_triangle(xx - 4, yy + height, xx + 4, yy + height, xx, yy + pinTail, false);
    draw_roundrect(xx - width, yy - height, xx + width, yy + height, false);
    
    if (global.levels[buildingUIId].stars != 0)
    {
        for (var s = -1; s <= 1; s++)
        {
            draw_sprite_ext(s_star, s + 1 < global.levels[buildingUIId].stars, xx + s * 14 + 0.5, yy + starsHeight, 2, 2, 0, c_white, 1);
        }
        
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(f_base);
            
        draw_text_transformed(xx + 2, yy - 4, string(global.levels[buildingUIId].moves), textScale, textScale, 0);
    }
    else 
    {
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(f_base);
        
        global.levels[buildingUIId].shoutRotation = lerp(global.levels[buildingUIId].shoutRotation, 0, 0.02);
        
        if (shoutScale == 1)
        {
            global.levels[buildingUIId].shoutRotation = random_range(-15, 15);
        }
        
        var paintMeScale = (1 - textScale) * shoutScale;
        if (textScale < 0.1)
        {
            draw_text_transformed(xx + 2, yy + 1, string("Paint Me!"), paintMeScale, paintMeScale, global.levels[buildingUIId].shoutRotation);
        }
        draw_sprite_ext(s_playButton, 0, xx - 1, yy + 1, textScale, textScale, 0, c_white, 1);
    }
    
    if (point_in_rectangle(mouseX, mouseY, xx - width, yy - height, xx + width, yy + height))
    {
        if (mouse_check_button_pressed(mb_left))
        {
            pressedID = buildingUIId;
        }
        
        if (mouse_check_button_released(mb_left))
        {
            if (buildingUIId == pressedID)
            {
                if (hm == 0)
                {
                    global.choosedLevel = buildingUIId;
                    
                    room_goto(r_game);
                }
                else    
                {
                    isSnapping = true;
                    scrollSnap = buildingUIId;
                    
                    scrollPosition += global.scrollFingerPosition;
                    scrollSpeed = 0;
                    global.scrollFingerPosition = 0;
                }
            }
        }
    }
}

draw_sprite_ext(s_uiBigStarGold, 0, -viewWidth / 2 + 20, -viewHeight / 2 + 20, 2, 2, 0, c_white, 1);
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_font(f_game);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

font_enable_effects(f_game, true, 
{
    outlineEnable: true,
    outlineDistance: 4,
    outlineColour: c_black
});
draw_text_transformed(-viewWidth / 2 + 40, -viewHeight / 2 + 25, gainedStars, 0.4, 0.4, 0);