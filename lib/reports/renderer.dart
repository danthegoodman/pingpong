part of pingpong.reports;

class ReportRenderer {
  final Element _el;
  ReportRenderer(this._el);

  ReportRenderer subrenderer(String sel) {
    return new ReportRenderer(_el.querySelector(sel));
  }

  void number(String sel, num n, {int decimal: 0}){
    if(n == null || n.isNaN) return;
    _el.querySelector(sel).text = n.toStringAsFixed(decimal);
  }

  void percent(String sel, num n, {int decimal: 2}){
    _el.querySelector(sel).text = "${(n*100).toStringAsFixed(decimal)}%";
  }

  void game(String sel, Map data){
    var game = new Game.blank()..fromJson(data);
    var w = game.winningTeam;
    var l = w.other;
    _el.querySelector(sel).innerHtml = """
      <div class='team'>${game.team[w].join(' and ')} vs ${game.team[l].join(' and ')}</div>
      <div class='score'>${game.score[w]}<span> to </span>${game.score[l]}</div>
      <div class='date'>${_renderDate(game.date)}</div>
    """;
  }

  void teamStreak(String sel, Map data){
    var t = data['streaker'] == 0 ? T0 : T1;
    var game = new Game.blank()..fromJson(data['game']);
    _el.querySelector(sel).innerHtml = """
      <div class='team'><strong>${game.team[t].join(' and ')}</strong> vs ${game.team[t.other].join(' and ')}</div>
      <div class='score'>${data['length']}<span> points in a row</span></div>
      <div class='date'>${_renderDate(game.date)}</div>
    """;
  }

  void playerStreak(String sel, Map data){
    var game = new Game.blank()..fromJson(data['game']);
    var player = PlayerManager.get(data['streaker']);
    var w = game.winningTeam;

    var teamText = "${game.team[w].join(' and ')} vs ${game.team[w.other].join(' and ')}";
    teamText = teamText.replaceFirst(player.name, "<strong>${player.name}</strong>");
    _el.querySelector(sel).innerHtml = """
      <div class='team'>${teamText}</div>
      <div class='score'>${data['length']}<span> points in a row</span></div>
      <div class='date'>${_renderDate(game.date)}</div>
    """;
  }

  String _renderDate(DateTime date){
    return "${date.month}/${date.day}/${date.year}";
  }
}
