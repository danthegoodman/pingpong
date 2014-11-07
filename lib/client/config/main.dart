library pingpong.config;

import '../common.dart';
import '../button_handler.dart';

part 'button_page.dart';
part 'player_page.dart';

void main() {
  common_main();
  ButtonMappings.init();

  var buttonTab = querySelector("#buttonTab");
  var playerTab = querySelector("#playerTab");

  buttonTab.onClick.listen((_)=> PageManager.goto(new ButtonPage()));
  playerTab.onClick.listen((_)=> PageManager.goto(new PlayerPage()));

  PageManager.setLink(ButtonPage, buttonTab);
  PageManager.setLink(PlayerPage, playerTab);

  PlayerManager.loadAll().then((_) {
    PageManager.goto(new PlayerPage());
  });
}
