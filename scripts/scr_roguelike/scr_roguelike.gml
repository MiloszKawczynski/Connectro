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
                    paintTile.isAvailable = true;
                    paintTile.value = paintValue;
                
                    ds_grid_set(grid, paintX, paintY, paintTile)
                    normalTileEffect(false, paintX, paintY);
                    array_delete(global.paints, string_digits(name), 1);
                    moves--;
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
                                
                                var paintTile = new Tile(paintType);
                                paintTile.isAvailable = true;
                                paintTile.value = paintValue;
                                
                                ds_grid_set(grid, other.paintX, other.paintY, paintTile)
                                normalTileEffect(true, other.paintX, other.paintY);
                                paintTile.isAvailable = false;
                                paintTile.potential = 1;
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
                    else 
                    {
                    	hoveredTile = undefined;
                    }
                    
                    if (paintPosY < o_connectro.gameOffset or paintPosY > o_connectro.gameOffset + global.cellSize * global.height)
                    {
                        with(o_connectro)
                        {
                            removePotential();
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

function createPaint(_type, _value)
{
    var paintId = array_length(global.paints);
    
    if (array_length(global.paints) == 3)
    {
        return;
    }
    
    createPaintUI(_type, _value, paintId);
    
    array_push(global.paints, { t: _type, v: _value, _paintId: paintId});
}

function createPaintsCards()
{
    var pickPaint = function()
    {
        other.isPick = true;
        other.ui.isAnyPick = true;
    }
    
    isAnyPick = false;
    
    for(var i = 0; i < 3; i++)
    {
        var paintCard = new Button(pickPaint);
        paintCard.setSprites(s_paintCard);
        paintCard.setScale(0, 0);
        
        with(paintCard)
        {
            type = irandom(3);
            value = irandom(3);
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
                        setPositionInGrid(lerp(posInGridX, 2.25 + 1.25 * array_length(global.paints), 0.2), lerp(posInGridY, 13.25, 0.2));
                        
                        if (scaleX < 1.51)
                        {
                            with(ui)
                            {
                                createPaint(other.type, other.value);
                                popLayer();
                            }
                        }
                    }
                    else 
                    {
                    	setScale(lerp(scaleX, 0, 0.2), lerp(scaleY, 0, 0.2));
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