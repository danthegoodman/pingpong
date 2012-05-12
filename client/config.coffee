$ ->
	new PlayersManager()

	sc = getShortcuts()
	new ShortcutField(0, 0, sc)
	new ShortcutField(0, 1, sc)
	new ShortcutField(1, 0, sc)
	new ShortcutField(1, 1, sc)

	PlayerList.fetch()

class PlayersManager
	constructor: ->
		@players = $('#players')
		@name = $('#name')
		@active = $('#active')
		new PlayerFields()

		@players.change @onSelectionChange
		PlayerList.on 'reset', @onReset
		PlayerList.on 'add', @onAdd

	onSelectionChange: =>
		op = @players.find(':selected').data('view')
		PlayerList.trigger 'select', op.model

	onAdd: (newPlayer)=>
		po = new PlayerOption(model: newPlayer)
		@players.append po.$el
		PlayerList.trigger('select', newPlayer)
		po.$el.attr 'selected', 'selected'

	onReset: =>
		@players.empty()
		first = true;
		PlayerList.each (m) =>
			@players.append( new PlayerOption(model: m).$el )
			PlayerList.trigger('select', m) if first
			first = false

class PlayerOption extends Backbone.View
	tagName: "option"

	initialize: ->
		@$el.data 'view', @
		@model.on 'change', @onModelChange
		@render()

	render: =>
		@$el.text @model.get 'name'

	onModelChange: =>
		@model.save()
		@render()

class PlayerFields
	constructor: ->
		@name = $ '#name'
		@active = $ '#active'


		$("#addNewPlayer").click @onAddNewPlayerClick
		@name.change @onNameChange
		@active.click @onActiveClick
		PlayerList.on 'select', @onPlayerSelect

	render: =>
		@name.val(@model.get 'name')
		a = @model.get 'active'
		@active.text(if a then "Yes" else "No")

	onPlayerSelect: (m)=>
		@model = m
		@render()

	onAddNewPlayerClick: =>
		PlayerList.add(new Player())

	onNameChange: =>
		@model.set 'name', @name.val()
		@render()

	onActiveClick: =>
		a = @model.get 'active'
		@model.set 'active', !a
		@render()

SHORTCUTS = {}
class ShortcutField
	constructor: (team, n, sc)->
		@name = "#{team}#{n}"
		@el = $('#sc'+@name)

		for k, v of sc
			continue unless v is @name
			@el.val(k)
			SHORTCUTS[v] = k
			break

		@el.on 'click', @onClick
		@el.on 'keydown', @onKeyDown

	onClick: =>
		@el.focus()

	onKeyDown: (e)=>
		key = String.fromCharCode(e.which)
		@el.val(key)
		SHORTCUTS[@name] = key
		saveShortcuts()

saveShortcuts = ->
	sc = {}

	for name, key of SHORTCUTS
		sc[key] = name

	localStorage.shortcuts = JSON.stringify(sc)


