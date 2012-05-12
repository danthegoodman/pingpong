mongoose = require 'mongoose'

###
Uncomment portions of this file to run queries against the DB.

Run this file like so:
	coffee <file>
###

###
#------ Startup ------#
require('./server/schema').connect()

Player = mongoose.model 'Player'
Point = mongoose.model 'Point'
Game = mongoose.model 'Game'
# ###


#------ General Queries ------#
# Player.find (e, list) ->
# 	console.err e if e
#	return unless list
# 	for p in list
# 		console.log "#{p.name}: Active? #{p.active}"

# Game.find()
# 	.select('_id', 'inProgress', 'team1', 'team0', 'parent', 'finish', 'date')
# 	.populate('team0', ['name'])
# 	.populate('team1', ['name'])
# 	.run (e, data) ->
# 		console.err(e) if e
# 		console.log(data) if data

# Game.count (e, c) ->
# 	console.err e if e
# 	console.log "Games: #{c}"

# Point.count (e, c) ->
# 	console.err e if e
# 	console.log "Points: #{c}"


###
#------ Data Reset ------#
Game.remove (err)->
	console.log err if err
	console.log "Deleted all games"

Point.remove (err)->
	console.log err if err
	console.log "Deleted all points"

Player.remove (err)->
	console.log err if err
	console.log "Deleted all players"

	PLAYER_LIST = ['James', 'Elizabeth', 'Corey', 
		'John', 'Hannah', 'Sarah', 'Tod', 'Bill']
	c = PLAYER_LIST.length
	for n in PLAYER_LIST
		Player.create {name:n}, (err, result)->
			console err if err
			console.log "created player #{result.name}" unless err
			c -= 1
			mongoose.disconnect() if c is 0
# ###