part of pingpong.common;

class Checkbox {
  final Element el;
  final _changeStream = new StreamController.broadcast();
  bool _value;

  Checkbox(this.el){
    el.onClick.listen(_onClick);
  }

  bool get value => _value;
  void set value(bool v){
    _value = v;
    el.classes.toggle('checkbox-checked', v);
  }

  void _onClick(_){
    value = !value;
    _changeStream.add(value);
  }

  Stream<bool> get onChange => _changeStream.stream;
}
