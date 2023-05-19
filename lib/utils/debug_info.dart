import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bobi_pay_out/utils/platform_utils.dart';

/// 输出限定字符串长度,0为不限制
const OUTPUT_LEN = 500;

enum EnumSentry {
  EnumSentryDef,
}

DebugInfo debugInfo = new DebugInfo();

const int _max = 100;

//调试打印
pdebug(info, {int? len, bool writeSentry = true, String? prefix}) {
  prefix ??= "debug";
  String msg = '${DateTime.now()} $prefix: $info';
  // if (writeSentry) debugInfo.addLog(msg);
  if (inProduction) return;
  len = len ?? OUTPUT_LEN;
  if (len > 0 && msg.length > len) {
    msg = msg.substring(0, len);
  }
  print('$msg');
}

extension objectExtension on Object {
  @protected
  mypdebug(dynamic msg, {bool writeSentry = true, int len = OUTPUT_LEN}) {
    String outMsg = '[$runtimeType]$msg';
    pdebug(outMsg, writeSentry: writeSentry, len: len);
  }
}

//////////////////////////////////////////////////////////
//////////////////////////堆栈收集/////////////////////////
//////////////////////////////////////////////////////////
class DebugInfo {
  late List<String> _logs;
  late int _bi;

  DebugInfo() {
    _logs = [];
    _bi = 0;
  }

  Future<void> init() async {}

  void addLog(String log) {
    if (_logs.length > _bi)
      _logs[_bi] = log;
    else
      _logs.add(log);
    _bi++;
    if (_bi >= _max) _bi = 0;
  }

  List<String> _getLogHistory() {
    List<String> result = [];
    for (var i = _bi; i < _logs.length; i++) result.add(_logs[i]);
    for (var i = 0; i < _bi; i++) result.add(_logs[i]);
    return result;
  }

  /// 排除
  bool _exclude(e) {
    if (e is PlatformException) {
      if (e.code == 'OPEN' &&
          e.message == null &&
          e.details == null &&
          e.stacktrace == null) return true;
      if (e.code == 'PLAY_ERROR' && e.details == '网络连接已中断。') return true;
    }
    return false;
  }

  String _formatE(e) {
    if (e == null) return "";
    String result = '''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->
''';
    print(result);
    return e.toString();
  }

  String _formatS(s) {
    if (s == null) return "";
    String result = '''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
''';
    print(result);
    return s.toString();
  }

  void _saveErrorMsg(e, s, EnumSentry es) {
    // postException(e, s, jsonEncode(_getLogHistory()), Platform.operatingSystem);

//     String temp =
//         '''${Conf.appName}[${defaultTargetPlatform == TargetPlatform.iOS ? "苹果" : "安卓"}]${Conf.clientVersion}
// 机型:${dataMgr.deviceInfoStr}
// APP:${Conf.appName} ${Conf.channelID}
// 用户:${dataMgr.mainUserId} ${dataMgr.mainUser?.nickname ?? '数据异常'}
// token:${dataMgr.appToken}
// $msg''';

//     List<String> route = [];
//     UserNavigatorObserver.history.forEach((element) {
//       route.add(element.toString());
//     });

//     serviceApi.sentry(
//         _getSentryDsn(es),
//         '${inProduction ? '发布版' : '调试版'} ${e.runtimeType} $e',
//         temp,
//         jsonEncode(_getLogHistory()),
//         jsonEncode(route),
//         es.index + 1);
  }

  /// [e]为错误类型 :可能为 Error , Exception ,String
  /// [s]为堆栈信息
  void printErrorStack(e, s,
      {String titleInfo = '',
      bool save = true,
      EnumSentry es = EnumSentry.EnumSentryDef}) {
    if (_exclude(e)) return;
    mypdebug(titleInfo);
    String msg = '$titleInfo\n${_formatE(e)}\n${_formatS(s)}';

    if (save) {
      try {
        _saveErrorMsg(e, s, es);
      } catch (e) {
        mypdebug("_saveErrorMsg:$e");
      }
    }
    // if (!inProduction)
    // Future.delayed(const Duration(seconds: 1)).then((value) => ShowToast(
    //       text: msg,
    //       determinecallback: () {},
    //     ));
  }

  //////////////////////////////////////////////////////////
  //////////////////////////网络统计/////////////////////////
  //////////////////////////////////////////////////////////
  // 发包统计
  apiSendDataStat(String path, int size) {}
  // 回包统计
  apiCallBackStat(String path, int size) {}
  // 超时统计
  apiTimeOutStat(String path) {}
}
