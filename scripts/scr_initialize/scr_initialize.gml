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
        shoutRotation = 0;
        typeOfLoad = 1;
        
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
                typeOfLoad = 2;
            }
        }
    }
    
    function biom(_y, _limit) constructor 
    {
        y = _y * 2 - 13
        limit = _limit;
    }
    
    global.levels = array_create(0);
    global.bioms = array_create(0);
    
    var i = 0;
    array_push(global.levels,
    //i = 0 dek dek dek dek
        new level("7_9", 5, 0 + 10 * (0 + i)),
        new level("7_9", 7, 2 + 10 * (0 + i)),
    
        new level("11_11", 0, 3 + 10 * (0 + i)),
        new level("9_13", 2, 5 + 10 * (0 + i)),
    //i = 1 dek dek test dek
        new level("9_11_test", 2, 5 + 10 * (1 + i), true, [20, 15, 11]),
        new level("7_9", 7, 2 + 10 * (1 + i)),
    
        new level("11_11", 0, 3 + 10 * (1 + i)),
        new level("9_13", 5, 0 + 10 * (1 + i)),
    //i = 2 dek wrap cross dek
        new level("9_11_wrap", 5, 0 + 10 * (2 + i), true, [20, 15, 12]),
        new level("7_9", 7, 2 + 10 * (2 + i)),
    
        new level("11_11", 0, 3 + 10 * (2 + i)),
        new level("9_11_cross", 2, 5 + 10 * (2 + i), true, [20, 15, 13]),
    //i = 3 dek walls last dek
        new level("9_11_walls", 5, 0 + 10 * (3 + i), true, [20, 15, 12]),
        new level("7_9", 7, 2 + 10 * (3 + i)),
    
        new level("11_11", 0, 3 + 10 * (3 + i)),
        new level("9_13_last", 2, 5 + 10 * (3 + i), true, [25, 20, 17]),
    //i = 4 dek dek dek dek
        new level("11_11", 0, 3 + 10 * (4 + i)),
        new level("9_13", 2, 5 + 10 * (4 + i)),
    
        new level("7_9", 5, 0 + 10 * (4 + i)),
        new level("7_9", 7, 2 + 10 * (4 + i)),
    );
    
    i = 6;
    array_push(global.levels,
    //-------------------------
        new level("7_9", 5, 0 + 10 * (0 + i)),
        new level("7_9", 7, 2 + 10 * (0 + i)),
    
        new level("11_11", 0, 3 + 10 * (0 + i)),
        new level("9_13", 2, 5 + 10 * (0 + i)),
    //-------------------------
        new level("9_13_4_3_4_0_4_1_0_1795845498", 2, 5 + 10 * (1 + i), true, [30, 20, 18]),
        new level("7_9", 7, 2 + 10 * (1 + i)),
    
        new level("11_11", 0, 3 + 10 * (1 + i)),
        new level("9_13", 5, 0 + 10 * (1 + i)),
    //-------------------------
        new level("9_13_4_3_4_0_4_1_0_2275901463", 5, 0 + 10 * (2 + i), true, [25, 22, 18]),//Solver zwrócił mi 25 18 18 podbiłem środkową gwiazdkę
        new level("7_9", 7, 2 + 10 * (2 + i)),
    
        new level("11_11", 0, 3 + 10 * (2 + i)),
        new level("9_13_4_3_1_1_4_1_0_1947235746", 2, 5 + 10 * (2 + i), true, [30, 25, 20]),//Solver zwrócił mi 20 20 30 podbiłem środkową gwiazdkę
    //-------------------------
        new level("9_13_4_3_1_1_4_1_0_2578357245", 5, 0 + 10 * (3 + i), true, [25, 19, 16]),
        new level("7_9", 7, 2 + 10 * (3 + i)),
    
        new level("11_11", 0, 3 + 10 * (3 + i)),
        new level("9_13_4_3_2_2_4_1_1_3943296509", 2, 5 + 10 * (3 + i), true, [30, 25, 21]),//Solver zwrócił mi 30 22 21 podbiłem środkową gwiazdkę
    //-------------------------
        new level("11_11", 0, 3 + 10 * (4 + i)),
        new level("9_13", 2, 5 + 10 * (4 + i)),
    
        new level("7_9", 5, 0 + 10 * (4 + i)),
        new level("7_9", 7, 2 + 10 * (4 + i)),
    );
    
    
    array_push(global.bioms, 
    new biom(904, 12),
    new biom(904 * 2, 24),
    )
    
    global.choosedLevel = 0;
    
    global.aspect = 9 / 20;
    
    if (MOBILE)
    {
        global.aspect = display_get_width() / display_get_height();
        surface_resize(application_surface, display_get_width(), display_get_height());
        camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);    
    }
}