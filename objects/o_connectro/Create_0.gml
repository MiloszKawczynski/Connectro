if (global.seed == 0)
{
	randomize();
}

grid = ds_grid_create(global.width, global.height);

generateGame();

hoveredX = 0;
hoveredY = 0;

moves = 0;

drawSurface = false;
is3DCreated = false;

muralSurface = surface_create(global.width * global.cellSize, global.height * global.cellSize);
blockSurface = surface_create(39 * 5, 39);

buildingRotation = 0;
buildingFingerRotation = 0;
buildingRotationSpeed = 1;
buildingScale = 1;
buildingTilt = 0;

lastMousePosition = mouse_x;
lastMousePositionPressed = mouse_x;

longPress = 0;

editorType = 0;
editorValue = 1;

if (global.isEditorOn)
{
    gameState = editor;
    drawState = editorDraw;
}
else 
{
	gameState = normal;
    drawState = normalDraw;
}