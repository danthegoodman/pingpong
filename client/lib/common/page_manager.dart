library us.kirchmeier.pingpong.common.pagemanager;

import 'dart:html';

PageManager_Instance PageManager = new PageManager_Instance();

class PageManager_Instance{
  Map<Type, ManagerPage> _pages = new Map<Type, ManagerPage>();
  ManagerPage _current;

  void add(ManagerPage page){
    _pages[page.runtimeType] = page;
  }

  bool isCurrent(Type page){
    return _current == _pages[page];
  }

  void goto(Type page){
    var prev = _current;
    var next = _pages[page];
    _current = next;

    if(prev != null){
      prev.onHide();
      _fadeOut(prev.element);
    }
    if(next != null){
      next.onShow();
      _fadeIn(next.element, delay: prev != null);
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

abstract class ManagerPage{
  Element get element;
  void onShow(){
  }
  void onHide(){
  }
}
