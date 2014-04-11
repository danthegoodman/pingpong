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

  void _processGameCounts(Element row, Map d){
    num win = d['win'];
    num games = win + d['lose'];

    _setNumText(row, '.games', games);
    _setPercentText(row, '.winRatio', win / games);
  }

  void _processPointTotals(Element row, Map d){
    _setNumText(row, '.scoreTotal', d['total']);
  }

  void _processServeCounts(Element row, Map d){
    num good = d['good'];
    num total = good + d['bad'];
    _setNumText(row, '.serveTotal', total);
    _setPercentText(row, '.serveRatio', good / total);
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
    var reports = {
      '/report/gameCounts' : _processGameCounts,
      '/report/pointTotals': _processPointTotals,
      '/report/serveCounts': _processServeCounts,
    };

    var limit = {'players': players.map((p) => p.id).toList()};
    var allRequests = [];
    reports.forEach((path, dataHandler){
      allRequests.add(postJSON(path, limit).then((data){
        for(var d in data){
          dataHandler(_playerRows[d['_id']], d);
        }
      }));
    });
    Future.wait(allRequests).then(_alignValues);
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

  _setNumText(Element e, String css, num n){
    e.querySelector(css).text = n.toStringAsFixed(0);
  }

  _setPercentText(Element e, String css, num n){
    e.querySelector(css).text = "${(n*100).toStringAsFixed(2)}%";
  }

  ///Right align the numbers, but center the value in the cell.
  void _alignValues(_){
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
