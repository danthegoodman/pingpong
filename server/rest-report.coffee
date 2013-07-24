mongoose = require('mongoose')

exports.handle = (app) ->
	Player = mongoose.model 'Player'
	Point = mongoose.model 'Point'
	Game = mongoose.model 'Game'

	app.get '/reports/count', (req, res, next) ->
		result =
			games: null
			points: null
		error = null

		checkDone = () ->
			return unless result.games? and result.points?
			return next(error) if error
			res.json(result)

		Game.count (err, n)->
			error = err unless error
			result.games = n
			checkDone()

		Point.count (err, n)->
			error = err unless error
			result.points = n
			checkDone()


	app.get '/reports/games', (req, res, next) ->
		m = ->
			if @score0.length > @score1.length
				out = win:1, lose: 0
			else
				out = win:0, lose: 1

			for t in @team0
				emit t, out

			out2 = win: out.lose, lose: out.win
			for t in @team1
				emit t, out2

		r = (key, values) ->
			res = win: 0, lose: 0
			for v in values
				res.win += v.win
				res.lose += v.lose
			return res

		p = out: {inline:1}

		Game.collection.mapReduce m,r,p, (e, v, s) ->
			return next(e) if e
			res.json v ? {}


	app.get '/reports/points', (req, res, next) ->
		m = ->
			f = (a,b,c,d) -> {scoreWon: a, scoreLost:b, goodServe:c, badServe: d}

			if @badServe
				emit @server, f(0,0,0,1)
			else
				emit @server, f(0,0,1,0)

			return unless @scoringPlayer

			emit @scoringPlayer, f(1,0,0,0)

			if @receiverPartner
				order = [@server, @receiverPartner, @serverPartner, @receiver]
			else
				order = [@server, @receiver]
			sp = @scoringPlayer.toString()

			for p in [0...order.length]
				if sp is order[p].toString()
					emit order[(p+1)%order.length], f(0,1,0,0)
					return;

		r = (key, values) ->
			o = {scoreWon: 0, scoreLost:0, goodServe:0, badServe: 0}
			for v in values
				o.scoreWon += v.scoreWon
				o.scoreLost += v.scoreLost
				o.goodServe += v.goodServe
				o.badServe += v.badServe
			return o

		p = out: {inline:1}

		Point.collection.mapReduce m,r,p, (e, v, s) ->
			return next(e) if e
			res.json v ? {}


	app.post '/reports/playersGames', (req, res, next) ->
		players = req.body.players
		return next("Missing required attribute: 'players'") unless players?
		return next("Players must have a length of 4") unless players.length is 4
		players = players.sort();

		m = ->
			return if @team0.length is 1
			w = [@team0[0], @team1[0], @team0[1], @team1[1]]
			x = w.slice().sort()

			l = AAAA
			return unless l[0] == x[0]+""
			return unless l[1] == x[1]+""
			return unless l[2] == x[2]+""
			return unless l[3] == x[3]+""

			z = if @score0.length > @score1.length then {win:1,lose:0} else {win:0,lose:1}
			emit w+"", z

		r = (key, values) ->
			res = {win:0, lose:0}
			for v in values
				res.win += v.win
				res.lose += v.lose
			return res

		mapReduceCfg = out: {inline:1}

		m = m.toString().replace(/AAAA/g, JSON.stringify(players));
		Game.collection.mapReduce m,r,mapReduceCfg, (e, v, s) ->
			return next(e) if e
			res.json v ? {}
