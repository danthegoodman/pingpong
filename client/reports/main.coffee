window.PAGES = new PageManager()

$ ->
	PAGES.add new AllGamesReport(el: $ '#allGames')
	PAGES.add new TournamentReport(el: $ '#tournament')

	reports = {}

	reportSelect = $("#report")
	reportSelect.on 'change', ->
		PAGES.goto reports[reportSelect.val()]

	playersFetched = PlayerList.fetch()
	inProgressFetched =	$.getJSON '/inprogress'

	$.when(inProgressFetched, playersFetched).then (progressData)->
		unless _.isEmpty( progressData[0]['tournament'] )
			reports["Current Tournament"] = TournamentReport
			t = new Tournament(progressData[0]['tournament'])
			TournamentList.add t
			TournamentList.trigger 'select', t

		reports["All Games"] = AllGamesReport
		for n, r of reports
			reportSelect.append "<option>#{n}</option>"

		reportSelect.change()
