function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    #macro Windows:MOBILE false 
    #macro Android:MOBILE true
	
	global.savedDataFilename = "SavedData.save";
	
	#macro MAX_MAP_WIDTH_OR_HEIGHT 25

	global.mapKeys = array_create();
	global.mapObjects = array_create();

	for(var _x = 0; _x < MAX_MAP_WIDTH_OR_HEIGHT; _x++)
	{
	    var mk = array_create();
	    var mo = array_create();

	    for(var _y = 0; _y < MAX_MAP_WIDTH_OR_HEIGHT; _y++)
	    {
	        array_push(mk, string("{0}_{1}", _x, _y));
	        array_push(mo, {x: _x, y: _y});
	    }

	    array_push(global.mapKeys, mk);
	    array_push(global.mapObjects, mo);
	}
	
	global.loadedLevels = false;
    
    function level(_seed, _x = 0, _y = 0, _hasMural = false, _movesToStar = [0, 0, 0], _roguelike = false) constructor 
    {
        seed = _seed;
        stars = 0;
        movesToStar = _movesToStar;
        typeOfLoad = 1;
        hasMural = _hasMural;
        splitSeed = string_split(seed, "_");
        width = real(splitSeed[0]);
        height = real(splitSeed[1]);
        color = c_aqua;
        
        if (hasMural)
        {
            if (string_digits(splitSeed[2]) == "")
            {
                seed = splitSeed[2];
                typeOfLoad = 2;
            }
        }
        
        if (!_roguelike)
        {
            x = 32 * (_x - 7 / 2);
            y = (-_y + 47) * 32 - 15;
            moves = 999;
            shoutRotation = 0;
            
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
            
            biomImIn = 0;
            for (var i = 0; i < array_length(global.bioms); i++)
            {
                biomImIn = i;
                
                if (global.bioms[i].y > -y + 1010 * 1.5)
                {
                    break;
                }
            }
            
            color = global.bioms[biomImIn].color;
            
            sprite = s_block1_1;
            
            if (biomImIn == 0)
            {
                if (width == height)
                {
                    sprite = choose(s_block1_1, s_blockBrick1_1);
                }
                
                if (width == 7 and height == 9)
                {
                    sprite = choose(s_block7_9, s_blockBrick7_9);
                }
                
                if (width == 9 and height == 11)
                {
                    sprite = choose(s_block9_11, s_blockBrick9_11);
                }
                
                if (width == 9 and height == 13)
                {
                    sprite = choose(s_block9_13, s_blockBrick9_13);
                }
            }
            
            if (biomImIn == 1)
            {
                if (width == height)
                {
                    sprite = s_blockCity1_1;
                }
                
                if (width == 7 and height == 9)
                {
                    sprite = s_blockCity7_9;
                }
                
                if (width == 9 and height == 11)
                {
                    sprite = s_blockCity9_11;
                }
                
                if (width == 9 and height == 13)
                {
                    sprite = s_blockCity9_13;
                }
            }
        
        
            texture = sprite_get_texture(sprite, 1);
            
            model = createWall(width, height, 64);
        }
    }
    
    function biom(_y, _limit, _color) constructor 
    {
        y = _y * 2 - 13
        limit = _limit;
        color = _color;
    }
    
    global.levels = array_create(0);
    global.bioms = array_create(0);
    global.rogelikeLevels = array_create(0);
    
    array_push(global.bioms, 
    new biom(904, 12, make_color_rgb(0, 74, 11)),
    new biom(904 * 2, 24, make_color_rgb(83, 26, 22)),
    )
    
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
    
    global.choosedLevel = 0;
    
    array_push(global.rogelikeLevels,
        new level("9_13_2_4_2_2_2_1_1_193688684",,, true, [35, 29, 18], true),
        new level("9_13_2_4_2_2_2_1_1_1151057660",,, true, [25, 19, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3552629797",,, true, [40, 32, 24], true),
        new level("9_13_2_4_2_2_2_1_1_3153640861",,, true, [30, 24, 20], true),
        new level("9_13_2_4_2_2_2_1_1_4021875037",,, true, [30, 22, 20], true),
        new level("9_13_2_4_2_2_2_1_1_2811738548",,, true, [35, 25, 20], true),
        new level("9_13_2_4_2_2_2_1_1_3187441689",,, true, [30, 22, 17], true),
        new level("9_13_2_4_2_2_2_1_1_3726692355",,, true, [25, 19, 18], true),
        new level("9_13_2_4_2_2_2_1_1_2276301258",,, true, [45, 37, 22], true),
        new level("9_13_2_4_2_2_2_1_1_444010586",,, true, [30, 24, 25], true),
        new level("9_13_2_4_2_2_2_1_1_638266406",,, true, [30, 23, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3788763126",,, true, [25, 19, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3555188026",,, true, [30, 23, 20], true),
        new level("9_13_2_4_2_2_2_1_1_3569671911",,, true, [25, 19, 22], true),
        new level("9_13_2_4_2_2_2_1_1_593320250",,, true, [25, 19, 18], true),
        new level("9_13_2_4_2_2_2_1_1_1335902531",,, true, [35, 29, 21], true),
        new level("9_13_2_4_2_2_2_1_1_3113663563",,, true, [30, 21, 15], true),
        new level("9_13_2_4_2_2_2_1_1_1252543605",,, true, [30, 24, 25], true),
        new level("9_13_2_4_2_2_2_1_1_346952331",,, true, [30, 22, 16], true),
        new level("9_13_2_4_2_2_2_1_1_2015002233",,, true, [30, 20, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3855613842",,, true, [35, 25, 22], true),
        new level("9_13_2_4_2_2_2_1_1_3621924303",,, true, [30, 24, 17], true),
        new level("9_13_2_4_2_2_2_1_1_2720513050",,, true, [30, 23, 19], true),
        new level("9_13_2_4_2_2_2_1_1_1833129828",,, true, [30, 22, 20], true),
        new level("9_13_2_4_2_2_2_1_1_2785582165",,, true, [25, 15, 16], true),
        new level("9_13_2_4_2_2_2_1_1_980730966",,, true, [30, 22, 20], true),
        new level("9_13_2_4_2_2_2_1_1_579544238",,, true, [30, 24, 21], true),
        new level("9_13_2_4_2_2_2_1_1_2561639116",,, true, [35, 27, 21], true),
        new level("9_13_2_4_2_2_2_1_1_4148295970",,, true, [40, 33, 19], true),
        new level("9_13_2_4_2_2_2_1_1_1395676437",,, true, [35, 27, 20], true),
        new level("9_13_2_4_2_2_2_1_1_1366510352",,, true, [40, 30, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3981043631",,, true, [35, 25, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3984713639",,, true, [30, 22, 17], true),
        new level("9_13_2_4_2_2_2_1_1_593439025",,, true, [30, 21, 19], true),
        new level("9_13_2_4_2_2_2_1_1_113187993",,, true, [30, 24, 22], true),
        new level("9_13_2_4_2_2_2_1_1_3776315255",,, true, [30, 21, 18], true),
        new level("9_13_2_4_2_2_2_1_1_1142836796",,, true, [25, 18, 15], true),
        new level("9_13_2_4_2_2_2_1_1_919222548",,, true, [35, 25, 21], true),
        new level("9_13_2_4_2_2_2_1_1_2556141117",,, true, [30, 23, 19], true),
        new level("9_13_2_4_2_2_2_1_1_3892571617",,, true, [30, 20, 19], true),
        new level("9_13_2_4_2_2_2_1_1_2432669405",,, true, [35, 29, 23], true),
        new level("9_13_2_4_2_2_2_1_1_4194693155",,, true, [25, 18, 17], true),
        new level("9_13_2_4_2_2_2_1_1_163117018",,, true, [30, 21, 18], true),
        new level("9_13_2_4_2_2_2_1_1_277555797",,, true, [35, 26, 18], true),
        new level("9_13_2_4_2_2_2_1_1_3965380132",,, true, [35, 25, 21], true),
        new level("9_13_2_4_2_2_2_1_1_1670474159",,, true, [35, 25, 23], true),
        new level("9_13_2_4_2_2_2_1_1_2700191507",,, true, [35, 29, 19], true),
    )
    
    global.aspect = 9 / 20;
    global.positionOnMap = -1010;
    
    if (MOBILE)
    {
        global.aspect = display_get_width() / display_get_height();
        surface_resize(application_surface, display_get_width(), display_get_height());
        camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);    
    }
}