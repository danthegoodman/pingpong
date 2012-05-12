PAGES = new PageManager()

$ ->
	PAGES.add new SetupPage(el: $ '#setup' )
	PAGES.add new GamePage(el: $ '#game' )
	PAGES.add new GameOverPage(el: $ '#gameover' )

	gameInProgress = null

	playersFetched = PlayerList.fetch()
	gameFetched = new $.Deferred()
	fakeDelay = new $.Deferred()

	$.getJSON '/inprogress', (data)->
		unless _.isEmpty(data)
			gameInProgress = new Game(data)
			GameList.add gameInProgress
		gameFetched.resolve()

	# I think the page looks better when delayed a bit.
	_.delay(fakeDelay.resolve, 250)

	$.when(playersFetched, gameFetched, fakeDelay).then ->
		if gameInProgress is null
			PAGES.goto SetupPage
		else
			GameList.trigger 'selectGame', gameInProgress
			if gameInProgress.isComplete()
				# Game has been completed but not marked in the DB...
				PAGES.goto GameOverPage
			else 
				PAGES.goto GamePage
