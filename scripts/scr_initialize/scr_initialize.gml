function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    #macro Windows:MOBILE false 
    #macro Android:MOBILE true
    
    function level(_seed, _x, _y, _movesToStar = [30, 25, 20]) constructor 
    {
        seed = _seed;
        x = 32 * (_x - 7 / 2);
        y = (-_y + 47) * 32 - 15;
        stars = 0;
        moves = 999;
        movesToStar = _movesToStar;
        
        rotation = choose(0, 90, 180, 270);
        
        splitSeed = string_split(seed, "_");
        width = real(splitSeed[0]);
        height = real(splitSeed[1]);
        
        sprite = s_block1_1;
        
        if (width == height)
        {
            sprite = choose(s_block1_1, s_blockBrick1_1);
        }
        
        if (width == 7 and height == 9)
        {
            sprite = choose(s_blockBrick7_9, s_blockBrick7_9);
        }
        
        if (width == 9 and height == 13)
        {
            sprite = choose(s_block9_13, s_blockBrick9_13);
        }
        
        texture = sprite_get_texture(sprite, 1);
        
        model = createWall(width, height, 64);
    }
    
    global.levels = array_create(0);
    
    for(var i = 0; i < 100; i++)
    {
        array_push(global.levels,
            new level("11_11" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 0, 3 + 10 * i, [50, 25, 20]),
            new level("9_13" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 2, 5 + 10 * i, [50, 25, 20]),
        
            new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 5, 0 + 10 * i, [50, 25, 20]),
            new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 7, 2 + 10 * i, [50, 25, 20]),
        
            //new level("11_11" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 0, 1, [50, 25, 20]),
            //new level("9_13" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 3, 1, [50, 25, 20]),
            //new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 5, 1, [50, 25, 20]),
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