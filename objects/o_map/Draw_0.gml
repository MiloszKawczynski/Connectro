draw_clear(c_black);
var eye = new vector3(15, 100, 90 * INVERT);
var target = new vector3(0, 1, 0);
var forward = normalize(subtract(target, eye))
var right = normalize(cross(forward, worldUp))
var up = cross(right, forward)
var view = matrix_build_lookat(
    eye.x, eye.y, eye.z,
    target.x, target.y, target.z,
    up.x, up.y, up.z,
);
var proj = matrix_build_projection_ortho(
    90, 160,
    -100, 1000
);
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_cullmode(cull_clockwise);
matrix_set(matrix_view, view);
matrix_set(matrix_projection, proj);

matrix_set(matrix_world, matrix_build(0, scrollPositionFinal - planeSize / 2 + 60, 0, 0, 0, 0, 2, 2, 1 * INVERT));
vertex_submit(plane, pr_trianglelist, texture);

var current_view = matrix_get(matrix_view);
var current_proj = matrix_get(matrix_projection);

var scale = 1.25;
for (var i = 0; i < array_length(global.levels); i++)
{
    var lvl = global.levels[i];
    matrix_set(matrix_world, matrix_build(lvl.x, lvl.y + scrollPositionFinal, 15 * scale * INVERT, -90, 0, 0, -1 * scale, -1 * scale, -1 * scale * INVERT));
    vertex_submit(building, pr_trianglelist, global.levels[i].texture);
}

matrix_set(matrix_world, matrix_build_identity());
matrix_set(matrix_view, matrix_build_identity());
matrix_set(matrix_projection, matrix_build_identity());

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);
gpu_set_alphatestenable(false);
gpu_set_cullmode(cull_noculling);

var proj = matrix_build_projection_ortho(
    90, -160 * INVERT,
    -100, 1000
);

matrix_set(matrix_projection, proj);

var negSrollPosition = -scrollPositionFinal;
var closestBuilding = 0;            
var lengthToSnap = abs(negSrollPosition - global.levels[0].y);

var mouseX = mouse_x - room_width / 2;
var mouseY = mouse_y - room_height / 2;

for (var i = 0; i < array_length(global.levels); i++)
{
    var lengthToBuilding = abs(negSrollPosition - global.levels[i].y);
    if (lengthToBuilding < lengthToSnap)
    {
        lengthToSnap = lengthToBuilding;
        closestBuilding = i;
    }
}

for (var i = -2; i <= 2; i++)
{
    if (closestBuilding + i < 0 or closestBuilding + i >= array_length(global.levels))
    {
        continue;
    }
    
    var buildingUIId = closestBuilding + i;
    
    var xx = lengthdir_x(global.levels[buildingUIId].y + scrollPositionFinal, 257) * 0.66 + lengthdir_x(global.levels[buildingUIId].x, 354);
    var yy = lengthdir_y(global.levels[buildingUIId].y + scrollPositionFinal, 257) * 0.66 + lengthdir_y(global.levels[buildingUIId].x, 354) - 40;
    
    var lerpDistanceValue = clamp(1 - (abs(scrollPositionFinal + global.levels[buildingUIId].y) / 90), 0, 1);
    
    var width = lerp(12, 12, lerpDistanceValue);
    var height = lerp(4, 8, lerpDistanceValue);
    var starsHeight = lerp(1, 4, lerpDistanceValue);
    var textScale = lerp(0, 0.6, lerpDistanceValue);
    var pinTail = lerp(height * 2, height, lerpDistanceValue);
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    
    draw_triangle(xx - 4, yy + height, xx + 4, yy + height, xx, yy + pinTail, false);
    draw_roundrect(xx - width, yy - height, xx + width, yy + height, false);
    
    for (var s = -1; s <= 1; s++)
    {
        draw_sprite(s_star, s + 1 < global.levels[buildingUIId].stars, xx + s * 7 + 0.5, yy + starsHeight);
    }
    
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var movesText = global.levels[buildingUIId].moves;
    if (global.levels[buildingUIId].moves = 999)
    {
        movesText = "-"
    }
    
    var movesToStarIndex = 0;
    var movesToStarText = string("/{0}", global.levels[buildingUIId].movesToStar[movesToStarIndex]);
    
    while(global.levels[buildingUIId].movesToStar[movesToStarIndex] > global.levels[buildingUIId].moves)
    {
        movesToStarIndex++;
        if (movesToStarIndex >= 3)
        {
            movesToStarText = "";
            break;
        }
        else 
        {
        	movesToStarText = string("/{0}", global.levels[buildingUIId].movesToStar[movesToStarIndex]);
        }
    }
    
    draw_text_transformed(xx + 1, yy - 2, string("{0}{1}", movesText, movesToStarText), textScale, textScale, 0);
    
    if (mouse_check_button_released(mb_left))
    {
        if (point_in_rectangle(mouseX, mouseY, xx - width, yy - height, xx + width, yy + height))
        {
            if (i == 0)
            {
                global.choosedLevel = buildingUIId;
                
                room_goto(r_game);
            }
            else    
            {
                scrollSpeed = 0;
                scrollFingerPosition = 0;
                scrollSnap = buildingUIId;
            }
        }
    }
}

var navigationX = 45 - 20;
var navigationY = 80 - 20;
var navigationScale = 0.5;
var buttonSize = 30;
draw_sprite_ext(s_arrowStreight, 3, navigationX, navigationY - 20, navigationScale, navigationScale, 0, c_white, 1);
draw_sprite_ext(s_arrowStreight, 1, navigationX, navigationY, navigationScale, navigationScale, 0, c_white, 1);

if (mouse_check_button_released(mb_left))
{
    if (point_in_rectangle(mouseX, mouseY, navigationX, navigationY - 20, navigationX + buttonSize * navigationScale, navigationY - 20 + buttonSize * navigationScale))
    {
        show_debug_message(scrollSnap);
        for (var i = 0; i < array_length(bioms); i++)
        {
            if (bioms[i] > scrollSnap)
            {
                scrollSpeed = 0;
                scrollFingerPosition = 0;
                scrollSnap = bioms[i];
                break;
            }
        }
        show_debug_message(scrollSnap);
    }
    
    if (point_in_rectangle(mouseX, mouseY, navigationX, navigationY, navigationX + buttonSize * navigationScale, navigationY + buttonSize * navigationScale))
    {
        show_debug_message(scrollSnap);
        for (var i = array_length(bioms) - 1; i >= 0; i--)
        {
            if (bioms[i] < scrollSnap)
            {
                scrollSpeed = 0;
                scrollFingerPosition = 0;
                scrollSnap = bioms[i];
                break;
            }
        }
        show_debug_message(scrollSnap);
    }
}