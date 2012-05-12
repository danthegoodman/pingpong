# Ping Pong Scorekeeping Application

A scorekeeping and record-reporting web application.

### Desciprtion

This is a webapp, using Node.js for the server and MongoDb as the
database. It is designed to be run on an internal or local network,
meaning async calls are nearly immediate and potentially abused. It 
was developed for Chrome, and though not tested in other browsers, 
it should work there too.

### Required Applications
* Node.js(0.6.x)
* npm
* MongoDB(2.0.x)
** specifically the `mongod` binary

### Additional Installation 
    npm -g install forever coffee-script less
    npm install

### Running the Application
Inside the `bin` directory, there are a couple of scripts which 
can start the server or the database.

Once running, navigate to 'localhost/index' to view a list of 
available pages.

### Development
The command `cake` will provide information for starting the db, 
server and more.

### More
`queryDb.coffee` is a handy file for easily running a query or two
against the database. By default, it does nothing, so uncomment the 
portions of the code you wish to run.

	coffee queryDb.coffee