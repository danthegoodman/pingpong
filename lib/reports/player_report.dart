part of pingpong.reports;

class PlayerReport extends ManagerPage{
  final Element element = querySelector("#playerReport");
  ReportRenderer txt;

  void onShow(Player player){
    txt = new ReportRenderer(element);
    window.location.hash = player.id.toString(); //DRK remove
    element.querySelector(".name").text = player.name;
    element.querySelector(".return").onClick.listen((_){
      PageManager.goto(AllGamesReport);
    });

    postJSON('/report/playerTotals', {'players': [player.id]}).then(_renderTotals);

    var opponents = PlayerManager.models.where(canShowPlayer).where((p)=> p != player);
    _reportSinglesMatchups(player, opponents);
//    _reportDoublesMatchups(player, opponents);
  }

  void _renderTotals(Iterable<Map> allData){
    var data = allData.single;

    var dWin = data['doublesWins'];
    var dLose = data['doublesLosses'];
    var dTot = dWin + dLose;
    txt.subrenderer('.doubles .total')
      ..number('.wins', dWin)
      ..number('.losses', dLose)
      ..number('.total', dTot)
      ..percent('.ratio', dWin / dTot);

    var sWin = data['singlesWins'];
    var sLose = data['singlesLosses'];
    var sTot = sWin + sLose;
    txt.subrenderer('.singles .total')
      ..number('.wins', sWin)
      ..number('.losses', sLose)
      ..number('.total', sTot)
      ..percent('.ratio', sWin / sTot);

    var aWin = dWin + sWin;
    var aLose = dLose + sLose;
    var aTot = dTot + sTot;
    txt.subrenderer('.allGames')
      ..number('.wins', aWin)
      ..number('.losses', aLose)
      ..number('.total', aTot)
      ..percent('.ratio', aWin / aTot);

    var dPts = data['doublesPoints'];
    var sPts = data['singlesPoints'];
    txt.subrenderer('.points .doubles')
      ..number('.total', dPts)
      ..number('.perGame', dPts / dTot, decimal: 2);
    txt.subrenderer('.points .singles')
      ..number('.total', sPts)
      ..number('.perGame', sPts / sTot, decimal: 2);

    num srvGood = data['goodServes'];
    num srvBad = data['badServes'];
    txt.subrenderer('.serves')
      ..number('.good', srvGood)
      ..number('.bad', srvBad)
      ..number('.total', srvGood + srvBad)
      ..percent('.ratio', srvGood / (srvGood + srvBad));

    txt.subrenderer('.misc')
      ..number('.longestStreak', data['longestStreak'])
      ..number('.fatalServes', data['fatalServes']);
  }

  void _reportSinglesMatchups(Player player, Iterable<Player> opponents){
    var el = element.querySelector('.singles tbody');
    el.children.clear();
    for(var p in opponents){
      postJSON('/report/matchProbability', {'players': [player.id, p.id]})
          .then((allData) => _renderSinglesMatchup(el, player, p, allData.first));
    }
  }

  void _reportDoublesMatchups(Player player, Iterable<Player> opponents){
    var el = element.querySelector('.doubles tbody');
    for(var p in opponents){
      postJSON('/report/matchProbability', {'players': [player.id, p.id]})
          .then((allData) => _renderSinglesMatchup(el, player, p, allData.first));
    }
  }

  void _renderSinglesMatchup(TableSectionElement el, Player pl, Player op, Map data){
    List players = data['players'];
    var counts = [data['team0'], data['team1']];
    int pNdx = players.indexOf(pl.id);

    int wins = counts[pNdx];
    int lose = counts[(pNdx-1).abs()];
    int total = wins + lose;

    if(total == 0) return;
    var row = el.addRow()..innerHtml = """
      <th>${op.name}</th>
      <td class="total"></td>
      <td class="wins"></td>
      <td class="losses"></td>
      <td class="ratio"></td>""";

    el.append(row);
    new ReportRenderer(row)
      ..number('.wins', wins)
      ..number('.losses', lose)
      ..number('.total', wins + lose)
      ..percent('.ratio', wins / (wins + lose));
  }
}
