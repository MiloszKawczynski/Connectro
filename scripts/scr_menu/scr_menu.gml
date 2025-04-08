function calculateAllRatio()
{
	global.allRatio = global.crossRatio + global.diamondRatio + global.lineRatio + global.diagRatio + global.plusRatio + global.blockRatio + global.targetRatio;
}

function updateAllRatio()
{
	calculateAllRatio();
	ui.crossRatioText.setContent(string("Cross ratio: {0}%", global.crossRatio / global.allRatio * 100));
	ui.diamondRatioText.setContent(string("Diamond ratio: {0}%", global.diamondRatio / global.allRatio * 100));
	ui.lineRatioText.setContent(string("Line ratio: {0}%", global.lineRatio / global.allRatio * 100));
	ui.diagRatioText.setContent(string("Diag ratio: {0}%", global.diagRatio / global.allRatio * 100));
	ui.plusRatioText.setContent(string("Plus ratio: {0}%", global.plusRatio / global.allRatio * 100));
	ui.blockRatioText.setContent(string("Block ratio: {0}%", global.blockRatio / global.allRatio * 100));
	ui.targetRatioText.setContent(string("Target ratio: {0}%", global.targetRatio / global.allRatio * 100));
}