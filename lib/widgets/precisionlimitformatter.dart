// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';

class PrecisionLimitFormatter extends TextInputFormatter {
  final int _scale;

  PrecisionLimitFormatter(this._scale);

  RegExp exp = RegExp(r"[0-9]");
  static const String POINTER = ".";
  static const String DOUBLE_ZERO = "00";
  static const String ZERO = "0";

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // mypdebug('oldValue:${oldValue.text}');
    // mypdebug('newValue:${newValue.text}');
    if (newValue.text.startsWith('.')) {
      return const TextEditingValue(
          text: '0.', selection: TextSelection.collapsed(offset: 2));
    }

    // if (newValue.text.startsWith(POINTER) && newValue.text.length == 1) {
    //   //第一个不能输入小数点
    //   return oldValue;
    // }

    ///输入完全删除
    if (newValue.text.isEmpty) {
      return const TextEditingValue();
    }

    ///只允许输入小数
    if (!exp.hasMatch(newValue.text)) {
      return oldValue;
    }

    if (newValue.text.startsWith(ZERO)) {
      final numStr = newValue.text.split("0")[1];
      if (numStr.startsWith(RegExp(r'[0-9]'))) {
        return TextEditingValue(
            text: numStr, selection: const TextSelection.collapsed(offset: 1));
      }
      // return newValue;
    }

    ///包含小数点的情况
    if (newValue.text.contains(POINTER)) {
      ///包含多个小数
      if (newValue.text.indexOf(POINTER) !=
          newValue.text.lastIndexOf(POINTER)) {
        return oldValue;
      }
      String input = newValue.text;
      int index = input.indexOf(POINTER);

      ///小数点后位数
      int lengthAfterPointer = input.substring(index, input.length).length - 1;

      ///小数位大于精度
      if (lengthAfterPointer > _scale) {
        return oldValue;
      }
    } else if (newValue.text.startsWith(POINTER) ||
        newValue.text.startsWith(DOUBLE_ZERO)) {
      ///不包含小数点,不能以“00”开头
      return oldValue;
    }

    if (newValue.text.length > 8) {
      return oldValue;
    }
    return newValue;
  }
}
