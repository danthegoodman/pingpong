path = require 'path'
fs = require 'fs'
_ = require 'underscore'
util = require 'util'

exports.handle = (app)->
	app.set 'views', global.path('views')
	app.set 'view engine', 'jade'
	app.set 'view options', layout: false

	views = 
		'/'           : 'reports.jade'
		'/index'      : 'index.jade'
		'/config'     : 'config.jade'
		'/reports'    : 'reports.jade'
		'/scorekeeper': 'scorekeeper.jade'

	logs =
		'/log/errors' : 'log/server.err.log'
		'/log/out'    : 'log/server.out.log'
		'/log/db'     : 'log/db.log'

	_.each views, (view, url)->
		app.get url, (req, res) -> res.render view

	_.each logs, (file, url) ->
		app.get url, (req, res) ->
			res.sendfile global.path(file)

	app.get '/fatal', (req, res) ->
		util.log "OHKO! Fatality. Restarting Server."
		process.exit(1)