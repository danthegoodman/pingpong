import 'dart:html';

void main() {
  querySelector('#recalculate').onClick.listen(_recalculateReports);
}

void _recalculateReports(_){
  var out = querySelector('#recalculateOutput');
  out.children.clear();
  var write = (data)=> out.appendText("${data}\n");

  var ws = new WebSocket("ws://${window.location.host}/ws/recalculate");
  ws.onOpen.listen((e)=> write(":Connected"));
  ws.onMessage.listen((e)=> write(e.data));
  ws.onError.listen((e)=> write(":Error - ${e}"));
  ws.onClose.listen((e)=> write(":Disconnected"));
}
