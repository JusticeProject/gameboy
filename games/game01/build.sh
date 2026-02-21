#!/usr/bin/sh

# this will convert it from relative path to absolute path
FULL_PATH=$(realpath "$0")
echo $FULL_PATH

# this will get the absolute path of the directory (without build.sh)
BASE_DIR=$(dirname $FULL_PATH)
echo $BASE_DIR

# gets the current directory without the full path
ROM_NAME=$(basename $BASE_DIR)
echo $ROM_NAME

# changes to the directory in case the script was invoked elsewhere using a relative path
pushd $BASE_DIR

# build it
rgbasm -Werror -Weverything -o main.o main.rgbasm
[ $? -eq 0 ] || exit 1
rgblink --dmg --tiny -o $ROM_NAME.gb main.o
[ $? -eq 0 ] || exit 1
rgbfix --title $ROM_NAME --pad-value 0 --validate $ROM_NAME.gb
[ $? -eq 0 ] || exit 1

# go back to initial directory
popd

exit 0

