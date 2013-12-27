#!/usr/bin/env bash

set -e

SCRIPT_DIR=`dirname $0`
pushd $SCRIPT_DIR > /dev/null

./pods.sh "$@"  
./test.sh "$@"
./build.sh "$@" 
./artifacts.sh "$@"

popd > /dev/null

