#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

if [ ! -e config.status ]
then
    ./configure
fi
make -j
sudo make install
