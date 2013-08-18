library us.kirchmeier.pingpong.common;

import 'dart:html';
import 'dart:json' as json;

import 'dart:async';
import 'common/page_manager.dart';
import 'common/models.dart';
import 'common/ajax.dart';

export 'dart:async';
export 'common/page_manager.dart';
export 'common/models.dart';
export 'common/ajax.dart';


main(){
  print("""Did you know that there are some "hidden" pages? They may not
interest you, but navigate to '/index' to see the complete list.
""");

  query("#asyncError").style.display = '';
}

Map<String, String> readShortcuts(){
  var s = window.localStorage['shortcuts'];
  try {
    return json.parse(s);
  } catch (e){
    return {'Q': '01', 'P':'10', 'Z':'00', 'M':'11'};
  }
}

//#-------------- Async Handler ---------------#
//_sync = Backbone.sync
//
//window.syncSuccess = ->
//
//window.syncError = (e, type, msg)->
//  console.error """
//    Error Communicating with Server.
//    Status: #{e.status} (#{e.statusText})
//    Messsage: #{e.responseText}
//  """
//  $("#asyncError").fadeIn(200)
//
//Backbone.sync = (method, model, options) ->
//  s = $.Callbacks()
//  s.add -> syncSuccess(arguments...)
//  s.add options.success if options?.success
//
//  e = $.Callbacks()
//  e.add -> syncError(arguments...)
//  e.add options.fail if options?.fail
//
//  _sync method, model,
//    success: s.fire
//    error: e.fire
