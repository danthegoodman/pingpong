#!/bin/bash
# Starts the server using forever. When the server quits,
# it will be restarted automatically.

if [ ! $PINGPONG_DIR ]; then
	echo 'PINGPONG_DIR not set'
	exit 1
fi

mkdir -p $PINGPONG_DIR/log
touch $PINGPONG_DIR/log/server.out.log
touch $PINGPONG_DIR/log/server.err.log

NODE_ENV=production

forever \
	-l $PINGPONG_DIR/log/server.out.log \
	-e $PINGPONG_DIR/log/server.err.log \
	--append \
	start \
	-c coffee \
	$PINGPONG_DIR/app.coffee

if [[ $PINGPONG_XTERM_ON_ERR && $? -ne 0 ]]; then
	xterm -hold -e echo 'Failed to start server.'
fi