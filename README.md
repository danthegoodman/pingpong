# Ping Pong Scorekeeping Application

A scorekeeping and record-reporting web application.

## Description

This is a webapp, using Node.js for the server and MongoDb as the database and Dart for the front end.
It is designed to be run on an internal or local network, meaning async calls are nearly immediate and potentially abused.
It was developed for Chrome, and though not tested in other browsers, it should work there too.

### Required Applications
1. Node.js(0.10.x)
1. npm
1. MongoDB(2.0.x)
1. Dart

### Installation
    # Install coffee-script and forever to your system
    npm -g install forever coffee-script

### Preparing the Project
    # Download project dependencies
    npm install

    # Compile Dart to Javascript
    ./bin/dartToJs.sh

### Environment Variables

* `PINGPONG_DIR`: The location of this project on your machine. Defaults to current working directory.
* `PINGPONG_PORT`: The port to serve content on. Default is 8000.

### Running the app

*Development*: `coffee app.coffee`
*Production*: `bin/forever_server.sh`

For production, `forever` is used to keep the application running, restarting it after fatal errors.
Logs are saved to the `log` directory and are viewable from the application.

Once running, navigate to `http://localhost:{port}/index` to view a list of available pages.

### Dart Development with Dart Editor

Open the `client` directory with dart editor.
Do not open the root project directory.

A single run configuration can be used to launch the application in Dartium with debugging.
Set the launch target URL to `http://localhost:{port}/index` and set the source to the pingpong client application.

