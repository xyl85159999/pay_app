/// 错误代码枚举
class CodeDefine {
  static const int success = 0;
  //发言中文最低等级提示错误
  static const int codeLevelNoZw = -2;
  // 等级不够
  static const int codeLevelNoEnough = -101;
  // im找不到用户
  static const int codeUnfindUser = -201;
  // 主播已关播
  static const int codeCloseVideo = -500;
  // 上分失败
  static const int codeAddScore = -888;
  // 不是主播
  static const int codeNotPodcast = -1000;
  // 付费类型不对
  static const int codePayTypeErr = -8001;
  // 未登录的code
  static const int codeNotLogin = -10000;
  // 被踢线
  static const int codeOtherKick = -10001;
  // 无效用户
  static const int codeUnknowUser = -10010;
  // 包超时的code
  static const int codeTimeout = -50001;
  // 解包失败的code
  static const int codeParseFail = -50002;
  // 出错的code
  static const int codeRunError = -50003;
  // 没有网络的code
  static const int codeNotNet = -50004;
  // body是null
  static const int codeBodyNull = -50005;
  // body是字符串nil
  static const int codeBodyNil = -50006;
  // body是空字符串
  static const int codeBodyNullString = -50007;
  // body类型不对
  static const int codeBodyTypeErr = -50008;
  // body解开json出错
  static const int codeBodyDecodeErr = -50009;
  // body没有code
  static const int codeBodyNotCode = -50010;
  // body的code不是数字
  static const int codeBodyCodeNotInt = -50011;
  // 服务端崩溃的code
  static const int codeServiceCrash = -50500;

  ////////////////////////////////////////////////////////////
  //http自定义错误 -55000到-56000
  static const int codeHttpUnknowErr = -55000;
  //http连接超时
  static const int codeHttpConnectTimeout = -55600;
  //http请求超时
  static const int codeHttpSendTimeout = -55601;
  //http响应超时
  static const int codeHttpReceiveTimeout = -55602;
  //http出现异常,一般不会进这个,应该是变成-55500了
  static const int codeHttpResponse = -55603;
  //http请求取消
  static const int codeHttpCancel = -55604;
  //http未知错误
  static const int codeHttpDefault = -55605;
  static int getHttpErrStatus(int statusCode) {
    assert(statusCode >= 0 && statusCode < 1000);
    return codeHttpUnknowErr - statusCode;
  }

  /// 通过code解析出对应的msg
  static String parseMsg(int code) {
    switch (code) {
      case success:
        return '成功';
      case codeTimeout:
        return '包超时';
      case codeParseFail:
        return '解包失败';
      case codeRunError:
        return '客户端执行出错';
      case codeNotNet:
        return '没有网络';
      case codeBodyNull:
        return 'body是null';
      case codeBodyNil:
        return 'body是nil';
      case codeBodyNullString:
        return 'body是空字符串';
      case codeBodyTypeErr:
        return 'body类型不对';
      case codeBodyDecodeErr:
        return '解开body字符串出错';
      case codeBodyNotCode:
        return 'body没有code';
      case codeBodyCodeNotInt:
        return 'code不是数字';
      default:
        return '未知错误';
    }
  }
}
