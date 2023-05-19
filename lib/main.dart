import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tron_api/eth_global.dart';
import 'package:flutter_tron_api/tron_global.dart';
import 'package:otp/otp.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/model/sql/dbUtil.dart';
import 'package:bobi_pay_out/service/service_voss_local.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/event_bus.dart';
import 'package:bobi_pay_out/utils/string.dart';
import 'package:bobi_pay_out/utils/utility.dart';

import 'app/app_scene.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails d) {
    debugInfo.printErrorStack(d.exception, d.stack,
        titleInfo: '[main] FlutterError.onError');
  };

  runZonedGuarded(() async {
    pdebug("开始运行");
    //初始化
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await mainInit();
      await mainUpdateConf();
      eventBus.emit(EventEnums.showGoogleDialog);
      eventBus.emit(EventEnums.appInitData);
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(AppScene());
    // Android状态栏透明 splash为白色,所以调整状态栏文字为黑色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light));
  }, (dynamic error, dynamic stack) {
    debugInfo.printErrorStack(error, stack,
        titleInfo: '[main] runZoned.onError');
  });
}

Future mainInit() async {
  // 初始化数据库
  List<String> list = await dbMgr.initDB();
  // 初始化配置
  await confMgr.initData(list);
  // await chukuanMgr.initData(list);
  // 初始化配置数据
  await confMgr.init();
  await addrMgr.init();
}

Future mainUpdateConf() async {
  // 更新配置数据
  String? localUrl = await confMgr.getValueByKey("voss_local");
  String? localSalt = await confMgr.getValueByKey('voss_local_salt');
  if (localUrl != null &&
      localSalt != null &&
      localUrl.isNotEmpty &&
      localSalt.isNotEmpty) {
    await serviceVossLocal.setUrlToken(localUrl, localSalt);
  }

  String? tjUrl = await confMgr.getValueByKey("voss_tj");
  String? tjSalt = await confMgr.getValueByKey('voss_tj_salt');
  if (tjUrl != null &&
      tjSalt != null &&
      tjUrl.isNotEmpty &&
      tjSalt.isNotEmpty) {
    await serviceVossTj.setUrlToken(tjUrl, tjSalt);
  }

  String? trxGrpc = await confMgr.getValueByKey("trx_grpc");

  if (trxGrpc != null && trxGrpc.isNotEmpty) {
    tronGlobal.trx_grpc = trxGrpc;
  }

  String? trxFeeLimit = await confMgr.getValueByKey("trx_fee_limit");

  if (trxFeeLimit != null && trxFeeLimit.isNotEmpty) {
    tronGlobal.trx_fee_limit = int.tryParse(trxFeeLimit)!;
  }

  String? trxPrice = await confMgr.getValueByKey("trx_price");

  if (trxPrice != null && trxPrice.isNotEmpty) {
    tronGlobal.trx_price = int.tryParse(trxPrice)!;
  }

  String? trxCostAddr = await confMgr.getValueByKey("trx_cost_addr");

  if (trxCostAddr != null && trxCostAddr.isNotEmpty) {
    tronGlobal.trx_cost_addr = trxCostAddr;
  }

  String? trxCostPriKey = await confMgr.getValueByKey("trx_cost_pri_key");

  if (trxCostPriKey != null && trxCostPriKey.isNotEmpty) {
    tronGlobal.trx_cost_pri_key = trxCostPriKey;
  }
  String? ethRpc = await confMgr.getValueByKey("eth_rpc");

  if (ethRpc != null && ethRpc.isNotEmpty) {
    ethGlobal.ethRpc = ethRpc;
  }

  String? ethGasLimit = await confMgr.getValueByKey("eth_gas_limit");

  if (ethGasLimit != null && ethGasLimit.isNotEmpty) {
    ethGlobal.eth_gas_limit = double.tryParse(ethGasLimit)!;
  }

  String? ethCostAddr = await confMgr.getValueByKey("eth_cost_addr");

  if (ethCostAddr != null && ethCostAddr.isNotEmpty) {
    ethGlobal.eth_cost_addr = ethCostAddr;
  }

  String? ethCostPriKey = await confMgr.getValueByKey("eth_cost_pri_key");

  if (ethCostPriKey != null && ethCostPriKey.isNotEmpty) {
    ethGlobal.eth_cost_pri_key = ethCostPriKey;
  }

  String? ethConfirmTime = await confMgr.getValueByKey("eth_confirm_time");

  if (ethConfirmTime != null && ethConfirmTime.isNotEmpty) {
    ethGlobal.eth_confirm_time = int.tryParse(ethConfirmTime)!;
  }

  String? googleKey = await confMgr.getValueByKey("google_key");

  if (googleKey != null && googleKey.isNotEmpty) {
    confMgr.google_key = googleKey;
  } else {
    confMgr.google_key = '';
  }

  await addrMgr.updateConf();
}

