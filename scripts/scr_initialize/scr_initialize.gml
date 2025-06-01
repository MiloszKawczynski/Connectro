function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    #macro Windows:MOBILE false 
    #macro Android:MOBILE true
    
    function level(_seed, _x, _y, _movesToStar = [30, 25, 20]) constructor 
    {
        seed = _seed;
        x = _x;
        y = _y;
        stars = 0;
        moves = 0;
        movesToStar = _movesToStar;
        texture = sprite_get_texture(s_block, 1);
    }
    
    global.levels = array_create(0);
    
    for (var i = 0; i < 100; i++)
    {
        array_push(global.levels,
            new level("9_13_2_4_2_2_2_1_1_" + string(irandom(999999999)), 17 * lerp(-1, 1, i mod 2), 55 - 70 * i, [30, 25, 20]));
    }
    
    global.choosedLevel = 0;
    
    global.aspect = 9 / 20;
    
    if (MOBILE)
    {
        global.aspect = display_get_width() / display_get_height();
        surface_resize(application_surface, display_get_width(), display_get_height());
        camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);    
    }
}