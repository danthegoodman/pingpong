part of pingpong.reports;

class AllGamesReport extends ManagerPage{
  AllGamesReport() {
    var settingsLink = new DivElement()
      ..className ='link'
      ..innerHtml = "<span class='icon-cog'></span>Settings"
      ..onClick.listen((_)=> PageManager.goto(new SettingsPage()));

    var links = new DivElement()
      ..className='links'
      ..append(settingsLink);

    element
      ..id = "allGames"
      ..append(links);

    var players = PlayerManager.models.where(canShowPlayer).map((x)=> x.id).toList();
    postJSON('/report/playerTotals', players).then(_processPlayerTotals);
    postJSON("/report/bestGames", {}).then(_processBestGames);
  }

  void _processPlayerTotals(Iterable<Map> data) {
    var results = new SplayTreeMap<Player, TableRowElement>();
    for (var d in data) {
      var p = PlayerManager.get(d['_id']);
      results[p] = _buildPlayerTotalRow(p, d);
    }

    var t = new TableElement();
    t.createTHead().addRow().innerHtml =
      "<th class='name'></th>"
      "<th class='games'>Games</th>"
      "<th class='winRatio'>Win Ratio</th>"
      "<th class='serveTotal'>Serves</th>"
      "<th class='serveRatio'>Good Ratio</th>";
    t.createTBody().children.addAll(results.values);

    _alignPlayerValues(t);
    element.append(new DivElement()..className = 'players'..append(t));
  }

  void _processBestGames(Map data){
    if(data.isEmpty) return;

    var t = new TableElement();
    t.addRow().children
      ..add(new Element.th()..text='Highest Scoring Game')
      ..add(_buildBestGame(data['highestScore']));

    t.addRow().children
      ..add(new Element.th()..text='Lowest Scoring Game')
      ..add(_buildBestGame(data['lowestScore']));

    t.addRow().children
      ..add(new Element.th()..text='Longest Doubles Streak')
      ..add(_buildBestStreak(data['doublesLongestStreak']));

    t.addRow().children
      ..add(new Element.th()..text='Longest Singles Streak')
      ..add(_buildBestStreak(data['singlesLongestStreak']));

    element.append(new DivElement()..className = 'bestGames'..append(t));
  }

  Element _buildPlayerTotalRow(Player p, Map d){
    num win = d['doublesWins'] + d['singlesWins'];
    num games = win + d['doublesLosses'] + d['singlesLosses'];
    num good = d['goodServes'];
    num serves = good + d['badServes'];

    var e = new TableRowElement();
    e.innerHtml =
      "<td class='name'>${p.name}</td>"
      "<td class='games'>${FMT.number(games)}</td>"
      "<td class='winRatio'>${FMT.percent(win / games)}</td>"
      "<td class='serveTotal'>${FMT.number(serves)}</td>"
      "<td class='serveRatio'>${FMT.percent(good / serves)}</td>";
    return e;
  }

  void _alignPlayerValues(TableElement t){
    var tbody = t.tBodies[0];
    var columns = ['td.games', 'td.scoreTotal', 'td.serveTotal'];
    for(var col in columns){
      var cells = tbody.querySelectorAll(col);
      int maxLen = cells.map((e)=> e.text.length).fold(0, math.max);
      for(var cell in cells){
        cell.innerHtml = cell.text.padLeft(maxLen, "&nbsp;");
      }
    }
  }

  Element _buildBestGame(Map data){
    if(data == null) return new Element.td();
    var game = new Game.fromJson(data);
    var w = game.winningTeam;
    var l = w.other;
    return new Element.td()..innerHtml =
      "<div class='team'>${game.team[w].join(' and ')} vs ${game.team[l].join(' and ')}</div>"
      "<div class='score'>${game.score[w]}<span> to </span>${game.score[l]}</div>"
      "<div class='date'>${FMT.date(game.date)}</div>";
  }

  Element _buildBestStreak(Map data){
    if(data == null) return new Element.td();
    var game = new Game.fromJson(data);
    var streak = game.longestPointStreak;
    var t = streak.team;
    return new Element.td()..innerHtml =
      "<div class='team'><strong>${game.team[t].join(' and ')}</strong> vs ${game.team[t.other].join(' and ')}</div>"
      "<div class='score'>${streak.length}<span> points in a row</span></div>"
      "<div class='date'>${FMT.date(game.date)}</div>";
  }
}
