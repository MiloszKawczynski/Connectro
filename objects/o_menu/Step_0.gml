ui.step();

if (mouse_check_button_pressed(mb_right))
{
	if (clipboard_has_text())
	{
		var clip = clipboard_get_text();
		var parts = string_split(clip, "_");
		
		if (array_length(parts) == 10)
		{
			global.width        = real(parts[0]);
			ui.widthInput.content = string(global.width);
			ui.widthInput.focus = true;
			
			global.height       = real(parts[1]);
			ui.heightInput.content = string(global.height);
			ui.heightInput.focus = true;
			
			global.crossRatio   = real(parts[2]);
			ui.crossRatio.content = string(global.crossRatio);
			ui.crossRatio.focus = true;
			
			global.diamondRatio = real(parts[3]);
			ui.diamondRatio.content = string(global.diamondRatio);
			ui.diamondRatio.focus = true;
			
			global.lineRatio    = real(parts[4]);
			ui.lineRatio.content = string(global.lineRatio);
			ui.lineRatio.focus = true;
			
			global.diagRatio    = real(parts[5]);
			ui.diagRatio.content = string(global.diagRatio);
			ui.diagRatio.focus = true;
			
			global.plusRatio    = real(parts[6]);
			ui.plusRatio.content = string(global.plusRatio);
			ui.plusRatio.focus = true;
			
			global.blockRatio   = real(parts[7]);
			ui.blockRatio.content = string(global.blockRatio);
			ui.blockRatio.focus = true;
			
			global.targetRatio  = real(parts[8]);
			ui.targetRatio.content = string(global.targetRatio);
			ui.targetRatio.focus = true;
			
			global.seed = real(parts[9]);
			ui.seedInput.content = string(global.seed);
			ui.seedInput.focus = true;
		}
	}
}
