function createPaint(_type, _value)
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
            
            with(o_connectro)
            {
                var paintTile = new Tile(paintType);
                paintTile.isAvailable = true;
                paintTile.value = paintValue;
            
                ds_grid_set(grid, paintX, paintY, paintTile)
                normalTileEffect(false, paintX, paintY);
                moves--;
            }
            
            with(other.containerImIn)
            {
                for(var i = 0; i < ds_list_size(components); i++)
                {
                    if (ds_list_find_value(components, i).name == "paint0")
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
        name = "paint0";
        paintX = -1;
        paintY = -1;
        hoveredTile = undefined;
        
        var normalFunction = function()
        {
            draw_sprite_ext(s_paint, type, posX, posY, 4, 4, 0, c_white, 1);
            draw_sprite_ext(s_valuePaint, value, posX, posY, 4, 4, 0, c_white, 1);
        }
        
        var pressFunction = function()
        {
            swing++;
            draw_sprite_ext(s_paint, type, posX, posY, 4, 4, sin(swing / 10) * 15, c_white, 1);
            draw_sprite_ext(s_valuePaint, value, posX, posY, 4, 4, sin(swing / 10) * 15, c_white, 1);
        }
        
        setDrawFunctions(normalFunction,, pressFunction,, 15 * 4, 15 * 4);
        
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
    
    mainLayer.addComponent(3.5, 13.25, paint);
}