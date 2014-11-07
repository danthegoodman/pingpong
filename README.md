# Ping Pong Scorekeeping Application

A scorekeeping and record-reporting web application.

## Description

This is a webapp, using Dart for the client and server with MongoDb as the database.
It is designed to be run on an internal or local network, meaning async calls are expected to be nearly immediate and potentially abused.
It was developed for Chrome, and though not tested in other browsers, it should work there too.

### Required Applications
1. Dart 1.7
1. MongoDB 2.6

### Environment Variables

* `PINGPONG_PORT`: The port to serve content on. Default is 8000.

### Development

    pub run server.dart
    ./pub-serve.sh

Once running, navigate to `http://localhost:{port}/index.html` to view a list of available pages.

### Production

    pub build
    pub run server.dart
