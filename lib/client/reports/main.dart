library pingpong.reports;

import 'dart:math' as math;
import 'dart:collection';
import '../common.dart';

part 'all_games.dart';
part 'settings.dart';

void main() {
  common_main();
  initSettings();

  PlayerManager.loadAll().then((_) {
    PageManager.goto(new AllGamesReport());
  });
}

const FMT = const FormattingNamespace();

class FormattingNamespace {
  const FormattingNamespace();

  String number(num n, {int decimal: 0}) {
    if (n == null || n.isNaN) return "";
    return n.toStringAsFixed(decimal);
  }

  String percent(num n, {int decimal: 2}) {
    if (n == null || n.isNaN) return "";
    return "${(n * 100).toStringAsFixed(decimal)}%";
  }

  String date(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
