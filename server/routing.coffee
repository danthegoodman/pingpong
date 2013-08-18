path = require 'path'
fs = require 'fs'
_ = require 'underscore'
util = require 'util'

exports.handle = (app)->
	resources =
		'/'                : 'client/web/reports.html'
		'/index'           : 'client/web/index.html'
		'/config'          : 'client/web/config.html'
		'/reports'         : 'client/web/reports.html'
		'/scorekeeper'     : 'client/web/scorekeeper.html'
		'/createTournament': 'client/web/createTournament.html'
		'/log/errors'      : 'log/server.err.log'
		'/log/out'         : 'log/server.out.log'

	_.each resources, (file, url) ->
		app.get url, (req, res) ->
			res.sendfile global.path(file)

	app.get '/fatal', (req, res) ->
		util.log "OHKO! Fatality. Restarting Server."
		process.exit(1)
