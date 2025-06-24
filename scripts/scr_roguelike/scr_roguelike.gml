function createPaintUI(_type, _value, _paintId)
{
    with(ui)
    {
        var takePaint = function ()  { }
        var putPaint = function(posX, posY) 
        { 
            var paintPosX = other.posX;
            var paintPosY = other.posY;
            var originalTile;
            
            originalTile = ds_grid_get(o_connectro.grid, other.paintX, other.paintY);
            
            if ((posY < o_connectro.gameOffset or posY > o_connectro.gameOffset + global.cellSize * global.height)
            or (originalTile.isAvailable or originalTile.isRevealed))
            {
                with(other)
                {
                    setShift(0, 0);
                }
            }
            else 
            {
                var paintType = other.type;
                var paintValue = other.value;
                var paintX = other.paintX;
                var paintY = other.paintY;
                var name = other.name;
                
                with(o_connectro)
                {
                    var paintTile = new Tile(paintType);
                    
                    if (paintType == 0 or paintType == 1 or paintType == 10)
                    { 
                        paintTile.isAvailable = true;
                        paintTile.value = paintValue;
                        
                        if (paintType == 10)
                        {
                            paintTile.type = 4;
                            paintTile.setColorFromType();
                        }
                    
                        ds_grid_set(grid, paintX, paintY, paintTile)
                        normalTileEffect(false, paintX, paintY);
                    }
                    
                    if (paintType >= 2 and paintType <= 5)
                    {
                        var tile = ds_grid_get(grid, paintX, paintY);
                        paintTile.type = 2;
                        paintTile.value = paintValue + 1;
                        paintTile.setColorFromType();
                        
                        tile.lineDirection = paintType - 2;
                        tile.sourceTile = paintTile;
                        tile.isLineDiag = false;
                        mustPickDirectionTileEffect(false, paintX, paintY);
                    }
                    
                    if (paintType >= 6 and paintType <= 9)
                    {
                        var tile = ds_grid_get(grid, paintX, paintY);
                        paintTile.type = 3;
                        paintTile.value = paintValue + 1;
                        paintTile.setColorFromType();
                        
                        tile.lineDirection = paintType - 6;
                        tile.sourceTile = paintTile;
                        tile.isLineDiag = true;
                        mustPickDirectionTileEffect(false, paintX, paintY);
                    }
                    
                    if (paintType == 11)
                    {
                        var tile = ds_grid_get(grid, paintX, paintY);
                        paintTile.type = 4;
                        
                        tile.isTargeted = true;
                        tile.sourceTile = paintTile;
                        mustPickTargetTileEffect(false, paintX, paintY);
                    }
                    global.paints[string_digits(name)] = undefined;
                    moves--;
                    checkForUselessness(false);
                    saveGame(moves);
                }
                
                with(other.containerImIn)
                {
                    for(var i = 0; i < ds_list_size(components); i++)
                    {
                        if (ds_list_find_value(components, i).name == name)
                        {
                            ds_list_delete(components, i);
                            break;
                        }
                    }
                }
            }
        }
        
        var paint = new DragAndDrop(takePaint, putPaint);
        
        with(paint)
        {
            swing = 0;
            type = _type;
            value = _value;
            name = string("paint{0}", _paintId);
            show_debug_message(name);
            paintX = -1;
            paintY = -1;
            hoveredTile = undefined;
            
            var normalFunction = function()
            {
                draw_sprite_ext(s_paint, type, posX, posY, 3, 3, 0, c_white, 1);
                draw_sprite_ext(s_valuePaint, value, posX, posY, 3, 3, 0, c_white, 1);
            }
            
            var pressFunction = function()
            {
                swing++;
                draw_sprite_ext(s_paint, type, posX, posY, 3, 3, sin(swing / 10) * 15, c_white, 1);
                draw_sprite_ext(s_valuePaint, value, posX, posY, 3, 3, sin(swing / 10) * 15, c_white, 1);
            }
            
            setDrawFunctions(normalFunction,, pressFunction,, 15 * 3, 15 * 3);
            
            step = function()
    		{
    			if (hover)
    			{
    				if (isPressed())
    				{
    					lastPosX = posX - shiftX;
    					lastPosY = posY - shiftY;
    					
    					onClick(posX, posY);
    				}
    			}
    			
    			if (press)
    			{
                    if (o_connectro.gameState == pickCard)
                    {
                        return;
                    }
                    
    				shiftX = device_mouse_x_to_gui(0) - lastPosX;
    				shiftY = device_mouse_y_to_gui(0) - lastPosY;
                    ui.getMainGroup().update();
                    
                    var paintPosX = other.posX;
                    var paintPosY = other.posY;
                    var originalTile;
                    var tileWasChanged = false;
                    
                    var paintBeforeX = paintX;
                    var paintBeforeY = paintY;
            
                    with(o_connectro)
                    {
                        for(var yy = 0; yy < global.height; yy++)
                        {
                            for(var xx = 0; xx < global.width; xx++)
                            {
                                if (paintPosX > xx * global.cellSize and paintPosX < xx * global.cellSize + global.cellSize)
                                {
                                    if (paintPosY - gameOffset > yy * global.cellSize and paintPosY - gameOffset < yy * global.cellSize + global.cellSize)
                                    {
                                        if (other.paintX != xx or other.paintY != yy)
                                        {
                                            other.paintX = xx;
                                            other.paintY = yy;
                                            tileWasChanged = true;
                                        }
                                    }
                                }
                            }
                        }
                        
                        originalTile = ds_grid_get(grid, other.paintX, other.paintY);
                    }
                    
                    if (paintX != -1 and paintY != -1 and !originalTile.isAvailable and !originalTile.isRevealed)
                    {
                        var paintType = other.type;
                        var paintValue = other.value;
                            
                        with(o_connectro)
                        {
                            if (tileWasChanged)
                            {
                                if (other.hoveredTile != undefined)  
                                {
                                    ds_grid_set(grid, paintBeforeX, paintBeforeY, other.hoveredTile)
                                }
                                other.hoveredTile = originalTile;
                                
                                if (paintType == 11)
                                {
                                    other.hoveredTile.potential = 3;
                                }
                                else if (paintType >= 2 and paintType <= 5)
                                {
                                    var parentTile = new Tile(2);
                                    parentTile.value = paintValue + 1;
                                    
                                    var paintTile = new Tile(0);
                                    ds_grid_set(grid, other.paintX, other.paintY, paintTile)
                                    paintTile.lineDirection = paintType - 2;
                                    paintTile.sourceTile = parentTile;
                                    paintTile.isAvailable = true; 
                                	    mustPickDirectionTileEffect(true, other.paintX, other.paintY);
                                    paintTile.isAvailable = false;
                                    paintTile.potential = 1;
                                    paintTile.lineDirection = -1;
                                }
                                else if (paintType >= 6 and paintType <= 9)
                                {
                                    var parentTile = new Tile(3);
                                    parentTile.value = paintValue + 1;
                                    
                                    var paintTile = new Tile(0);
                                    ds_grid_set(grid, other.paintX, other.paintY, paintTile)
                                    paintTile.lineDirection = paintType - 6;
                                    paintTile.sourceTile = parentTile;
                                    paintTile.isLineDiag = true; 
                                    paintTile.isAvailable = true; 
                                	    mustPickDirectionTileEffect(true, other.paintX, other.paintY);
                                    paintTile.isAvailable = false;
                                    paintTile.isLineDiag = false; 
                                    paintTile.potential = 1;
                                    paintTile.lineDirection = -1;
                                }
                                else 
                                {
                                    var paintTile = new Tile(paintType);
                                    
                                    if (paintType == 10)
                                    {
                                        paintTile.type = 4;
                                    }
                                
                                    ds_grid_set(grid, other.paintX, other.paintY, paintTile)
                                    paintTile.value = paintValue;
                                    paintTile.isAvailable = true;
                                	    normalTileEffect(true, other.paintX, other.paintY);
                                    paintTile.isAvailable = false;
                                    paintTile.potential = 1;
                                }
                            }
                            else 
                            {
                                if (paintType == 11)
                                {
                                    other.hoveredTile.potential = 3;
                                }
                                else if (paintType >= 2 and paintType <= 5)
                                { 
                                    var parentTile = new Tile(2);
                                    parentTile.value = paintValue + 1;
                                    
                                    var tile = ds_grid_get(grid, other.paintX, other.paintY);
                                    tile.lineDirection = paintType - 2;
                                    tile.sourceTile = parentTile;
                                    tile.isAvailable = true;
                                	    mustPickDirectionTileEffect(true, other.paintX, other.paintY);
                                    tile.isAvailable = false;
                                    tile.potential = 1;
                                    tile.lineDirection = -1;
                                }
                                else if (paintType >= 6 and paintType <= 9)
                                {
                                    var parentTile = new Tile(3);
                                    parentTile.value = paintValue + 1;
                                    
                                    var tile = ds_grid_get(grid, other.paintX, other.paintY);
                                    tile.lineDirection = paintType - 6;
                                    tile.sourceTile = parentTile;
                                    tile.isLineDiag = true;
                                    tile.isAvailable = true;
                                	    mustPickDirectionTileEffect(true, other.paintX, other.paintY);
                                    tile.isAvailable = false;
                                    tile.isLineDiag = false;
                                    tile.potential = 1;
                                    tile.lineDirection = -1;
                                }
                                else 
                                {
                                    var tile = ds_grid_get(grid, other.paintX, other.paintY);
                                    tile.isAvailable = true;
                                	    normalTileEffect(true, other.paintX, other.paintY);
                                    tile.isAvailable = false;
                                    tile.potential = 1;
                                }
                            }
                        }
                    }
                    else 
                    {
                    	hoveredTile = undefined;
                    }
                    
                    
                    if (paintPosY < o_connectro.gameOffset or paintPosY > o_connectro.gameOffset + global.cellSize * global.height)
                    {
                        with(o_connectro)
                        {
                            removePotential();
                            removeTarget();
                            removeDirections();
                        }
                    }
    			}	
    			
    			if (isReleased())
    			{
    				if (click)
    				{
    					onDrop(posX, posY);
    				}
    			}
    		}
        }
        
        mainLayer.addComponent(2.25 + _paintId * 1.25, 13.25, paint);
    }
}

