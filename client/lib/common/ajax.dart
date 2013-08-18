library us.kirchmeier.pingpong.common.ajax;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;

Future getJSON(String url){
  return requestJSON('GET', url, null);
}

Future postJSON(String url, dynamic sendData){
  return requestJSON('POST', url, sendData);
}

Future requestJSON(String method, String url, [dynamic sendData]){
  var c = new Completer();

  var requestHeaders = {};
  if(sendData != null && sendData is! String){
    sendData = json.stringify(sendData);
    requestHeaders['Content-Type'] = 'application/json';
  }

  HttpRequest.request(url, method: method,
      requestHeaders: requestHeaders,
      sendData: sendData)
    ..then((xhr)=> c.complete(json.parse(xhr.responseText)))
    ..catchError((e)=> c.completeError(e));

  return c.future;
}