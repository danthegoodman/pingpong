part of pingpong.reports;

class AllGamesReport extends ManagerPage{
  final Element element = querySelector("#allGames");
  final _playerContainer = querySelector('#allGames .players tbody');
  final _bestGameStats = querySelector("#allGames .bestGames");
  final _playerRows = new Map<int, ReportRenderer>();

  void onShow(data){
    _bestGameStats.hidden = true;

    var players = PlayerManager.models.where(canShowPlayer);
    _renderPlayerRows(players);
    _loadPlayerSummaries(players);

    postJSON("/report/bestGames", {}).then(_processBestGames);
  }

  void _processPlayerTotals(ReportRenderer rndr, Map d){
    num win = d['doublesWins'] + d['singlesWins'];
    num games = win + d['doublesLosses'] + d['singlesLosses'];
    num points = d['doublesPoints'] + d['singlesPoints'];
    num good = d['goodServes'];
    num serves = good + d['badServes'];

    rndr..number('.games', games)
        ..percent('.winRatio', win / games)
        ..number('.scoreTotal', points)
        ..number('.serveTotal', serves)
        ..percent('.serveRatio', good / serves);
  }

  void _processBestGames(Map data){
    if(data.isEmpty) return;

    var rndr = new ReportRenderer(_bestGameStats);
    rndr..game('highestScoringGame', data['highestScore'])
        ..game('lowestScoringGame', data['lowestScore'])
        ..teamStreak('longestTeamStreak', data['longestTeamStreak'])
        ..playerStreak('longestPlayerStreak', data['longestPlayerStreak']);
    _bestGameStats.hidden = false;
  }

  _loadPlayerSummaries(Iterable<Player> players){
    var limit = {'players': players.map((p) => p.id).toList()};
    postJSON('/report/playerTotals', limit).then((data){
      for(var d in data){
        _processPlayerTotals(_playerRows[d['_id']], d);
      }
      _alignValues();
    });
  }

  _renderPlayerRows(Iterable<Player> players){
    _playerContainer.children.clear();
    _playerRows.clear();

    for(var p in players){
      var el = new TableRowElement()..className = 'player';
      el.onClick.listen((_)=> PageManager.goto(PlayerReport, p));
      el.innerHtml = """
        <td class='name'>${p.name}</td>
        <td class='games'></td>
        <td class='winRatio'></td>
        <td class='scoreTotal'></td>
        <td class='serveTotal'></td>
        <td class='serveRatio'></td>
      """;
      _playerRows[p.id] = new ReportRenderer(el);
      _playerContainer.append(el);
    }
  }

  ///Right align the numbers, but center the value in the cell.
  void _alignValues(){
    var columns = ['td.games', 'td.scoreTotal', 'td.serveTotal'];
    for(var col in columns){
      var cells = _playerContainer.querySelectorAll(col);
      int maxLen = cells.map((e)=> e.text.length).fold(0, math.max);
      for(var cell in cells){
        cell.innerHtml = cell.text.padLeft(maxLen, "&nbsp;");
      }
    }
  }
}
