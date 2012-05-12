# PAGES = new PageManager()
# SELECTION = null
# $ ->
# 	tabManager = new TabManager()
# 	SELECTION = new PlayerSelectionManger()

# 	PAGES.linkPagesWithDataField 'page'
# 	PAGES.add new PlayersPage(el: $ '#players')
# 	PAGES.add new TeamsPage(el: $ '#teams')
# 	PAGES.add new GamesPage(el: $ '#games')
# 	PAGES.add new WinLossPage(el: $ '#winLoss')
# 	PAGES.add new PointsPage(el: $ '#points')

# 	playersFetched = PlayerList.fetch()

# 	# I think the page looks better when it fades in after a small delay.
# 	fakeDelay = new $.Deferred()
# 	_.delay(fakeDelay.resolve, 250)

# 	$.when(playersFetched, fakeDelay).then ->
# 		PAGES.goto PlayersPage
# 		tabManager.setSelected $('.player.tab').eq(0)

# class PlayersPage extends Backbone.View
# 	initialize: ->
# 		PlayerList.on 'reset', @onReset

# 	onReset: =>
# 		@$el.empty()
# 		PlayerList.each (m) =>
# 			@$el.append( new PlayersPage.Item(model: m).el )

# class PlayersPage.Item extends Backbone.View
# 	className: 'player'
# 	events:
# 		'click': 'onClick'

# 	initialize: ->
# 		@state = false
# 		@$el.text @model.get 'name'

# 	onClick: =>
# 		@state = !@state
# 		@$el.toggleClass 'selected', @state
# 		@model.trigger "select:#{@state}", @model

# class TeamsPage extends Backbone.View

# class GamesPage extends Backbone.View

# class WinLossPage extends Backbone.View

# class PointsPage extends Backbone.View

# class TabManager
# 	constructor: ->
# 		@selection = null
# 		$('.tab').on 'click', @onTabClick

# 	setSelected: (el) ->
# 		@selection.toggleClass('selected', false) if @selection
# 		@selection = el
# 		@selection.toggleClass('selected', true) if @selection

# 	onTabClick: (e) =>
# 		target = $(e.target)
# 		return if target.is(@selection)
# 		@setSelected target
# 		PAGES.gotoUsingLink target

# class PlayerSelectionManger
# 	constructor: ->
# 		@el = $('#playerSelection')
# 		@selection = []
# 		PlayerList.on 'select:true', @onPlayerSelect
# 		PlayerList.on 'select:false', @onPlayerDeselect

# 	render: ->
# 		names = _.collect @selection, (it) -> it.get 'name'

# 		@el.text( names.join(', ') )

# 	onPlayerSelect: (model)=>
# 		ndx = @selection.indexOf(model)
# 		return unless ndx is -1
# 		@selection.push(model)
# 		@render()

# 	onPlayerDeselect: (model)=>
# 		ndx = @selection.indexOf(model)
# 		return if ndx is -1
# 		@selection.splice(ndx, 1)
# 		@render()



