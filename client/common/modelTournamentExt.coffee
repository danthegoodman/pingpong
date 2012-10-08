$ ->
	Tournament.prototype = _.extend Tournament.prototype,
		belongsWith: (game) ->
			return false unless game?
			return game.get('tournament') is @id

		hasMatch: (players) ->
			teamSize = Math.max(players[0].length, players[1].length)
			isSingles = (teamSize is 1)
			return false unless isSingles is @get('isSingles')

			pl = _.flatten(players)
			result = _.intersection @get('players'), pl
			return pl.length is result.length

		isMatchComplete: (players)->
			[a,b] = @_playersIndex(players)
			data = @get('table')
			return null unless data
			return data[a]?[b]?.length is 2 or data[b]?[a]?.length is 2

		getScore: (players)->
			[a,b] = @_playersIndex(players)
			data = @get('table')
			return [] unless data
			return [data[a]?[b]?.length, data[b]?[a]?.length]

		addGame: (game)->
			[a,b] = @_playersIndex(game.getPlayers())
			data = @get('table')
			return unless data
			[a,b] = [b,a] if game.score(1) > game.score(0)
			data[a]?[b]?.push game.id

		_playersIndex: (players)->
			return [
				_.indexOf @get('players'), players[0][0]
				_.indexOf @get('players'), players[1][0]
			]
