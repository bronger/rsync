#!/bin/sh

SCRIPT=$(realpath -e "$0") || exit 1
SCRIPTPATH=$(dirname "$SCRIPT") || exit 1
cd "$SCRIPTPATH" || exit 1

./build.sh || exit 2

source=`mktemp -d /tmp/rsync_test.XXXXXXXX` || exit 3
destination=`mktemp -d /tmp/rsync_test.XXXXXXXX` || exit 3

# Cases:
#
# 1 – File in source & destination
# 2 – File in source & destination, deleted in source before Rsync
# 3 – File in destination, created after cut time
# 4 – File in destination, created before cut time
#
# “cut time” is the time given to Rsync in ``--delete-older``.  It simulates
# the point in time at which the previous synchronisation from destination to
# source took place.
#
# Situation in destination after first Rsync:
#
# 1 & 2 present.
#
# Expected situation in destination after second Rsync:
#
# 1 & 3 present.

(
    touch "$destination"/4
    touch "$source"/1 "$source"/2 || exit 4
    sleep 2
    cp -a "$source"/* "$destination" || exit 4
    cut_time=`date +%s` || exit 7
    touch "$destination"/3 || exit 4
    rm "$source"/2 || exit 4

    rsync -avu --delete-older="$cut_time" "$source"/ "$destination" || exit 5
    # rsync -avu "$source"/ "$destination" || exit 5
    # rm "$destination"/2 "$destination"/4

    [ -e "$destination"/3 ] || exit 6
    [ -e "$destination"/1 ] || exit 8
    [ ! -e "$destination"/2 ] || exit 9
    [ ! -e "$destination"/4 ] || exit 10
)
exit_code=$?
rm -Rf "$source" "$destination"
if [ $exit_code -eq 0 ]
then
echo "Test successful!"
fi
exit $exit_code
