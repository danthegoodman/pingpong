Game.prototype = _.extend Game.prototype, 
	_unsafePlayer: (teamN, p) ->
		if @get("team#{teamN}").length is 1
			return PlayerList.get(@get("team#{teamN}")[p])

		points = @score()
		if(points < 40)
			points += 5 if teamN is 0
			if (points%20) >= 10
				p = if p is 1 then 0 else 1
		else
			points += 1 if teamN is 0
			if (points%4) >= 2
				p = if p is 1 then 0 else 1

		return PlayerList.get(@get("team#{teamN}")[p])

	playerBasedOnScore: (teamN, p) ->
		if @get("team#{teamN}").length is 1 and p is 1
			p = 0
		return @_unsafePlayer(teamN, p)

	isComplete: () ->
		s0 = @score(0)
		s1 = @score(1)
		return (s0 >= 21 or s1 >= 21) and (Math.abs(s0 - s1) >= 2)

	isNewGame: () ->
		return @get('scoreHistory').length is 0

	winningTeam: () ->
		winTeam = if @score(0) > @score(1) then 0 else 1
		p = []
		for pid in @get("team#{winTeam}")
			p.push PlayerList.get(pid).get 'name'
		return p

	score: (teamN=null) ->
		if teamN?
			@get("score#{teamN}").length
		else
			@get("score0").length + @get("score1").length

	isServing: (teamN) ->
		s = @score()
		if(s < 40)
			if teamN is 0
				return (s%10) < 5 
			else
				return (s%10) >= 5 
		else
			return (s%2) is teamN

	addPointBy: (player) ->
		point = @_createPoint()
		point.set 'scoringPlayer', player.id

		$.when( point.save() ).then =>
			found = _.any @get('team0'), (it) -> it == player.id
			scoringTeam = if found then 0 else 1

			@get("score#{scoringTeam}").push point.id
			@get('scoreHistory').push scoringTeam
			@save()
			GameList.trigger 'score', 1, 'addPoint'

	recordBadServe: ->
		point = @_createPoint()
		point.set 'badServe', true

		$.when( point.save() ).then =>
			receivingTeam = if @isServing(0) then 1 else 0
			@get("score#{receivingTeam}").push point.id
			@get('scoreHistory').push receivingTeam
			@save()
			GameList.trigger 'score', 1, 'badServe'


	undoLastPoint: ->
		hist = @get('scoreHistory')
		return if hist.length is 0

		lastTeam = hist.pop()
		lastPointId = @get("score#{lastTeam}").pop()
		
		new Point(_id: lastPointId).destroy()
		@save()
		GameList.trigger 'score', -1, 'undo'

	switchServingSide: ->
		@set {
			team0: @get 'team1'
			team1: @get 'team0'
		}
		@save()
		GameList.trigger 'teamChange'

	createNewMatch: (afterSaveCallback)->
		t0 = _.clone(@get 'team0')
		t1 = _.clone(@get 'team1')

		r2 = -> Math.floor(Math.random * 2)
		if r2() #Randomize the starting server
			t0.reverse()
			t1.reverse()

		g = new Game
			parent: @id
			team0: t1 #switch sides so the other team starts serving
			team1: t0
		$.when( GameList.create(g) ).then (newGame)->
			afterSaveCallback(newGame)

	_createPoint: ->
		servingTeam = if @isServing(0) then 0 else 1
		receivingTeam = if servingTeam is 0 then 1 else 0

		return new Point
			game           : @id
			server         : @_unsafePlayer(servingTeam,0)?.id
			serverPartner  : @_unsafePlayer(servingTeam,1)?.id
			receiver       : @_unsafePlayer(receivingTeam,0)?.id
			receiverPartner: @_unsafePlayer(receivingTeam,1)?.id
