// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:bobi_pay_out/utils/utility.dart';

final EncryptUtil encryptUtil = EncryptUtil();

/// Encrypt Util.
class EncryptUtil {
  /// md5 加密
  String encodeMd5(String data) {
    var content = const Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  /// 异或对称加密
  String xorCode(String res, String key) {
    List<String> keyList = key.split('');
    List<int> codeUnits = res.codeUnits;
    List<int> codes = [];
    for (int i = 0, length = codeUnits.length; i < length; i++) {
      int code = codeUnits[i] ^ keyList[i % keyList.length].codeUnitAt(0);
      codes.add(code);
    }
    return String.fromCharCodes(codes);
  }

  /// 异或对称 Base64 加密
  String xorBase64Encode(String res, String key) {
    String encode = xorCode(res, key);
    encode = base64Encode(encode);
    return encode;
  }

  /// 异或对称 Base64 解密
  String xorBase64Decode(String res, String key) {
    String encode = base64Decode(res);
    encode = xorCode(encode, key);
    return encode;
  }

  /*
  * Base64加密
  */
  String base64Encode(String data) {
    var content = convert.utf8.encode(data);
    var digest = convert.base64Encode(content);
    return digest;
  }

/*
  * Base64解密
  */
  String base64Decode(String data) {
    List<int> bytes = convert.base64Decode(data);
    // 网上找的很多都是String.fromCharCodes，这个中文会乱码
    //String txt1 = String.fromCharCodes(bytes);
    String result = convert.utf8.decode(bytes);
    return result;
  }

  String make(Map<String, dynamic> info, String saltKey) {
    if (saltKey.isEmpty) return 'saltKey is null';
    info["tm"] = nowUnixTimeSecond();

    final qsX = base64Encode(jsonEncode(info));
    final sign = md5.convert(utf8.encode(qsX + saltKey)).toString();
    final sk = "info=$qsX&sign=$sign";
    return sk;
  }

  dynamic check(String info, String sign, String saltKey) {
    if (saltKey.isEmpty) return 'saltKey is null';

    info = info.replaceAll(" ", "+");

    if (md5.convert(utf8.encode(info + saltKey)).toString().contains(sign) ==
        false) {
      return {'code': -1, 'msg': 'err sign'};
    }
    final strAppinfo = base64Decode(info);
    final appinfoTable = Map.from(jsonDecode(strAppinfo));
    return appinfoTable;
  }
}
