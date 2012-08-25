# Hold down for timeframe
UNDO_TIMEFRAME = 400

#Press and release and press again within timeframe
BAD_SERVE_TIMEFRAME = 500

if UNDO_TIMEFRAME >= (BAD_SERVE_TIMEFRAME-20)
	throw "BAD_SERVE_TIMEFRAME must be at least " +
		  "20ms larger than UNDO_TIMEFRAME"

class KeyboardHandler
	constructor: ->
		@game = null
		@undoTid = null #timer id
		@scoreTid = null #timer id
		@lastChar = null #detection for bad serve
		@currChar = null #prevents repetition

		@activeChar = null #char event fired on
		@teamMap = {}

		for k, team of getShortcuts()
			@teamMap[k] = team.split('')
		$(document).on 'keydown', @onKeyDown
		$(document).on 'keyup', @onKeyUp

		GameList.on 'selectGame', @setGame

	doBadServe: (team, pos)->
		return unless @game
		return if @game.isComplete()
		@game.recordBadServe()

	doUndoScore: (team, pos)->
		return unless @game
		if @game.isNewGame()
			@game.switchServingSide()
		else
			@game.undoLastPoint()

	doScore: (team, pos)->
		return unless @game
		return if @game.isComplete()
		p = if pos is "1" then 1 else 0
		@game.addPointBy @game.playerBasedOnScore(team, p)

	setGame: (game)=>
		@game = game
		@clearAllTimeouts()
		@lastChar = null
		@currChar = null

	clearAllTimeouts: () =>
		@clearUndoTimeout()
		if @scoreTid?
			clearTimeout @scoreTid
			@scoreTid = null
		@lastChar = null

	clearUndoTimeout: () =>
		if @undoTid?
			clearTimeout @undoTid
			@undoTid = null

	onKeyDown: (e)=>
		return unless @game
		ch = String.fromCharCode e.which
		return unless ch of @teamMap
		return if @currChar
		@currChar = ch
		@activeChar = ch
		if @lastChar
			return unless @lastChar is ch
			return unless @scoreTid? #score not recorded
			@doBadServe @teamMap[@activeChar]...
			@clearAllTimeouts()
		else
			@undoTid = setTimeout @onUndoTimeout, UNDO_TIMEFRAME
			@scoreTid = setTimeout @onScoreTimeout, BAD_SERVE_TIMEFRAME

	onKeyUp: (e)=>
		return unless @game
		ch = String.fromCharCode e.which
		return unless @currChar is ch

		if @undoTid? #undo did not fire
			@clearUndoTimeout()
			@lastChar = @currChar
		@currChar = null

	onUndoTimeout: =>
		@doUndoScore @teamMap[@activeChar]...
		@clearAllTimeouts()

	onScoreTimeout: =>
		@doScore @teamMap[@activeChar]...
		@clearAllTimeouts()
