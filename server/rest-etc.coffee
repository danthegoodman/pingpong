mongoose = require('mongoose')

exports.handle = (app) ->
	Game = mongoose.model 'Game'
	Tournament = mongoose.model 'Tournament'

	app.get '/inprogress', (req, res, next) ->
		Game.findOne {inProgress: true}, (err, game) ->
			return next(err) if err
			Tournament.findOne {inProgress: true}, (err, tournament) ->
				return next(err) if err
				res.json({game: game, tournament: tournament})

	app.get '/lastgame', (req, res, next) ->
		myMap = -> emit '', @
		myReduce = (key, values) ->
			max = values[0]
			max = v for v in values when v.date > max.date
			return max

		Game.collection.mapReduce(
			myMap.toString()
			myReduce.toString()
			{out: {inline: 1}}
			(err, values, stats)->
				return next(err) if err
				game = values[0]?.value if values.length
				res.json game ? {}
		)