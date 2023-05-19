#!/bin/sh
home=$(cd "$(dirname "$0")" && pwd)
if [ ! -d "$home"/plugin ]; then
  echo "not plugin dir"
  exit 0
fi
cd plugin || exit
plugin_path=$(pwd)
files=$(ls "$plugin_path")
for item in $files; do
  if [ -d "$files/$item" ]; then
    cd "$item" || exit
    echo get "$item"
    flutter pub get
    cd ../
  fi
done
flutter pub get
