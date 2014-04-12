part of pingpong.reports;

final _settings = {
    'showInactive': false,
    'showGuests': false,
    'showInfrequent': false,
};

bool canShowPlayer(Player player){
  if(!player.frequent && !_settings['showInfrequent']) return false;
  if(player.guest && !_settings['showGuests']) return false;
  if(!player.active && !_settings['showInactive']) return false;
  return true;
}

class SettingsPage extends ManagerPage{
  final Element element = querySelector("#settings");
  final _guests = new Checkbox(querySelector("#settings .showGuest"));
  final _inactive = new Checkbox(querySelector("#settings .showInactive"));
  final _infrequent = new Checkbox(querySelector("#settings .showInfrequent"));

  SettingsPage(){
    element.querySelector(".returnFromSettings")
      .onClick.listen((_)=> PageManager.goto(AllGamesReport));

    var storage = window.localStorage;
    _handleSetting('showGuests', _guests);
    _handleSetting('showInactive', _inactive);
    _handleSetting('showInfrequent', _infrequent);
  }

  void _handleSetting(String key, Checkbox checkbox){
    _settings[key] = window.localStorage[key] == 'true';
    checkbox.value = _settings[key];
    checkbox.onChange.listen((b){
      _settings[key] = b;
      window.localStorage[key] = b.toString();
    });
  }
}
