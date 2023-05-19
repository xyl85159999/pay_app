#!/bin/sh
set -e
cd plugin/flutter_tron_api
flutter clean
flutter pub get
cd ../..
flutter clean
flutter pub get
if [ "$1" == "1" ]; then
    flutter pub upgrade
fi
cd ios
pod install
if [ "$2" == "1" ]; then
    pod update
fi
cd ..