function findEmptySpot()
{
    var firstEmpty = array_length(global.paints);
    
    for(var i = 0; i < array_length(global.paints); i++)
    {
        if (global.paints[i] == undefined)
        {
            firstEmpty = i;
            break;
        }
    }
    
    return firstEmpty;
}

function createPaint(_type, _value)
{
    var paintId = findEmptySpot();
    
    if (paintId == 3)
    {
        return;
    }
    
    createPaintUI(_type, _value, paintId);
    
    global.paints[paintId] = { t: _type, v: _value, paintId: paintId};
}

function createPaintsCards(_tier)
{
    with(ui)
    {
        isAnyPick = false;
        levelProgress = false;
        
        background = new Output();
        with(background)
        {
            isShow = false;
            draw = function()
            {
                if (!isShow)
                {
                    isShow = true;
                    o_connectro.fade = false;
                    o_connectro.fadeAlpha = 0;
                }
                draw_set_color(c_black);
                draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
            }
        }
        
        paintsLayer.addComponent(3.5, 6.5, background);
        
        gameNumber = new Text(string(global.roguelikeLevelNumber - 1), f_menu);
        gameNumber.setScale(3, 3);
        
        newGameNumber = new Text(string(global.roguelikeLevelNumber), f_menu);
        newGameNumber.setScale(3, 3);
        
        with(gameNumber)
        {
            audio_sound_gain(sn_town, 0.1, 100);
            
            wait = 0;
            step = function()
            {
                if (ui.levelProgress)
                {
                    wait++;
                    if (wait == 30)
                    {
                        audio_play_sound(sn_roguelikeProgress, 0, false);
                    }
                    if (wait > 30)
                    {
                        setPositionInGrid(lerp(posInGridX, -3.7 * 2, 0.02), posInGridY);
                    }
                }
            }
        }
        
        with(newGameNumber)
        {
            wait = 0;
            step = function()
            {
                if (ui.levelProgress)
                {
                    wait++;
                    if (wait > 30)
                    {
                        setPositionInGrid(lerp(posInGridX, 3.7, 0.02), posInGridY);
                        
                        if (posInGridX < 3.8)
                        {
                            with(o_connectro)
                            {
                                fadeFunction = goToNextLevelFade;
                                fade = true;
                            }
                        }
                    }
                }
            }
        }
        
        paintsLayer.addComponent(3.7, 6.5, gameNumber);
        paintsLayer.addComponent(3.7 * 3, 6.5, newGameNumber);
        
        if (_tier > 0)
        {
            cardsSlot = new Output();
            cardsSlot.setSprite(s_paintCardSlot);
            cardsSlot.setScale(0, 0);
            
            with(cardsSlot)
            {
                step = function()
                {
                    if (!ui.isAnyPick)
                    {
                        setScale(lerp(scaleX, 5.2 / 4, 0.2), lerp(scaleY, 1.1, 0.2));
                    }
                    else 
                    {
                        setScale(lerp(scaleX, 0, 0.2), lerp(scaleY, 0, 0.2));
                    }
                }
            }
        
            paintsLayer.addComponent(3.5, 6.5, cardsSlot);
        
            var pickPaint = function()
            {
                if (!other.ui.isAnyPick)
                {
                    audio_play_sound(sn_paintIsPicked, 0, false);
                    other.isPick = true;
                    other.ui.isAnyPick = true;
                }
            }
            
            for(var i = 0; i < 3; i++)
            {
                var paintCard = new Button(pickPaint);
                paintCard.setSprites(s_paintCard);
                paintCard.setScale(0, 0);
                
                with(paintCard)
                {
                    firstEmpty = findEmptySpot();
                    
                    //0 - plus
                    //1 - diamond
                    //2 [2 - 5] - lines
                    //3 [6 - 9] - diagonals
                    //4 - cross
                    //5 - target
                    switch(_tier)
                    {
                        case(1):
                        {
                            type = choose(2, 3, 5);
                            switch(type)
                            {
                                case(2):
                                {
                                    type = choose(2, 3, 4, 5);
                                    value = 3;
                                    break;
                                }
                                case(3):
                                {
                                    type = choose(6, 7, 8, 9);
                                    value = choose(2, 3);
                                    break;
                                }
                                case(5):
                                {
                                    type = 11;
                                    value = 1;
                                    break;
                                }
                            }
                            break;
                        }
                        
                        case(2):
                        {
                            type = choose(0, 1, 2, 3, 4);
                            switch(type)
                            {
                                case(0):
                                {
                                    value = choose(2, 3);
                                    break;
                                }
                                case(1):
                                {
                                    value = choose(1, 2);
                                    break;
                                }
                                case(2):
                                {
                                    type = choose(2, 3, 4, 5);
                                    value = choose(4, 5);
                                    break;
                                }
                                case(3):
                                {
                                    type = choose(6, 7, 8, 9);
                                    value = 4;
                                    break;
                                }
                                case(4):
                                {
                                    type = 10;
                                    value = choose(2, 3);
                                    break;
                                }
                            }
                            break;
                        }
                        
                        case(3):
                        {
                            type = choose(0, 1, 4);
                            switch(type)
                            {
                                case(0):
                                {
                                    value = choose(4, 5);
                                    break;
                                }
                                case(1):
                                {
                                    value = 3;
                                    break;
                                }
                                case(4):
                                {
                                    type = 10;
                                    value = choose(4, 5);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    isPick = false;
                    
                    var normalFunction = function()
                    {
                        draw_sprite_ext(s_paintCard, 0, posX, posY, scaleX, scaleY, 0, c_white, 1);
                        draw_sprite_ext(s_paintCardTile, type, posX, posY, scaleX, scaleY, 0, c_white, 1);
                        draw_sprite_ext(s_valuePaintCard, value, posX, posY, scaleX, scaleY, 0, c_white, 1);
                    }
                    
                    step = function()
            		{
            			if (click)
            			{
            				onClick(); 
            			}
                        
                        if (!ui.isAnyPick)
                        {
                            setScale(lerp(scaleX, 4, 0.2), lerp(scaleY, 4, 0.2));
                        }
                        else 
                        {
                        	if (isPick)
                            {
                                setScale(lerp(scaleX, 1.5, 0.2), lerp(scaleY, 1.5, 0.2));
                                setPositionInGrid(lerp(posInGridX, 2.25 + 1.25 * firstEmpty, 0.2), lerp(posInGridY, 13.25, 0.2));
                                
                                if (scaleX < 1.51 and !ui.levelProgress)
                                {
                                    with(ui)
                                    {
                                        levelProgress = true;
                                        createPaint(other.type, other.value);
                                    }
                                }
                            }
                            else 
                            {
                            	setScale(lerp(scaleX, 0, 0.2), lerp(scaleY, 0, 0.2));
                                setPositionInGrid(3.5, lerp(posInGridY, 6.5, 0.2));
                            }
                        }
                    }
                    
                    setDrawFunctions(normalFunction,,,, 15 * 8, 15 * 8);
                }
                
                switch(i)
                {
                    case(0):
                    {
                        paintsLayer.addComponent(3.5, 4.5, paintCard);
                        break;
                    }
                    case(1):
                    {
                        paintsLayer.addComponent(3.5, 7.375, paintCard);
                        break;
                    }
                    case(2):
                    {
                        paintsLayer.addComponent(3.5, 10.25, paintCard);
                        break;
                    }
                }
            }
        }
        
        chooseText = new Text(string("{0} stars prize\n\nChoose one", _tier), f_game);
        
        if (_tier == 1)
        {
            chooseText.setContent("1 star prize\n\nChoose one");
        }
        chooseText.setScale(0, 0);
        
        if (_tier == 0)
        {
            chooseText.setContent("0 stars\n\nNo prize\n\nfor you");
        }
        
        with(chooseText)
        {
            tier = _tier;
            step = function()
            {
                if (!ui.isAnyPick)
                {
                    setScale(lerp(scaleX, 1, 0.2), lerp(scaleY, 1, 0.2));
                    setPositionInGrid(3.5, lerp(posInGridY, 2, 0.2));
                    
                    if (tier == 0 and scaleX > 0.99)
                    {
                        ui.levelProgress = true;
                    }
                }
                else 
                {
                    setScale(lerp(scaleX, 0, 0.2), lerp(scaleY, 0, 0.2));
                    setPositionInGrid(3.5, lerp(posInGridY, 6.5, 0.2));
                }
            }
        }
        
        paintsLayer.addComponent(3.5, 6.5, chooseText);
        
        pushLayer(paintsLayer);
    }
}

function isPaintInventoryEmpty()
{
    if (!global.isRoguelikeMode)
    {
        return false;
    }
    
    for (var i = 0; i < array_length(global.paints); i++)
    {
        if (global.paints[i] != undefined)
        {
            return false;
        }
    }
    return true;
}

function gameOverScreen()
{
    if (!global.isRoguelikeMode or isAllRevealed())
    {
        return;
    }
    
    with(ui)
    {
        if (global.roguelikeLevelNumber > global.roguelikeBest)
        {
            global.roguelikeBest = global.roguelikeLevelNumber;
            gameOverLayer.addComponent(3.5, 6.5, gameOverRecordText);
        }
        else 
        {
            gameOverBorder.crop = 0.1;
        	gameOverText.center = 0.75;
        	gameOverNoMoreMovesText.center = 0.75;
        	gameOverScoreText.center = 0.75;
        }
        
        var scoreContent = string("Score: {0}\n\nBest: {1}", global.roguelikeLevelNumber, global.roguelikeBest)
        global.roguelikeLevelNumber = 0;
        
        gameOverScoreText.setContent(scoreContent);
        pushLayer(gameOverLayer);
    }
    
    mouse_clear(mb_left);
    gameState = gameOver;
}