part of pingpong.common;

PageManager_Instance PageManager = new PageManager_Instance();

class PageManager_Instance{
  final _links = new Map<Type, Element>();
  ManagerPage _currentPage;

  void setLink(Type type, Element element){
    _links[type] = element;
  }

  void goto(ManagerPage nextPage){
    ManagerPage prevPage = _currentPage;
    _currentPage = nextPage;

    if(prevPage != null){
      prevPage.onLeave();
      Element prevLink = _links[prevPage.runtimeType];
      if(prevLink != null){
        prevLink.classes.remove('selected');
      }
    }

    Element nextLink = _links[nextPage.runtimeType];
    if(nextLink != null){
      nextLink.classes.add('selected');
    }

    _fadeOut(prevPage)
      .then((_)=> _fadeIn(nextPage));
  }
}

Future _fadeOut(ManagerPage p){
  if(p == null) return new Future.value();

  p.element.style
    ..opacity = ""
    ..zIndex = "";

  return new Future.delayed(new Duration(milliseconds: 500))
    .then((_)=> p.element.remove());
}

void _fadeIn(ManagerPage p){
  document.body.append(p.element);
  new Future((){
    p.element.style
      ..opacity = "1"
      ..zIndex = "1";
  });
}

abstract class ManagerPage{
  final element = new Element.section()..className = 'page';

  void onLeave(){
  }
}
