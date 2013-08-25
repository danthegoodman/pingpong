library us.kirchmeier.pingpong.common;

import 'dart:html';

export 'dart:async';
export 'common/button_mappings.dart';
export 'common/page_manager.dart';
export 'common/models.dart';
export 'common/ajax.dart';

main(){
  print("""Did you know that there are some "hidden" pages? They may not
interest you, but navigate to '/index' to see the complete list.
""");

  query("#asyncError").style.display = '';
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
