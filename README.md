# Ping Pong Scorekeeping Application

A scorekeeping and record-reporting web application.

## Description

This is a webapp, using Groovy for the server and MongoDb as the database and Dart for the front end.
It is designed to be run on an internal or local network, meaning async calls are nearly immediate and potentially abused.
It was developed for Chrome, and though not tested in other browsers, it should work there too.

### Required Applications
1. Java 7
1. MongoDB 2.6
1. Dart 1.3
1. Gradle

### Preparing the Project

    gradle build

### Environment Variables

* `PINGPONG_PORT`: The port to serve content on. Default is 8000.

### Development

    gradle fake-data
    gradle run

Once running, navigate to `http://localhost:{port}/index.html` to view a list of available pages.

### Production

???
