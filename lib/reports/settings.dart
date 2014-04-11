part of pingpong.reports;

bool _showInactive = false;
bool _showGuests = false;

bool canShowPlayer(Player player){
  if(!player.active) return _showInactive;
  if(player.guest) return _showGuests;
  return true;
}

class SettingsPage extends ManagerPage{
  final Element element = querySelector("#settings");
  final _guests = new Checkbox(querySelector("#settings .showGuestPlayers"));
  final _inactive = new Checkbox(querySelector("#settings .showInactivePlayers"));

  SettingsPage(){
    element.querySelector(".returnFromSettings")
      .onClick.listen((_)=> PageManager.goto(AllGamesReport));

    var storage = window.localStorage;
    _showGuests = storage['showGuests'] == 'true';
    _showInactive = storage['showInactive'] == 'true';

    _guests.value = _showGuests;
    _inactive.value = _showInactive;

    _guests.onChange.listen((b){
      _showGuests = b;
      storage['showGuests'] = b.toString();
    });

    _inactive.onChange.listen((b){
      _showInactive = b;
      storage['showInactive'] = b.toString();
    });
  }
}
