$ ->
	new PlayersContainer(el: $ '#players')

	playersFetched = PlayerList.fetch()

	type = $("#type")
	type.append "<option value='ROUND_ROBIN'>Round Robin</option>"

	title = $("#title")

	$("#create").on 'click', ->
		return alert "A title is required" unless title.val()?.length

		players = []
		PlayerList.each (p) ->
			players.push p.id if p.selected
		t = new Tournament(
			players: players
			type: type.val()
			title: title.val()
			inProgress: true
		)
		constructTable(t)
		$.when( t.save() ).then ->
			alert "The tournament has been created!"
			window.location.assign "/index"

constructTable = (t)->
	len = t.get('players').length
	data = []
	for a in [0...len]
		d = data[a] = []
		for b in [0...len]
			d[b] = []
	t.set('table', data)

class PlayersContainer extends Backbone.View
	initialize: ->
		PlayerList.on 'reset', @onReset

	onReset: =>
		PlayerList.each (m) =>
			@$el.append new PlayerItem(model: m).el

class PlayerItem extends Backbone.View
	tagName: 'div'
	className: 'player'

	initialize: ->
		@model.selected = false
		@$el.text @model.get 'name'
		@$el.on 'click', @onClick

	onClick: =>
		sel = !@model.selected
		@model.selected = sel
		@$el.toggleClass('selected', sel)




