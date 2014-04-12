import 'dart:html';

void main() {
  querySelector('#recalculate').onClick.listen(_recalculateReports);
}

void _recalculateReports(_){
  var out = querySelector('#recalculateOutput');
  out.children.clear();

  var es = new EventSource("recalculate");
  es.url = "/api/recalculate"; //TODO rewrite backend in ratpack so I can do this... crappy Spark.
  es.onOpen.listen((e){
    print(e);
  });
  es.onMessage.listen((e){
    print(e);
  });
  es.onError.listen((e){
    print(e);
  });
}
