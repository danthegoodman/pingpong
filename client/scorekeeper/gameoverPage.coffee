class GameOverPage extends Backbone.View
	initialize: ->
		$("#gameOverUndo").on 'click', @onUndoScoreClick
		$("#returnToSetup").on 'click', @onReturnToSetupClick
		$("#playAnotherMatch").on 'click', @onPlayAnotherMatchClick
		GameList.on 'selectGame' , @setGame
		GameList.on 'score', @onScoreChange

	setGame: (game) =>
		@game = game

	exitPage: (page, newGame=null) =>
		@game.set 'inProgress', false
		@game.set 'finish', new Date()
		@game.save()
		GameList.trigger 'selectGame', newGame
		PAGES.goto page

	onScoreChange: (delta, type)=>
		return unless PAGES.is GameOverPage
		return unless delta <= 0
		PAGES.goto GamePage

	onReturnToSetupClick: =>
		@exitPage SetupPage

	onPlayAnotherMatchClick: =>
		@game.createNewMatch (newGame) =>
			@exitPage GamePage, newGame

	onUndoScoreClick: =>
		@game.undoLastPoint()
		PAGES.goto GamePage

	# Called from the page manager
	render: =>
		@return if @game is null
		t = @game.winningTeam()

		if t.length is 1
			title = '... and the winner is:'
		else
			title = '... and the winners are:'

		$("#winTitle").text title
		$("#winners").text t.join(' and ')
