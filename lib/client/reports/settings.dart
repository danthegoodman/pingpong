part of pingpong.reports;

void initSettings(){
  var maybeUpdate = (key, value){
    if(!window.localStorage.containsKey(key)) window.localStorage[key] = value;
  };

  maybeUpdate('showInfrequent', 'true');
  maybeUpdate('showGuests', 'false');
  maybeUpdate('showInactive', 'false');
}

bool canShowPlayer(Player player){
  if(!player.frequent && window.localStorage['showInfrequent'] == 'false') return false;
  if(player.guest && window.localStorage['showGuests'] == 'false') return false;
  if(!player.active && window.localStorage['showInactive'] == 'false') return false;
  return true;
}

class SettingsPage extends ManagerPage{
  final _guests = new Checkbox()..el.text = "Show Guest Players";
  final _inactive = new Checkbox()..el.text = "Show Inactive Players";
  final _infrequent = new Checkbox()..el.text = "Show Infrequent Players";

  SettingsPage(){
    element.id = "settings";

    var returnButton = new ButtonElement()
      ..className = "return"
      ..text = "Return to Reports"
      ..onClick.listen((_) => PageManager.goto(new AllGamesReport()));

    _handleSetting('showGuests', _guests);
    _handleSetting('showInactive', _inactive);
    _handleSetting('showInfrequent', _infrequent);

    element
      ..append(_inactive.el)
      ..append(_guests.el)
      ..append(_infrequent.el)
      ..append(returnButton);
  }

  void _handleSetting(String key, Checkbox checkbox){
    checkbox.value = (window.localStorage[key] == 'true');
    checkbox.onChange.listen((b){
      window.localStorage[key] = b.toString();
    });
  }
}
