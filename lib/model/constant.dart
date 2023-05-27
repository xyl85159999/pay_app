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

const COLLECTION_LIST = {};

///订单状态枚举
enum PayOutStatusEnum {
  ///初始化
  payOutStatusNone,

  ///转账中
  payOutStatusProcessing,

  ///回调中
  payOutStatusCallback,

  ///成功
  payOutStatusSucceed,

  ///出错
  payOutStatusFail,
}

extension PayOutStatusEnumExt on PayOutStatusEnum {
  String get name {
    switch (this) {
      case PayOutStatusEnum.payOutStatusNone:
        return "初始化";
      case PayOutStatusEnum.payOutStatusProcessing:
        return "转账中";
      case PayOutStatusEnum.payOutStatusCallback:
        return "回调中";
      case PayOutStatusEnum.payOutStatusSucceed:
        return "成功";
      case PayOutStatusEnum.payOutStatusFail:
        return "出错";
      default:
        return "";
    }
  }
}
