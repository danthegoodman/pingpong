$ ->
	new PlayersContainer(el: $ '#players')

	playersFetched = PlayerList.fetch()

	$.when(playersFetched).then ->
		$.getJSON '/reports/games', processGames
		$.getJSON '/reports/points', processPoints

processGames = (data) ->
	for p in data
		PlayerList.get(p._id).trigger 'getGame', p.value

processPoints = (data) ->
	for p in data
		PlayerList.get(p._id).trigger 'getPoint', p.value

class PlayersContainer extends Backbone.View
	initialize: ->
		PlayerList.on 'reset', @onReset

	onReset: =>
		PlayerList.each (m) =>
			@$el.append new PlayerItem(model: m).el

class PlayerItem extends Backbone.View
	tagName: 'tr'
	className: 'player'

	initialize: ->
		@$el.append $ """
			<td class='name'>#{@model.get 'name'}</span>
			<td class='games'/>
			<td class='win'/>
			<td class='lose'/>
			<td class='scoreWon'/>
			<td class='scoreLost'/>
			<td class='scoreRatio'/>
			<td class='serveGood'/>
			<td class='serveBad'/>
			<td class='serveRatio'/>"""

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
