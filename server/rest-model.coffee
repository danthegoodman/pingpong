mongoose = require('mongoose')

exports.handle = (app) ->
	Player = mongoose.model 'Player'
	Game = mongoose.model 'Game'
	Point = mongoose.model 'Point'
	Tournament = mongoose.model 'Tournament'

	genericRest app, Player, 'player'
	genericRest app, Point, 'point'
	genericRest app, Game, 'game'
	genericRest app, Tournament, 'tournament'

genericRest = (app, Model, url, extras={}) ->
	app.get "/#{url}/:id", (req, res, next) ->
		Model.findById req.params.id, (err, result) ->
			return next(err) if err
			res.json result

	app.get "/#{url}", (req, res, next) ->
		Model.find (err, result) ->
			return next(err) if err
			res.json result

	app.post "/#{url}", (req, res, next) ->
		data = Model.filter(req.body)
		model = new Model(data)
		model.save (err) ->
			return next(err) if err
			res.json model

	app.put "/#{url}/:id", (req, res, next) ->
		data = Model.filter(req.body)
		Model.findById req.params.id, (err, model)->
			return next(err) if err
			model.copyFrom data
			model.save (err) ->
				return next(err) if err
				res.json model

	app.del "/#{url}/:id", (req, res, next) ->
		Model.findById req.params.id, (err, model)->
			return next(err) if err
			model.remove (err) ->
				return next(err) if err
				res.json {}
