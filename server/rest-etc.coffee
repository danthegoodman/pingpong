mongoose = require('mongoose')

exports.handle = (app) ->
	Player = mongoose.model 'Player'
	Game = mongoose.model 'Game'

	sendResult = (res) ->
		return (err, result)->
			res.send(if err then 500 else result)

	app.get '/inprogress', (req, res, next) ->
		Game.findOne {inProgress: true}, (err, game) ->
			return next(err) if err
			res.json(game ? {})

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