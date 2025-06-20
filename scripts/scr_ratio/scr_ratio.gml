function adjustCamera()
{
    if (global.aspect <= 0.48)
    {
        surface_resize(application_surface, display_get_width(), display_get_height());
        camera_set_view_size(view_get_camera(0), room_width, room_width / global.aspect);    
        show_debug_message(string("ratio: {0}", room_width / (room_width / global.aspect)));
    }
}