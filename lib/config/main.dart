library pingpong.config;

import 'package:pingpong/common.dart';
import 'package:pingpong/button_handler.dart';

part 'button_page.dart';
part 'player_page.dart';

void main(){
  common_main();
  PageManager.addWithLink(new ButtonPage(), querySelector("#buttonTab"));
  PageManager.addWithLink(new PlayerPage(), querySelector("#playerTab"));
  PageManager.goto(PlayerPage);
}