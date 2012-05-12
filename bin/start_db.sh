#!/bin/bash
# Starts the database and leaves it running.

if [ ! $PINGPONG_DIR ]; then
	echo 'PINGPONG_DIR not set'
	exit 1
fi

if [ $PINGPONG_DB_DIR ]; then
	DBPATH="$PINGPONG_DB_DIR"
else
	DBPATH="/data/db"
fi

mkdir -p $PINGPONG_DIR/log
mkdir -p $DBPATH

touch $PINGPONG_DIR/log/db.log

mongod \
	--dbpath $DBPATH \
	--fork \
	--logpath $PINGPONG_DIR/log/db.log \
	--logappend \
	--quiet \
	--journal

if [[ $PINGPONG_XTERM_ON_ERR && $? -ne 0 ]]; then
	xterm -hold -e "echo -e Something happened when launching the DB server."
fi