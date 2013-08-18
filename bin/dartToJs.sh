#!/bin/bash
# Compiles dart code to javascript, using dart2js.

command -v dart2js >/dev/null 2>&1 || { echo >&2 "Command not found: dart2js"; exit 1; }

# Move to the web dart & js dir
CDPATH=""
cd `dirname ${BASH_SOURCE[0]}`/../client/web/js

dartCompile() {
  echo "Compiling $1 to javascript"
  dart2js \
    --out=$1.js \
    --minify \
    $1
}

dartCompile config.dart
dartCompile createTournament.dart
dartCompile reports.dart
dartCompile scorekeeper.dart

