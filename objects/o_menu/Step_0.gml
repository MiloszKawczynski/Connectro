ui.step();

if (mouse_check_button_pressed(mb_right))
{
	if (clipboard_has_text())
	{
		var clip = clipboard_get_text();
		
        setSeed(clip);
        
        ui.widthInput.content = string(global.width);
        ui.widthInput.focus = true;
        
        ui.heightInput.content = string(global.height);
        ui.heightInput.focus = true;
        
        ui.crossRatio.content = string(global.crossRatio);
        ui.crossRatio.focus = true;
        
        ui.diamondRatio.content = string(global.diamondRatio);
        ui.diamondRatio.focus = true;
        
        ui.lineRatio.content = string(global.lineRatio);
        ui.lineRatio.focus = true;
        
        ui.diagRatio.content = string(global.diagRatio);
        ui.diagRatio.focus = true;
        
        ui.plusRatio.content = string(global.plusRatio);
        ui.plusRatio.focus = true;
        
        ui.blockRatio.content = string(global.blockRatio);
        ui.blockRatio.focus = true;
        
        ui.targetRatio.content = string(global.targetRatio);
        ui.targetRatio.focus = true;

        ui.seedInput.content = string(global.seed);
        ui.seedInput.focus = true;
	}
}
