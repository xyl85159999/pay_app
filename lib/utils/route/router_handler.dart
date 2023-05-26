import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:bobi_pay_out/app/root_scene.dart';

var rootSceneHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return RootScene();
});
