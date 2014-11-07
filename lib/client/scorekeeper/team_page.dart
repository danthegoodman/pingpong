part of pingpong.scorekeeper;

const SIGNIFICANT_GAME_SIZE = 20;
const SCORE_MULTIPLIER = 100;

class TeamPage extends ManagerPage{
  final List<Player> players;

  TeamPage(this.players){
    var cancel = new DivElement()
      ..text="Return to Player Selection"
      ..className="cancel"
      ..onClick.first.then((q)=> PageManager.goto(new PlayerPage()));

    element.id = "teamPage";
    element.append(cancel);

    var searchedPlayers = players.map((p)=> p.id).toList()..sort();
    postJSON('/report/idealTeam', {'players': searchedPlayers})
      .then((data)=> _onPlayersGamesResult(data));
  }

  void _onPlayersGamesResult(Map data){
    var groups = [];
    data.forEach((team, data)=> groups.add(new _TeamGroup(team, data)));
    groups.sort();

    element.children.addAll(groups.map((x)=> x.toElement()));
  }
}

class _TeamGroup implements Comparable<_TeamGroup>{
  final Map data;
  final String teamId;

  _TeamGroup(this.teamId, this.data);

  int get games => data['games'];
  bool get isNotSignificant => games < SIGNIFICANT_GAME_SIZE;

  String get players {
    _formatTeam(team)=> team.split(',').map(PlayerManager.get).join(' & ');;
    return teamId.split('-').map(_formatTeam).join(' vs. ');
  }

  String get score {
    if(data['score'] == null) return '\u{2014}';
    num s = data['score'] * SCORE_MULTIPLIER;
    return "${s > 0 ? '+' : ''}${s.toStringAsFixed(3)}";
  }

  //Significant then highest score then most games
  int compareTo(_TeamGroup o) {
    var sig = isNotSignificant ? 0 : 1;
    var osig = o.isNotSignificant ? 0 : 1;

    var r = Comparable.compare(osig, sig);
    if(r != 0) return r;

    var scr = data['score'] == null ? -1000 : data['score'];
    var oscr = o.data['score'] == null ? -1000 : o.data['score'];
    r = Comparable.compare(oscr, scr);
    if(r != 0) return r;

    return Comparable.compare(o.games, games);
  }

  Element toElement(){
    el(clazz,text) => new DivElement()..className = clazz..text = text;

    var details = new DivElement()
      ..className = 'details'
      ..append(el('players', players))
      ..append(el('games', "${games} games"));

    return new DivElement()
      ..onClick.first.then(handleClick)
      ..className = 'team ${isNotSignificant ? 'insignificant' : ''}'
      ..append(el('score', score))
      ..append(details);
  }

  void handleClick(_){
    var players = teamId.split(new RegExp('[-,]'));
    //move one of the second team members to the correct place
    players.insert(1, players.removeAt(RNG.nextInt(2) + 2));

    //shuffle the starting lineup
    int pivot = RNG.nextInt(4);
    if(pivot > 0){
      players.addAll(players.getRange(0, pivot));
      players.removeRange(0, pivot);
    }

    GameManager.create(new Game(PlayerManager.mapFrom(players))).then((newGame){
      PageManager.goto(new GamePage(newGame));
    });
  }
}
