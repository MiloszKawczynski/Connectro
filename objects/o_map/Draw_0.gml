draw_clear(c_black);

var eye = new vector3(15, 100, 90);
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
    1, 1000
);

gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_cullmode(cull_clockwise);

matrix_set(matrix_view, view);
matrix_set(matrix_projection, proj);

matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 2, 2, 1));
vertex_submit(plane, pr_trianglelist, texture);

var scale = 1.25;
matrix_set(matrix_world, matrix_build(17, -35, 15 * scale, -90, 0, 0, -1 * scale, -1 * scale, -1.5 * scale));
vertex_submit(building, pr_trianglelist, buildingTexture);
matrix_set(matrix_world, matrix_build(-17, 55, 15 * scale, -90, r, 0, -1 * scale, -1 * scale, -1.5 * scale));
vertex_submit(building, pr_trianglelist, buildingTexture);
matrix_set(matrix_world, matrix_build_identity());

matrix_set(matrix_view, matrix_build_identity());
matrix_set(matrix_projection, matrix_build_identity());

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);
gpu_set_alphatestenable(false);
gpu_set_cullmode(cull_noculling);
