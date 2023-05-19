import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:bobi_pay_out/app/root_scene.dart';
import 'package:bobi_pay_out/pages/tongji_detail.dart';

var rootSceneHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return RootScene();
});

var tongjiDetailHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var baoming = params['bao_ming']?.first ?? "";
  var st = params['startDate']?.first;
  var et = params['endDate']?.first;

  if (st == null || et == null) {
    return TongJiDetailPage(baoming);
  }

  final startDate = DateTime.fromMicrosecondsSinceEpoch(int.parse(st));
  final endDate = DateTime.fromMicrosecondsSinceEpoch(int.parse(et));
  return TongJiDetailPage(baoming, startDate: startDate, endDate: endDate);
});
