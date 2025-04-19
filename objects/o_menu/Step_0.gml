ui.step();

if (mouse_check_button_pressed(mb_right))
{
	if (clipboard_has_text())
	{
		var clip = string_digits(clipboard_get_text());
		if (string_length(clip) > 0)
		{
			global.seed = real(real(clip));
			ui.seedInput.content = string(global.seed);
			ui.seedInput.focus = true;
		}
	}
}