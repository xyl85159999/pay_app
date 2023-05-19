import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bobi_pay_out/model/update_block_bean.dart';
import 'package:bobi_pay_out/utils/encrypt_util.dart';
import 'package:bobi_pay_out/utils/platform_utils.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:common_utils/common_utils.dart';

import '../manager/timer_mgr.dart';
import '../utils/code_define.dart';

/// 不过短连接还是长连接,他们总是有一些业务是一样的,所以他们需要一个共同的基类
/// 处理游戏盾
/// 第一次的登录问题
abstract class BaseService extends OnUpdateActor {
  ///////////////////////////////////////////////
  //Tunnel的连接URI
  Uri? _uri;
  //token
  late String _salt;

  Uri _parseUri(String url) {
    url = url.trim();
    //转换成uri地址
    Uri result = Uri.parse(url);
    //没有主机
    assert(!ObjectUtil.isEmpty(result.host));
    return result;
  }

  /// 设置url和salt
  Future<int> setUrlToken(String url, String salt) async {
    assert(url.isNotEmpty);
    _salt = salt;
    _uri = _parseUri(url);
    return 0;
  }

  String makeSign(Map<String, dynamic> info) {
    return encryptUtil.make(info, _salt);
  }

  dynamic check(String info, String sign) {
    return encryptUtil.check(info, sign, _salt);
  }

  /// 真正的post
  Future<HttpResponseBean> httpPost(String path, String info) async {
    mypdebug("httpPost start $path $info");

    dynamic body;

    if (_uri == null) {
      mypdebug("名称 key 未配置...");
      body = {"code": CodeDefine.codeHttpDefault, "msg": "名称 key 未配置"};
      return HttpResponseBean(body, path, {'param': info});
    }

    //最多重试3次,每次往后等待时间多1s
    for (int i = 0; i < 3; i++) {
      //防止死循环，先把重试次数减一
      var httpClient = HttpClient();
      try {
        Uri uri = _uri!.replace(path: path);
        var request = await httpClient.postUrl(uri);

        // var parts = [];
        // data.forEach((key, value) {
        //   parts.add('${Uri.encodeQueryComponent(key)}='
        //       '${Uri.encodeQueryComponent(value.toString())}');
        // });
        // var formData = parts.join('&');
        request.headers
            .add('Content-type', 'application/x-www-form-urlencoded');
        request.write(info);

        var rep = await request.close();
        int status = rep.statusCode;
        var utf8Stream = rep.transform(const Utf8Decoder());
        String responseBody = await utf8Stream.join();
        switch (status) {
          case 200:
            body = jsonDecode(responseBody);
            break;
          case 500:
            body = {'code': CodeDefine.codeServiceCrash, 'msg': responseBody};
            break;
          case 403:
            mypdebug("$path 需要重新鉴权");
            body = {'code': CodeDefine.codeServiceCrash, 'msg': responseBody};
            break;
          case 404:
            mypdebug("$path 路径不存在");
            body = {'code': CodeDefine.codeServiceCrash, 'msg': responseBody};
            break;
          default:
            body = {"code": CodeDefine.codeHttpDefault, "msg": "$rep"};
            break;
        }
        // 不管有没有成功，走到这里都不需要重试了
        break;
      } catch (e) {
        // 异常转化成返回值
        // debugInfo.printErrorStack(crashType, e, null, titleInfo: 'httpPost:$path');
        body = {"code": CodeDefine.codeHttpDefault, "msg": "$e"};
        await Future.delayed(Duration(seconds: i + 1));
      } finally {
        httpClient.close();
      }
    }

    final paramStr = body['msg'];
    if (paramStr != null &&
        paramStr is String &&
        paramStr.toString().contains('info=') &&
        paramStr.toString().contains('sign=')) {
      Map<String, String> params = {};
      List<String> pList = paramStr.split('&');
      if (pList.isNotEmpty) {
        for (var i = 0; i < pList.length; i++) {
          final str = pList[i];
          final idx = str.indexOf('=');
          List<String> pObj = [str.substring(0, idx), str.substring(idx + 1)];
          if (pObj.length == 2) {
            String key = pObj[0];
            try {
              params[key] = Uri.decodeComponent(pObj[1]);
            } catch (e) {
              params[key] = pObj[1];
            }
          }
        }
      }

      final info = params['info'];
      final sign = params['sign'];
      final obj = check(info!, sign!);
      body = obj;
    }
    if (body['code'] != 0) {
      showToastTip('$path,$body');
    }
    mypdebug('httpPost res $path, $body');

    return HttpResponseBean(body, path, {'param': info});
  }
}
