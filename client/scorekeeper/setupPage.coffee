class SetupPage extends Backbone.View
	events:
		'click #begin': 'onBeginClick'

	initialize: ->
		@players = $('#players')
		@begin = $('#begin')
		@begin.fadeOut(0)

		PlayerList.on 'reset', @onReset
		$BUS.on 'canBegin', @onCanBeginChange
		@teamManager = new TeamSlotManager()

	#called from the page manager
	render: ->
		@begin.fadeOut(0)
		PlayerList.each (p) =>
			p.trigger "select:off", p

	onBeginClick: =>
		players = [[],[]]
		for s in @teamManager.slots
			continue unless s.player?
			players[s.team].push(s.player.id)
		
		return unless players[0].length
		return unless players[1].length

		# Shuffle the ordering
		r2 = -> Math.floor(Math.random() * 2)
		players.reverse() if r2() is 1
		players[0].reverse() if r2() is 1
		players[1].reverse() if r2() is 1

		newGame = new Game(team0: players[0], team1: players[1])
		$.when( GameList.create(newGame) ).then (game)->
			GameList.trigger 'selectGame', game
			PAGES.goto GamePage

	onCanBeginChange: (e, value) =>
		targetOpacity = if value then "1" else "0"
		return if @begin.css('opacity') is targetOpacity
		@begin.fadeTo(200, targetOpacity)

	onReset: =>
		@players.empty()
		PlayerList.each (m) =>
			@players.append( new PlayerButton(model:m).el )


class PlayerButton extends Backbone.View
	tagName: "div"

	events:
		'click': 'onClick'

	initialize: ->
		@selected = false
		@model.on 'selected', @onSelectedChange
		@render()

	render: =>
		@$el.hide() unless @model.get 'active'
		@$el.html( @model.get 'name' )

	onSelectedChange: (side) =>
		@selected = side?
		@$el.removeClass()
		@$el.addClass(side) if side?

	onClick: =>
		type = if @selected then 'off' else 'on'
		PlayerList.trigger "select:#{type}", @model

class TeamSlotManager
	constructor: ->
		@current = 0;
		@slots = [
			new TeamSlot(0, 0)
			new TeamSlot(1, 0)
			new TeamSlot(0, 1)
			new TeamSlot(1, 1)
		]

		PlayerList.on 'select:on', @onPlayerSelect
		PlayerList.on 'select:off', @onPlayerDeselect
		$('.team').on 'click', @redraw
		@redraw()

	redraw: =>
		count = 0:0, 1:0

		@current = null
		for i in [0...@slots.length]
			s = @slots[i]
			@current = i unless @current? or s.player?
			s.redraw(i == @current)
			count[s.team] += 1 if s.player?

		$BUS.trigger 'canBegin', (count[0] and count[1])
 
	onPlayerSelect: (pl) =>
		return unless @current?
		@slots[@current].player = pl
		side = if @slots[@current].team is 1 then 'right' else 'left'
		pl.trigger 'selected', side
		@redraw()

	onPlayerDeselect: (pl) =>
		for s in @slots
			if s.player is pl
				s.player = null
				break

		@redraw()
		pl.trigger 'selected', null

class TeamSlot extends Backbone.View
	events: 
		'click': 'onClick'

	initialize: (@team, @n) ->
		@setElement $("#slot#{team}#{n}")
		@player = null

	redraw: (ready) =>
		e = @$el
		e.toggleClass 'hasPlayer', @player?
		if @player?
			e.text(@player.get 'name')
		else if ready
			e.text('Select a player')
		else
			e.empty()

	onClick: =>
		return unless @player?
		PlayerList.trigger 'select:off', @player