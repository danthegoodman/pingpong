part of pingpong.common;

PageManager_Instance PageManager = new PageManager_Instance();

class PageManager_Instance{
  Map<Type, _PageLookup> _pages = new Map<Type, _PageLookup>();
  _PageLookup _current;

  void add(ManagerPage page){
    _pages[page.runtimeType] = new _PageLookup(page);
  }

  void addWithLink(ManagerPage page, Element link){
    _pages[page.runtimeType] = new _PageLookup(page, link);
    link.onClick.listen((q)=> goto(page.runtimeType));
  }

  bool isCurrent(Type page){
    return _current == _pages[page];
  }

  void goto(Type page, [data]){
    _PageLookup prev = _current;
    _PageLookup next = _pages[page];
    _current = next;

    if(prev != null){
      prev.page.onHide();
      if(prev.link != null){
        prev.link.classes.remove('selected');
      }
      _fadeOut(prev.page.element);
    }
    if(next != null){
      next.page.onShow(data);
      if(next.link != null){
        next.link.classes.add('selected');
      }
      _fadeIn(next.page.element, delay: prev != null);
    }
  }
}

void _fadeOut(Element e){
  e.style..transitionDelay = ""
    ..opacity = ""
    ..zIndex = "";
}

void _fadeIn(Element e, {delay: true}){
  e.style..transitionDelay = delay ? "500ms" : ""
    ..opacity = "1"
    ..zIndex = "1";
}

class _PageLookup {
  final ManagerPage page;
  final Element link;
  _PageLookup(this.page, [this.link = null]);
}

abstract class ManagerPage{
  Element get element;
  void onShow(data){
  }
  void onHide(){
  }
}
