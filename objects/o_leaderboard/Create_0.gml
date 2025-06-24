event_inherited();

highscores = "";

fadeAlpha = 1;
fade = false;
fadeFunction = undefined;

ui = new UI();

goBackFunctionFade = function()
{
    room_goto(r_init);
}

with(ui)
{
    logoTimer = 0;
    init = true;
    
	mainLayer = new Layer();
	mainLayer.setGrid(6, 13);
    
    vignetteL = new Output();
    vignetteL.setSprite(s_menuVignette);
    
    vignetteR = new Output();
    vignetteR.setSprite(s_menuVignette);
    vignetteR.setScale(-1, 1);
    
    logo = new Output();
    logo.setSprite(s_logo);
    
	var goBackFunction = function()
	{
        o_leaderboard.fade = true;
        o_leaderboard.fadeFunction = o_leaderboard.goBackFunctionFade;
	}
	
	goBackButton = new Button(goBackFunction);
    goBackButton.setSpriteSheet(s_uiGoBack);
	
	highscores = LLHighscoresTopFormatted();
	highscoresArray = string_split(highscores, "\n");
	
	var playerScore = real(LLPlayerScore());
	var playerRank = 999;
	
	for (var s = 0; s < array_length(highscoresArray); ++s)
	{
		var split = string_split(highscoresArray[s], " ");
		
		var mapsIndex = array_length(split) - 2;
		
		if (mapsIndex < 0)
		{
			break;
		}
		
		if (playerScore >= split[mapsIndex])
		{
			playerRank = s + 1;
			break;
		}
	}
	
	var leaderboard = [];
	var i = 0;
	for (i = 0; i < 5; ++i)
	{
		if (i >= array_length(highscoresArray))
		{
			break;
		}
		
		leaderboard[i] = new Text(highscoresArray[i], f_base);
		leaderboard[i].setScale(2, 2);
		mainLayer.addComponent(3, 3.5 + i, leaderboard[i]);
	}
	
	var myScoreString = string(playerRank) + ". " + "YOU" + "     " + LLPlayerScore();

	var myScore = new Text(myScoreString, f_base);
	myScore.setScale(2, 2);
	myScore.setColor(c_lime);
	mainLayer.addComponent(3, 3.5 + 6, myScore);
	
	var notification = new Text("Your rank may take some\ntime to update.", f_base);
	notification.setScale(2, 2);
	mainLayer.addComponent(3, 3.5 + 6.8, notification);

    mainLayer.addComponent(0, 0, vignetteL);
    mainLayer.addComponent(6, 0, vignetteR);
    mainLayer.addComponent(0, -5, logo);
	mainLayer.addComponent(1, 12.25, goBackButton);
	
	pushLayer(mainLayer);
}