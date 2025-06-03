array_push(global.levels,
            new level(global.seed, -999, -999, [30, 25, 20]));

global.choosedLevel = array_length(global.levels) - 1 ;

room_goto(r_game);
//room_goto(r_map);
