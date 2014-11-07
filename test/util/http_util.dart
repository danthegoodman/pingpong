library pingpong.test.util.http;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

const TESTING_PORT = 9900;

final httpClient = new HttpClient();

Future<HttpTestResponse> http(String method, String path, [body]) {
  return httpClient.open(method, "localhost", TESTING_PORT, path).then((req) {
    if (body != null) {
      var content = JSON.encode(body);
      req.headers.contentType = ContentType.JSON;
      req.headers.contentLength = content.length;
      req.write(content);
    }
    return req.close();
  }).then((HttpClientResponse res) {
    return res.transform(UTF8.decoder).fold("", (p, e) => p + e)
        .then((text)=> new HttpTestResponse(res.statusCode, text.isEmpty ? null : JSON.decode(text)));
  });
}

class HttpTestResponse {
  final int statusCode;
  final json;
  HttpTestResponse(this.statusCode, this.json);
}
