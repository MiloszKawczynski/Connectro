function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    #macro Windows:MOBILE false 
    #macro Android:MOBILE true
    
    function level(_seed, _x, _y, _hasMural = false, _movesToStar = [0, 0, 0]) constructor 
    {
        seed = _seed;
        x = 32 * (_x - 7 / 2);
        y = (-_y + 47) * 32 - 15;
        stars = 0;
        moves = 999;
        movesToStar = _movesToStar;
        hasMural = _hasMural;
        
        if (hasMural)
        {
            if (_x == 2)
            {
                rotation = 0;
            }
            else 
            {
            	rotation = 270;
            }
        }
        else 
        {
        	rotation = choose(180, 90);
        }
        
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
        
        if (width == 9 and height == 11)
        {
            sprite = choose(s_block9_11, s_blockBrick9_11);
        }
        
        if (width == 9 and height == 13)
        {
            sprite = choose(s_block9_13, s_blockBrick9_13);
        }
        
        texture = sprite_get_texture(sprite, 1);
        
        model = createWall(width, height, 64);
        
        if (hasMural)
        {
            if (string_digits(splitSeed[2]) == "")
            {
                seed = splitSeed[2];
            }
        }
    }
    
    global.levels = array_create(0);
    
    var i = 0;
    array_push(global.levels,
    //i = 0 dek dek dek dek
        new level("7_9", 5, 0),
        new level("7_9", 7, 2),
    
        new level("11_11", 0, 3),
        new level("9_13", 2, 5),
    //i = 1 dek dek test dek
        new level("9_11_test", 2, 5 + 10, true, [50, 25, 20]),
        new level("7_9", 7, 2 + 10),
    
        new level("11_11", 0, 3 + 10),
        new level("9_13", 5, 0 + 10),
    //i = 2 dek wrap cross dek
        new level("9_11_wrap", 5, 0 + 10 * 2, true, [50, 25, 20]),
        new level("7_9", 7, 2 + 10 * 2),
    
        new level("11_11", 0, 3 + 10 * 2),
        new level("9_11_cross", 2, 5 + 10 * 2, true, [50, 25, 20]),
    //i = 3 dek walls last dek
        new level("9_11_walls", 5, 0 + 10 * 3, true, [50, 25, 20]),
        new level("7_9", 7, 2 + 10 * 3),
    
        new level("11_11", 0, 3 + 10 * 3),
        new level("9_13_last", 2, 5 + 10 * 3, true, [50, 25, 20]),
    //i = 4 dek dek dek dek
        new level("11_11", 0, 3 + 10 * 4),
        new level("9_13", 2, 5 + 10 * 4),
    
        new level("7_9", 5, 0 + 10 * 4),
        new level("7_9", 7, 2 + 10 * 4),);
    
    //for(var i = 0; i < 10; i++)
    //{
        //if (i == 0)
        //{
            //array_push(global.levels,
            //new level("11_11", 0, 3 + 10 * i),
            //new level("9_13", 2, 5 + 10 * i),
        //
            //new level("7_9", 5, 0 + 10 * i),
            //new level("7_9", 7, 2 + 10 * i),
            //);
        //}
        //else 
        //{
        	//array_push(global.levels,
            //new level("11_11", 0, 3 + 10 * i),
            //new level("9_13" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 2, 5 + 10 * i, true, [50, 25, 20]),
        //
            //new level("7_9" + "_2_4_2_2_2_1_1_" + string(irandom(999999999)), 5, 0 + 10 * i, true, [50, 25, 20]),
            //new level("7_9", 7, 2 + 10 * i),
            //);
        //}
    //}
    
    global.choosedLevel = 0;
    
    global.aspect = 9 / 20;
    
    if (MOBILE)
    {
        global.aspect = display_get_width() / display_get_height();
        surface_resize(application_surface, display_get_width(), display_get_height());
        camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);    
    }
}