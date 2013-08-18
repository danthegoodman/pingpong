library us.kirchmeier.pingpong.reports;

import 'dart:html';
import 'package:pingpong/common.dart';
import 'tournament.dart';
import 'all_games.dart';

Tournament CURRENT_TOURNY;
SelectElement _reportSelect;
Map _reportOptions = {};

void main(){
  var tournyReport = new TournamentReport();
  PageManager.add(new AllGamesReport());
  PageManager.add(tournyReport);

  _reportSelect = query("#report");
  _reportSelect.onChange.listen(_onReportSelectChange);

  Future playersFetched = PlayerManager.loadAll();
  Future inProgressFetched = getJSON('/inprogress');
  Future.wait([inProgressFetched, playersFetched]).then((result){
    var tourny = result[0]['tournament'];
    if(tourny != null){
      _reportOptions["Current Tournament"] = TournamentReport;
      tournyReport.currentTournament = new Tournament()..fromJson(tourny);
    }
    _reportOptions["All Games"] = AllGamesReport;

    _populateSelect();
    _onReportSelectChange();
  });
}

void _populateSelect(){
  var options = _reportOptions.keys.map((n)=>new OptionElement(n));
  options.first.selected = true;
  _reportSelect.children.addAll(options);
}

void _onReportSelectChange([q]){
  PageManager.goto(_reportOptions[_reportSelect.value]);
}
