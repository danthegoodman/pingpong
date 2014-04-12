part of pingpong.reports;

class PlayerReport extends ManagerPage{
  final Element element = querySelector("#playerReport");
  ReportRenderer txt;

  void onShow(Player player){
    txt = new ReportRenderer(element);
    window.location.hash = player.id.toString(); //TODO remove
    element.querySelector(".name").text = player.name;
    element.querySelector(".return").onClick.listen((_){
      PageManager.goto(AllGamesReport);
    });

    postJSON('/report/playerTotals', {'players': [player.id]}).then(_render);
  }

  void _render(Iterable<Map> allData){
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
  }
}
