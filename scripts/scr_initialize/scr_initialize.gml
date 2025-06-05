function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    #macro Windows:MOBILE false 
    #macro Android:MOBILE true
    
    function level(_seed, _x, _y, _movesToStar = [30, 25, 20]) constructor 
    {
        seed = _seed;
        x = lerp(-45, 45, _x / 5);
        y = -100 - _y * 15;
        stars = 0;
        moves = 999;
        movesToStar = _movesToStar;
        
        splitSeed = string_split(seed, "_");
        width = real(splitSeed[0]);
        height = real(splitSeed[1]);
        
        sprite = undefined;
        
        if (width == height)
        {
            sprite = s_block1_1;
        }
        
        if (width == 7 and height == 9)
        {
            sprite = s_block7_9;
        }
        
        if (width == 9 and height == 13)
        {
            sprite = s_block9_13;
        }
        
        texture = sprite_get_texture(sprite, 1);
        
        model = createWall(width, height, 20);
    }
    
    global.levels = array_create(0);
    
    for(var i = 0; i < 100; i+= 2)
    {
        array_push(global.levels,
            new level("11_11" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 0, i, [50, 25, 20]),
            new level("9_13" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 2, i, [50, 25, 20]),
            new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 4, i, [50, 25, 20]),
        
            new level("11_11" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 1, i + 1, [50, 25, 20]),
            new level("9_13" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 3, i + 1, [50, 25, 20]),
            new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 5, i + 1, [50, 25, 20]),
        );
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