class TournamentReport extends Backbone.View

	initialize: ->
		@loaded = false
		new Details(el: @$el.find('.details table'))
		new Standings(el: @$el.find('.standings table'))

	class Standings extends Backbone.View
		initialize: ->
			TournamentList.on 'select', @onTournamentSelect

		onTournamentSelect: (t)=>
			standings = TournamentReport.getStandings(t)
			first = true
			for s in standings
				@$el.append new Item(model:s).el
				if first
					PlayerList.trigger 'tournamentSelect', s.player
				first = false;


		class Item extends Backbone.View
			tagName: 'tr'
			initialize: ->
				PlayerList.on 'tournamentSelect', @onPlayerSelect
				@render()
				@$el.on 'click', @onClick

			onClick: =>
				PlayerList.trigger 'tournamentSelect', @model.player

			render: ->
				w = @model.wins
				if w is -1
					win = ""
				else if w is 1
					win = "1 win"
				else
					win = "#{w} wins"

				@$el.append $ """
					<td>#{@model.player.get('name')}</td>"
					<td>#{win}</td>
					"""

			onPlayerSelect: (player)=>
				@$el.toggleClass 'selected', @model.player.id is player.id

	class Details extends Backbone.View
		initialize: ->
			@tournament = null
			TournamentList.on 'select', (t)=> @tournament = t
			PlayerList.on 'tournamentSelect', @onPlayerSelect

		onPlayerSelect: (p)=>
			@$el.empty()
			TournamentReport.getDetails @tournament, p, @renderDetails

		renderDetails: (details)=>
			for d in details
				games = ""
				for g in d.games
					games += """<div class="game #{if g.winner then 'win' else 'lose'}">
						#{g.myScore} - #{g.theirScore}
						</div>"""

				@$el.append """<tr>
					<td>vs #{d.player.get('name')}</td>
					<td>#{games}</td>
					</tr>"""

TournamentReport.getStandings = do ->
	getStandings = (t)->
		players = t.get('players')
		len = players.length
		data = t.get('table')
		return unless data?

		points = []
		for a in [0...len]
			r = []
			for b in [0...len] when a isnt b
				r.push playerWinsMatch(data, a, b)
			points[a] = countWins(r)

		return formatStandings(players, points)

	playerWinsMatch = (data, a, b)->
		win = data[a][b].length
		lose = data[b][a].length
		return true if win is 2
		return false if lose is 2
		return null

	countWins = (list)->
		allNull = true
		count = 0
		for x in list
			allNull = false if x?
			count++ if x is true

		return -1 if allNull
		return count

	formatStandings = (players, points) ->
		return _.chain( _.zip(players, points))
			.map((x)->{player: PlayerList.get(x[0]), wins: x[1]})
			.groupBy('wins')
			.sortBy( (k,winCount)->+winCount )
			.reverse()
			.tap((o)->_.each o, (x)->x.sort())
			.flatten()
			.value()

	return getStandings

TournamentReport.getDetails = do ->
	getDetails = (t, player, callback)->
		players = _.clone(t.get 'players')
		playerNdx = _.indexOf players, player.id
		fetchAllGames t, playerNdx, ->
			result = []
			for ndx in [0...players.length] when ndx isnt playerNdx
				p = players[ndx]
				result.push {
					player:PlayerList.get(p)
					games: collectGames(t, player.id, playerNdx, ndx)
				}

			callback _.sortBy result, (x)->player.get('name')

	collectGames = (t, pid, myNdx, theirNdx)->
		data = t.get('table')
		return [] unless data
		return _.chain(data[myNdx][theirNdx].concat data[theirNdx][myNdx])
			.map((g)-> GameList.get(g))
			.sortBy((g)-> new Date(g.get('date')))
			.map((g)-> getGameObject(g, pid))
			.value()

	getGameObject = (g, pid)->
		team = teamForPlayer(g, pid)
		a = g.score(team)
		b = g.score(Math.abs(team-1))
		return {
			myScore: a
			theirScore: b
			winner: a > b
		}

	teamForPlayer = (game, pid)->
		if _.contains game.get('team0'), pid
			return 0
		else
			return 1

	fetchAllGames = (t, ndx, callback)->
		len = t.get('players').length
		data = t.get('table')
		return [] unless data
		games = []
		for i in [0...len]
			for g in data[ndx][i]
				games.push g
			for g in data[i][ndx]
				games.push g

		dlist = []
		for g in games
			d = $.Deferred()
			dlist.push d
			GameList.getOrFetch g, d.resolve

		$.when(dlist...).then callback

	return getDetails

