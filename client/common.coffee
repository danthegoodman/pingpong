# Everything on the common page is ment to be shared,
# thus the need for attaching things to the 'window'

console.log """
	Did you know that there are some "hidden" pages? They may not
	interest you, but navigate to '/index' to see the complete list.
	"""

#-------------- Event Bus ---------------#
# Since jQuery and Backbone use different namespace 
# semantics, lets use "event:namespace"
bus = $ {}
convertNS = (str) -> str.replace new RegExp(':', 'g'), '.'

window.$BUS =
	on: (events, handler) -> bus.on convertNS(events), handler
	off: (events, handler) -> bus.off convertNS(events), handler
	trigger: (event, args...) -> bus.trigger convertNS(event), args

#-------------- Models ---------------#
class window.Player extends Backbone.Model
	idAttribute: "_id"
	urlRoot: "/player"
	defaults:
		name: "New Player"
		active: true

class window.Game extends Backbone.Model
	# Serving always starts with team 0
	idAttribute: "_id"
	urlRoot: "/game"
	defaults:
		date: new Date()
		parent: null #gameId
		team0: [] # list of player IDs
		team1: [] 
		score0: [] # list of point IDs
		score1: [] 
		scoreHistory: [] # 0 or 1
		inProgress: true 
		finish: null # date/time of completion

class window.Point extends Backbone.Model
	idAttribute: "_id"
	urlRoot: "/point"
	defaults:
		game: null #gameId
		server: null #playerId
		receiver: null
		serverPartner: null
		receiverPartner: null
		scoringPlayer: null
		badServe: false

#-------------- Collections ---------------#
class PlayerListCollection extends Backbone.Collection
	model: Player
	url: "/player"
	comparator: (player) -> 
		player.get 'name'	
class GameListCollection extends Backbone.Collection
	model: Game
	url: "/game"
	comparator: (game) -> 
		new Date(game.get('date')).getTime()

window.PlayerList = new PlayerListCollection()
window.GameList = new GameListCollection()

#-------------- Shortcuts ---------------#
window.getShortcuts = ->
	s = localStorage.shortcuts
	return {Q:'01', P:'10', Z:'00', M:'11'} unless s?

	return JSON.parse(s)

#-------------- Async Handler ---------------#
_sync = Backbone.sync

window.syncSuccess = ->

window.syncError = (e, type, msg)->
	console.error """
		Error Communicating with Server.
		Status: #{e.status} (#{e.statusText})
		Messsage: #{e.responseText}
	"""
	$("#asyncError").fadeIn(200)

Backbone.sync = (method, model, options) ->
	s = $.Callbacks()
	s.add -> syncSuccess(arguments...)
	s.add options.success if options?.success

	e = $.Callbacks()
	e.add -> syncError(arguments...)
	e.add options.fail if options?.fail

	_sync method, model, 
		success: s.fire
		error: e.fire

#-------------- Page Manager ---------------#
class window.PageManager
	constructor: ->
		@pages = {}
		@current = null
		@field = null

	linkPagesWithDataField: (field)->
		@field = field

	add: (page) ->
		@pages[page.constructor.name] = page
		page.$el.fadeOut(0)

		if @field
			element = $("[data-#{@field}=#{page.el.id}]")
			element.data '_page', page.constructor

	gotoUsingLink: (link) ->
		@goto link.data('_page')

	goto: (page) ->
		prev = @current
		next = @pages[page.name]
		@current = next

		showNext = ()->
			next?.render()
			next.$el.fadeIn(500) if next?

		if prev?
			prev.$el.fadeOut(500, showNext)
		else
			showNext()

#-------------- On Window Load ---------------#
$ ->
	a = $("#asyncError")
	a.css('display', '')
	a.fadeOut(0)
