soundManager.url = '/lib/'

initSound = (id, moreOpts)->
	opts = 
		id: id
		url: "/sound/#{id}.mp3"
		autoLoad: true
	soundManager.createSound _.extend(opts, moreOpts)

soundManager.onready ->
	new GameSoundHandler()
	audifySyncError()

	initSound 'score'
	initSound 'undo', volume: 30
	initSound 'badServe'
	initSound 'error'

SCORE_SOURCE = 
	addPoint: 'score'
	badServe: 'badServe'
	undo    : 'undo'

class GameSoundHandler
	constructor: ->
		@game = null
		GameList.on 'selectGame', @setGame
		GameList.on 'score', @onScoreChange

	setGame: (game) =>
		@game = game

	onScoreChange: (delta, source) =>
		return unless @game
		s = SCORE_SOURCE[source]
		return unless s
		
		if s is 'badServe' and @game.isComplete()
			s = 'error'
		soundManager.play s

audifySyncError = ->
	_serr = window.syncError
	notYetPlayed = true
	
	window.syncError = ->
		if notYetPlayed
			soundManager.play 'error'
			notYetPlayed = false
		_serr(arguments...)