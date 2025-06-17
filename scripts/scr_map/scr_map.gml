function calculateGainedStars()
{
    gainedStars = 0;
    for (var i = 0; i < array_length(global.levels); i++)
    {
        if (!global.levels[i].hasMural)
        {
            continue;
        }
        
        gainedStars += global.levels[i].stars;
    }
}

function calculateActiveBarier()
{
    activeBarier = -1;
    for (var i = 0; i < array_length(global.bioms); i++)
    {
        if (global.bioms[i].limit > gainedStars)
        {
            activeBarier = i;
            break;
        }
    }
    
    if (activeBarier != -1)
    {
        scrollMax = global.bioms[activeBarier].y - 1010 * 1.5;
        createBariarSurface = true;
    }
}

function debugManipulation()
{
    if (keyboard_check_pressed(vk_f6))
    {
        gainedStars += 10;
        
        calculateActiveBarier();
    }
    
    var cameraSpeed = 0.1;
    
    if (keyboard_check(vk_lshift))
    {
        cameraSpeed = 2;
    }
    
    x += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * cameraSpeed;
    y += (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * cameraSpeed;
    z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * cameraSpeed;
    r += (keyboard_check(ord("I")) - keyboard_check(ord("O"))) * cameraSpeed;
    
    if (keyboard_check_pressed(ord("R")))
    {
        x = 0;
        y = 0;
        z = 0;
        r = 0;
    }
    
    if (keyboard_check_pressed(vk_lcontrol))
    {
        x = floor(x);
        y = floor(y);
        z = floor(z);
        r = floor(r);
    }
    
    if (keyboard_check_pressed(ord("P")))
    {
        show_debug_message(string("x: {0}, y: {1}, z: {2}, r: {3}, s: {4}", x, y, z, r, scrollPositionFinal));
    }
}

function createBarierSurface()
{
    if (activeBarier == -1)
    {
        return;
    }
    
    if (createBariarSurface)
    {
        createBariarSurface = false;
        
        var surf = surface_create(200, 64);
        surface_set_target(surf);
        draw_clear_alpha(c_white, 0);
        draw_set_color(c_white);
        draw_set_alpha(1);
        
        draw_sprite(s_barier, 0, 0, 0);
        draw_set_font(f_game);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        font_enable_effects(f_game, true, 
        {
            outlineEnable: true,
            outlineDistance: 4,
            outlineColour: c_black
        });
        
        draw_text_transformed(95, 36, global.bioms[activeBarier].limit, 0.75, 0.75, 0);
        surface_reset_target();
        
        star = sprite_get_texture(sprite_create_from_surface(surf, 0, 0, 200, 64, false, false, 0, 0), 0);
    }
}