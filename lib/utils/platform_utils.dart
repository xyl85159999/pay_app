import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';

export 'dart:io';

/// 是否是生产环境
const bool inProduction = bool.fromEnvironment("dart.vm.product");

class PlatformUtils {
  static PackageInfo? instance;
  static init() async {
    PlatformUtils.instance = await PackageInfo.fromPlatform();
    pdebug(PlatformUtils.instance);
  }

  static String getPackageName() {
    return instance!.packageName;
  }

  static String getAppVersion() {
    return instance!.version;
  }

  static String getBuildNum() {
    return instance!.buildNumber;
  }

  static Future getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      return await deviceInfo.iosInfo;
    } else {
      return null;
    }
  }
}
