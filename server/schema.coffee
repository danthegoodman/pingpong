mongoose = require('mongoose')
Schema = mongoose.Schema
Types = mongoose.Schema.Types
_ = require 'underscore'

exports.url = URL = 'mongodb://localhost/pingpong'
exports.connect = ->
	establishConnection()

	# MongoDB does allow for embedded documents, however, it makes
	# searching more difficult. For that reason, all references to
	# other objects are saved as IDs only.
	Player = new Schema
		name: String
		active: { type: Boolean, default: true }

	Point = new Schema
		game: { type: Types.ObjectId, ref: 'Game' }
		server: { type: Types.ObjectId, ref: 'Player' }
		receiver: { type: Types.ObjectId, ref: 'Player' }
		serverPartner: { type: Types.ObjectId, ref: 'Player' }
		receiverPartner: { type: Types.ObjectId, ref: 'Player' }
		badServe: Boolean
		scoringPlayer: { type: Types.ObjectId, ref: 'Player' }
 			# will be null if badServe

	# Serving always starts with team0.
	Game = new Schema
		date: { type: Date, default: Date.now }
		parent: { type: Types.ObjectId, ref: 'Game' }
			# The parent game, if part of a match
		gameCount: { type: Number, default: 0 }
			# The n-th game of a match
		team0: [{ type: Types.ObjectId, ref: 'Player' }]
		team1: [{ type: Types.ObjectId, ref: 'Player' }]
		score0: [{ type: Types.ObjectId, ref: 'Point' }]
		score1: [{ type: Types.ObjectId, ref: 'Point' }]
		scoreHistory: [ Number ]
			# 0 or 1, the team who scored
		inProgress: Boolean
		finish: Date
		tournament: {type: Types.ObjectId, ref: 'Tournament'}
			# The tournament the game belongs to, null if none.

	Tournament = new Schema
		date: { type: Date, default: Date.now }
		players: [{ type: Types.ObjectId, ref: 'Player' }]
		title: String
		type: String
			# "enum": ROUND_ROBIN
		table: Types.Mixed
			# Table of player to player, representing state. Data structure is based upon type.
		inProgress: Boolean
		isSingles: Boolean

	# Round Robin Data:
	#  [ N: [M: [G]] ] where N & M are players index in 'players'
	#       and G is a list of game ids won by N against M

	# When deleting a game, we want to delete all associated points.
	Game.pre 'remove', (next) ->
		g = @
		tid = @tournament
		mongoose.model('Point').remove {game: @_id}, (err) ->
			next(err)


	# Create a filter method on our schema that will
	# filter out values we don't want to save.
	#
	# The filter is a whitelist that by default includes all
	# properties listed above on the schema.
	#
	# Every field name listed here will be excluded from the
	# whitelist.
	createFilter Player
	createFilter Point
	createFilter Game, 'date'
	createFilter Tournament, 'date'

	# Create a method ("copyFrom") on our model that will
	# update all fields using the given object. Fields not
	# listed in the given object will not be modified.
	#
	# Meant to be combined with the filter method above.
	createCopyFromMethod Player
	createCopyFromMethod Point
	createCopyFromMethod Game
	createCopyFromMethod Tournament

	# Tell mongoose which schema belongs to the model.
	mongoose.model 'Game', Game
	mongoose.model 'Player', Player
	mongoose.model 'Point', Point
	mongoose.model 'Tournament', Tournament

createFilter = (Model, badKeys...) ->
	badKeys.push "_id" # We never want to update the id.
	acceptableKeys = _.difference( _.keys(Model.paths), badKeys)
	Model.statics.filter = (obj) ->
		return _.pick obj, acceptableKeys

createCopyFromMethod = (Model) ->
	Model.methods.copyFrom = (obj) -> return _.extend @, obj

establishConnection = ()->
	hadError = false;
	timeout = 2;

	doConnect = ->
		testConnection = mongoose.createConnection URL

		testConnection.on 'error', ->
			console.error "Connection error with db. Will try again in #{timeout} seconds."
			hadError = true
			testConnection.close()
			setTimeout doConnect, timeout*1000
			timeout *= 2 unless timeout >= 60

		testConnection.on 'open', ->
			console.error "Connection established at #{new Date().toLocaleString()}" if hadError
			mongoose.connect URL

	doConnect()
