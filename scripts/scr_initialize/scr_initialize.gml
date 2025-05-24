function initialize()
{
    #macro Windows:INVERT 1 
    #macro Android:INVERT -1
    
    function level(_seed, _x, _y) constructor 
    {
        seed = _seed;
        x = _x;
        y = _y;
        stars = 0;
        moves = 0;
        movesToStar = 37;
        texture = sprite_get_texture(s_block, 1);
    }
    
    global.levels = array_create(0);
    
    for (var i = 0; i < 100; i++)
    {
        array_push(global.levels,
            new level("11_11_2_4_2_2_2_1_1_368711115", 17 * lerp(-1, 1, i mod 2), 55 - 90 * i));
    }
    
    global.choosedLevel = 0;
}