class AllGamesReport extends Backbone.View

	initialize: ->
		@loaded = false
		@players = @$el.find('.players')

		PlayerList.on 'reset', @onReset

	render: ->
		return if @loaded
		$.getJSON '/reports/games', @onProcessGames
		$.getJSON '/reports/points', @onProcessPoints
		@loaded = true

	onReset: =>
		PlayerList.each (m) =>
			@players.append new AllGamesReport.PlayerItem(model: m).el

	onProcessGames: (data) =>
		for p in data
			PlayerList.get(p._id).trigger 'getGame', p.value

	onProcessPoints: (data) ->
		for p in data
			PlayerList.get(p._id).trigger 'getPoint', p.value

class AllGamesReport.PlayerItem extends Backbone.View
	tagName: 'tr'
	className: 'player'

	initialize: ->
		@$el.append $ """
			<td class='name'/>
			<td class='games'/>
			<td class='win'/>
			<td class='lose'/>
			<td class='scoreWon'/>
			<td class='scoreLost'/>
			<td class='scoreRatio'/>
			<td class='serveGood'/>
			<td class='serveBad'/>
			<td class='serveRatio'/>"""

		@$el.find('.name').text @model.get 'name'
		@model.on 'getGame', @onGameResponse
		@model.on 'getPoint', @onPointResponse

	onGameResponse: (d)=>
		@$el.find('.games').text(d.win + d.lose)
		@$el.find('.win').text d.win
		@$el.find('.lose').text d.lose

	onPointResponse: (d)=>
		@$el.find('.scoreWon').text d.scoreWon
		@$el.find('.scoreLost').text d.scoreLost

		s = d.scoreWon / d.scoreLost
		s = Math.round(s*100)/100
		@$el.find('.scoreRatio').text s

		@$el.find('.serveGood').text d.goodServe
		@$el.find('.serveBad').text d.badServe

		r = d.goodServe / (d.goodServe+ d.badServe)
		r = Math.round(r*1000)/10
		@$el.find('.serveRatio').text "#{r}%"
