class GameOverPage extends Backbone.View
	initialize: ->
		$("#gameOverUndo").on 'click', @onUndoScoreClick
		$("#returnToSetup").on 'click', @onReturnToSetupClick
		$("#playAnotherGame").on 'click', @onPlayAnotherGameClick
		GameList.on 'selectGame' , @setGame
		GameList.on 'score', @onScoreChange

	setGame: (game) =>
		@game = game

	exitPage: (page, newGame=null) =>
		@game.set 'inProgress', false
		@game.set 'finish', new Date()

		t = TournamentList.first()
		if t?.belongsWith @game
			t.addGame( @game )
		else
			t = null

		PAGES.fadeOut()
		$.when( t?.save(), @game.save() ).then ->
			GameList.trigger 'selectGame', newGame
			PAGES.goto page

	onScoreChange: (delta, type)=>
		return unless PAGES.is GameOverPage
		return unless delta <= 0
		PAGES.goto GamePage

	onReturnToSetupClick: =>
		@exitPage SetupPage

	onPlayAnotherGameClick: =>
		@game.createNewGame (newGame)=>
			@exitPage GamePage, newGame

	onUndoScoreClick: =>
		@game.undoLastPoint()
		PAGES.goto GamePage

	# Called from the page manager
	render: =>
		@return if @game is null
		$("#playAnotherGame").show()
		t = TournamentList.first()
		if t?.belongsWith @game
			return @renderTournament(t)

		team = @game.winningTeam()
		$("#winners").text team.join(' and ')
		$("#subwinners").empty()

		$title = $("#winTitle")
		if team.length is 1
			$title.text '... and the winner is:'
		else
			$title.text '... and the winners are:'


	renderTournament: (t)->
		pl = @game.getPlayers()
		score = t.getScore(pl)
		winTeam = if @game.score(0) > @game.score(1) then 0 else 1
		loseTeam = Math.abs(winTeam-1)
		winPlayer = PlayerList.get(pl[winTeam][0]).get 'name'
		losePlayer = PlayerList.get(pl[loseTeam][0]).get 'name'

		score[winTeam] += 1

		$title = $("#winTitle")
		$winners = $("#winners")
		$subwinners = $("#subwinners")

		if score[0] is 2 or score[1] is 2
			$title.text '... and the winner of the match is:'
			$winners.text winPlayer
			$subwinners.empty()
			$("#playAnotherGame").hide()
			return

		$title.text '... and the standings are:'

		$winners.text "#{winPlayer} - #{score[winTeam]}"
		$subwinners.text "#{losePlayer} - #{score[loseTeam]}"
