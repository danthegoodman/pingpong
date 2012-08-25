class GamePage extends Backbone.View
	initialize: ->
		new KeyboardHandler()

		new NameCell('serve', 0)
		new NameCell('standby', 0)
		new NameCell('serve', 1)
		new NameCell('standby', 1)

		new ScoreCell(0)
		new ScoreCell(1)

		$("#undoScore").on 'click', @onUndoScoreClick
		$("#badServe").on 'click', @onBadServeClick
		$("#cancelGame").on 'click', @onCancelGameClick

		GameList.on 'selectGame', @setGame
		GameList.on 'score', @checkScore

	setGame: (game) =>
		@game = game
		@render()

	checkScore: =>
		return unless @game
		if @game.isComplete()
			PAGES.goto GameOverPage

		@render()

	render: =>
		return unless @game
		@$el.toggleClass 'leftServing', @game.isServing(0)
		@$el.toggleClass 'rightServing', @game.isServing(1)

	onUndoScoreClick: =>
		@game.undoLastPoint()

	onBadServeClick: =>
		@game.recordBadServe()

	onCancelGameClick: =>
		b = window.confirm("Are you sure you want to cancel this game?")
		return unless b

		$.when(@game.destroy()).then ->
			GameList.trigger 'selectGame', null
			PAGES.goto SetupPage

class NameCell
	constructor: (@type, @team) ->
		@pos = if @type is 'serve' then 0 else 1
		@el = $("##{type}#{team}")

		GameList.on 'selectGame', @setGame
		GameList.on 'score', @render
		GameList.on 'teamChange', @onTeamChange

		@el.on 'click', @onClick

	onClick: =>
		return unless @player and @game
		@game.addPointBy @player

	setGame: (game) =>
		@game = game
		return unless @game

		t = game.get("team#{@team}")
		shouldHide = t.length is 1 and @pos is 1
		@el.parent().toggle(!shouldHide)
		@render()

	onTeamChange: =>
		@render()

	render: =>
		return unless @game
		@player = @game.playerBasedOnScore(@team, @pos)
		@el.text @player?.get 'name'

class ScoreCell
	constructor: (@team) ->
		@el = $("#score#{@team}")
		GameList.on 'selectGame', @setGame
		GameList.on 'score', @render

	setGame: (game) =>
		@game = game
		@render()

	render: =>
		return unless @game
		@el.text @game.score(@team)
