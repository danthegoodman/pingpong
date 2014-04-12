part of pingpong.reports;

class AllGamesReport extends ManagerPage{
  final Element element = querySelector("#allGames");
  final _playerContainer = querySelector('#allGames .players tbody');
  final _bestGameStats = querySelector("#allGames .bestGames");
  Map<int, Element> _playerRows = {};

  void onShow(data){
    _bestGameStats.hidden = true;

    var players = PlayerManager.models.where(canShowPlayer);
    _renderPlayerRows(players);
    _loadPlayerSummaries(players);

    postJSON("/report/bestGames", {}).then(_processBestGames);
  }

  void _processPlayerTotals(Element row, Map d){
    num win = d['doublesWins'] + d['singlesWins'];
    num games = win + d['doublesLosses'] + d['singlesLosses'];
    num points = d['doublesPoints'] + d['singlesPoints'];
    num good = d['goodServes'];
    num serves = good + d['badServes'];

    _setNumText(row, '.games', games);
    _setPercentText(row, '.winRatio', win / games);

    _setNumText(row, '.scoreTotal', points);

    _setNumText(row, '.serveTotal', serves);
    _setPercentText(row, '.serveRatio', good / serves);
  }

  void _processBestGames(Map data){
    if(data.isEmpty) return;
    _renderScoringGame('.highestScoringGame', data['highestScore']);
    _renderScoringGame('.lowestScoringGame', data['lowestScore']);
    _renderTeamStreak('.longestTeamStreak', data['longestTeamStreak']);
    _renderPlayerStreak('.longestPlayerStreak', data['longestPlayerStreak']);
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
      _playerRows[p.id] = el;
      _playerContainer.append(el);
    }
  }

  void _renderScoringGame(String cssSelector, Map data){
    var el = _bestGameStats.querySelector(cssSelector);
    var game = new Game.blank()..fromJson(data);
    var w = game.winningTeam;
    var l = w.other;
    el.innerHtml = """
      <div class='team'>${game.team[w].join(' and ')} vs ${game.team[l].join(' and ')}</div>
      <div class='score'>${game.score[w]}<span> to </span>${game.score[l]}</div>
      <div class='date'>${game.date.month}/${game.date.day}/${game.date.year}</div>
    """;
  }

  void _renderTeamStreak(String cssSelector, Map data){
    var el = _bestGameStats.querySelector(cssSelector);
    var length = data['length'];
    var t = data['streaker'] == 0 ? T0 : T1;
    var game = new Game.blank()..fromJson(data['game']);
    el.innerHtml = """
      <div class='team'><strong>${game.team[t].join(' and ')}</strong> vs ${game.team[t.other].join(' and ')}</div>
      <div class='score'>${length}<span> points in a row</span></div>
      <div class='date'>${game.date.month}/${game.date.day}/${game.date.year}</div>
    """;
  }

  void _renderPlayerStreak(String cssSelector, Map data){
    var el = _bestGameStats.querySelector(cssSelector);
    var length = data['length'];
    var game = new Game.blank()..fromJson(data['game']);
    var player = PlayerManager.get(data['streaker']);
    var w = game.winningTeam;

    var teamText = "${game.team[w].join(' and ')} vs ${game.team[w.other].join(' and ')}";
    teamText = teamText.replaceFirst(player.name, "<strong>${player.name}</strong>");
    el.innerHtml = """
      <div class='team'>${teamText}</div>
      <div class='score'>${length}<span> points in a row</span></div>
      <div class='date'>${game.date.month}/${game.date.day}/${game.date.year}</div>
    """;
  }

  _setNumText(Element e, String css, num n, {int decimal: 0}){
    e.querySelector(css).text = n.toStringAsFixed(decimal);
  }

  _setPercentText(Element e, String css, num n){
    e.querySelector(css).text = "${(n*100).toStringAsFixed(2)}%";
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
