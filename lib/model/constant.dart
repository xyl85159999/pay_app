// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const Color mainColor = Color(0xff354465);
const Color iconColor = Color(0xff2D61D3);
const Color fontColor = Color(0xff999999);
const Color bgColor = Color(0xffF4F4F4);
const Color dividerColor = Color(0xffF6F6F6);

const Divider divider = Divider(
  color: dividerColor,
  height: 2,
  thickness: 2,
);

const COLLECTION_STATUS_NONE = 0; //转账初始化
const COLLECTION_STATUS_COST = 1; //转入费用中
const COLLECTION_STATUS_ING = 2; //转账中
const COLLECTION_STATUS_OK = 3; //转账完成
const COLLECTION_STATUS_PASS = 4; //不转账
const COLLECTION_STATUS_FAIL = 5; //转账失败
const COLLECTION_STATUS_WAITING_SIGIN = 6; //等待远程签名
const COLLECTION_STATUS_WAITING_CONFIRM = 7; //等待确认
const COLLECTION_STATUS_HEIGHT_ENERGY = 8; //高费用

const COLLECTION_LIST = {
  "$COLLECTION_STATUS_NONE" : "转账初始化",
  "$COLLECTION_STATUS_COST" : "转入费用中",
  "$COLLECTION_STATUS_ING" : "转账中",
  "$COLLECTION_STATUS_OK" : "转账完成",
  "$COLLECTION_STATUS_PASS" : "不转账",
  "$COLLECTION_STATUS_FAIL" : "转账失败",
  "$COLLECTION_STATUS_WAITING_SIGIN" : "等待远程签名",
};

const TRANSFER_TASK_STATUS_NONE = 0; // 初始化
const TRANSFER_TASK_STATUS_ACCEPT = 1; // 确认开始出款
const TRANSFER_TASK_STATUS_ING = 2; // 出款中
const TRANSFER_TASK_STATUS_OK = 10; // 出款完成
const TRANSFER_TASK_STATUS_FAIL = 11; // 出款出错
const TRANSFER_TASK_STATUS_NOT_USDT = 12; // 余额不足
const TRANSFER_TASK_STATUS_REJECT = 13; // 拒绝出款
const TRANSFER_TASK_STATUS_INVALID = 14; // 作废

const TRANSFER_TASK_LIST = {
  "$TRANSFER_TASK_STATUS_NONE" : "初始化",
  "$TRANSFER_TASK_STATUS_ACCEPT" : "确认开始出款",
  "$TRANSFER_TASK_STATUS_ING" : "出款中",
  "$TRANSFER_TASK_STATUS_OK" : "出款完成",
  "$TRANSFER_TASK_STATUS_FAIL" : "出款出错",
  "$TRANSFER_TASK_STATUS_NOT_USDT" : "余额不足",
  "$TRANSFER_TASK_STATUS_REJECT" : "拒绝出款",
  "$TRANSFER_TASK_STATUS_INVALID" : "作废",
};