Future<bool?> showCustomDialog(BuildContext context,
    {String? title = '提示',
    String? content = '',
    String? ok = '确定',
    String? cancel = '取消',
    required FutureOr<void> Function(bool result) onResult}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("$title"),
        content: Text("$content"),
        actions: <Widget>[
          TextButton(
              child: Text("$cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                onResult(false);
              }),
          TextButton(
            child: Text("$ok"),
            onPressed: () async {
              Navigator.of(context).pop(true);
              onResult(true);
            },
          ),
        ],
      );
    },
  );
}

TextEditingController controller = TextEditingController(); // _drController
Future<bool?> showCustomDialog2(BuildContext context,
    {String? title = '提示',
    String? content = '',
    String? ok = '确定',
    String? cancel = '取消',
    required FutureOr<void> Function(bool result, {String? str})
        onResult}) async {
  controller.clear();
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("$title"),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 300.w,
            child: TextFormField(
              minLines:
                  2, // any number you need (It works as the rows for the textarea)
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: controller,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text("$cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                onResult(false);
              }),
          TextButton(
            child: Text("$ok"),
            onPressed: () async {
              final str = controller.text;
              Navigator.of(context).pop(true);
              onResult(true, str: str);
            },
          ),
        ],
      );
    },
  );
}

Future<bool?> showGoogleDialog(BuildContext context, bool mounted,
    {FutureOr<void> Function(bool result)? onResult}) async {
  final secret = confMgr.google_key.isEmpty ? OTP.randomSecret() : '';
  String code = '';
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(secret.isEmpty ? '验证谷歌码' : '扫码绑定谷歌KEY'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              secret.isEmpty
                  ? const SizedBox.shrink()
                  : InkWell(
                      child: Center(
                        child: PrettyQr(
                          typeNumber: null,
                          size: 100.w,
                          data: 'otpauth://totp/voss?secret=$secret',
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          roundEdges: true,
                        ),
                      ),
                      onTap: () {
                        copyStr(secret);
                        showToastTip("复制成功:$secret");
                      },
                    ),
              TextFormField(
                maxLength: 6,
                // autofocus: true,
                decoration: const InputDecoration(
                  hintText: '输入您的谷歌码',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, //数字，只能是整数
                ],
                onChanged: (value) {
                  code = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onResult != null) {
                        onResult(false);
                      }
                    },
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (code == null || code.isEmpty) {
                        return showToastTip("请输入谷歌码");
                      }
                      if (secret.isEmpty) {
                        bool pass = await confMgr.googleCodeVerification(code);
                        showToastTip(pass ? '验证成功' : '谷歌码错误🙅');
                        onResult!(pass);
                      } else {
                        bool pass = await confMgr.googleCodeVerification(code,
                            secret: secret);
                        if (!pass) {
                          //  onResult!(false);
                          return showToastTip('谷歌码错误🙅');
                        }
                        bool b = await confMgr.updateGoogleKey(secret);
                        // onResult!(b);
                        if (b) {
                          showToastTip("谷歌码绑定成功");
                        } else {
                          showToastTip("谷歌码绑定失败");
                        }
                      }
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
