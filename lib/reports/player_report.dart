part of pingpong.reports;

class PlayerReport extends ManagerPage{
  final Element element = querySelector("#playerReport");

  void onShow(Player player){
    window.location.hash = player.id.toString();
  }
}
