generateGame();

hoveredX = 0;
hoveredY = 0;

moves = 0;

drawSurface = false;
is3DCreated = false;

muralSurface = surface_create(global.width * global.cellSize, global.height * global.cellSize);
blockSurface = surface_create(33 * 5, 33);

buildingRotation = 0;
buildingRotationSpeed = 1;
buildingScale = 1;
buildingTilt = 0;

lastMousePosition = mouse_x;

gameState = levelStart;
drawState = normalDraw;

acTimer = -0.25;