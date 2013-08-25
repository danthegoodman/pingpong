library us.kirchmeier.pingpong.config;

import 'dart:html';
import 'package:pingpong/common.dart';
import 'button_page.dart';
import 'player_page.dart';

final StreamController<Player> _playerDataChange = new StreamController<Player>.broadcast();

void main(){
  PageManager.addWithLink(new ButtonPage(), query("#buttonTab"));
  PageManager.addWithLink(new PlayerPage(), query("#playerTab"));
  PageManager.goto(ButtonPage);
}
