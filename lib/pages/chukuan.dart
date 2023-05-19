// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/main.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/manager/chukuan_mgr.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/event_bus.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';
import 'package:bobi_pay_out/utils/string.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/chukuan_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_bagname_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_balance_model.dart';
import 'package:bobi_pay_out/view_model/root_scene_model.dart';
import 'package:bobi_pay_out/widgets/date_time_picker.dart';
import 'package:bobi_pay_out/widgets/precisionlimitformatter.dart';
import 'package:bobi_pay_out/widgets/sizebox_icon_button.dart';

class ChuKuanPage extends StatefulWidget {
  const ChuKuanPage({Key? key}) : super(key: key);

  @override
  State<ChuKuanPage> createState() => _ChuKuanPageState();
}

class _ChuKuanPageState extends State<ChuKuanPage> {
  final TextEditingController _addrController =
      TextEditingController(); // config_des

  final TextEditingController _amoutController =
      TextEditingController(); // config_value
  final TextEditingController _remarkController =
      TextEditingController(); // config_key

  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    // _addrController.text = 'TPgyhN2daWc5oY62RsSECn3v3yJFBtUEMK';
    // _amoutController.text = '1';
    // _remarkController.text = 'beizhu';
  }

  Widget getRow(
      {required TextEditingController controller,
      required String title,
      required String hintText,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool disable = false}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(title),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            height: 40.w,
            decoration: BoxDecoration(
              color: disable ? Colors.grey : const Color(0xffededed),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: TextField(
              readOnly: disable,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              keyboardAppearance: Brightness.light,
              controller: controller,
              maxLines: 2,
              style: TextStyle(fontSize: 12.w),
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                        style: BorderStyle.none)), //输入框启用时，下划线的样式
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                        style: BorderStyle.none)),
                contentPadding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                  top: 8.w,
                ),
                hintText: hintText,
              ),
            ),
          ),
        )
      ],
    );
  }

  // 表单添加数据
  Future<void> showInformationDialog(BuildContext context) async {
    return await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(10.w),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              height: MediaQuery.of(context).size.height / 3.0 + 100.h,
              child: Column(
                children: [
                  const Center(
                    child: Text('添加出款'),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      const Text('钱包类型:  '),
                      Consumer<DiZhiBagNameModel>(
                        builder: (context, value, child) {
                          if (value.listWalletTypeBagName.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return DropdownButton<String>(
                            menuMaxHeight:
                                MediaQuery.of(context).size.height / 3.0,
                            items: value.listWalletTypeBagName
                                .map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                value: e.toString(),
                                child: Text('$e'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              value.selectWalletType = v!;
                            },
                            hint: Text('请选择钱包类型',
                                style: TextStyle(fontSize: 14.w)),
                            value: value.selectWalletType,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('包名:  '),
                      Consumer<DiZhiBagNameModel>(
                        builder: (context, value, child) {
                          if (value.listBagName.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return DropdownButton<String>(
                            menuMaxHeight:
                                MediaQuery.of(context).size.height / 3.0,
                            items: value.listSelectBagName
                                .map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                value: e['books_name'].toString(),
                                child: Text('${e['books_name']}'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              value.select_books_name = v!;
                            },
                            hint: Text('请选择出款包',
                                style: TextStyle(fontSize: 14.w)),
                            value: value.select_books_name,
                          );
                        },
                      ),
                      Expanded(
                        child: Consumer<DiZhiBalanceModel>(
                          builder: (context, value, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('余额:${value.usdt_balance}',
                                    style: TextStyle(fontSize: 14.w)),
                                SizeBoxIconButton(
                                  onPressed: () async {
                                    await dizhi_balance_model.query_balance();
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  //key
                  getRow(
                      controller: _addrController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]|[A-Z]|[a-z]')),
                      ],
                      title: '地址:  ',
                      hintText: '请输入地址'),
                  SizedBox(height: 10.w),
                  // 参数描
                  getRow(
                      controller: _amoutController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        PrecisionLimitFormatter(2),
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))
                      ],
                      title: '金额:  ',
                      hintText: '请输入金额'),
                  SizedBox(height: 10.w),
                  //数据
                  getRow(
                      controller: _remarkController,
                      title: '描述:  ',
                      hintText: '请输入描述'),
                  SizedBox(height: 20.w),
                  Row(
                    // mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('取消'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Routes.popPage(context);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('添加'),
                          onPressed: () async {
                            if (dizhi_bagname_model.selectWalletType.isEmpty) {
                              showToastTip('请选择钱包类型');
                              return;
                            }
                            if (dizhi_bagname_model.select_books_name.isEmpty) {
                              showToastTip('请选择付款包名');
                              return;
                            }
                            if (_addrController.text.isEmpty) {
                              showToastTip('地址错误');
                              return;
                            }
                            if (_amoutController.text.isEmpty) {
                              showToastTip('金额错误');
                              return;
                            }

                            final balance =
                                double.parse(_amoutController.text.trim());
                            if (balance <= 0) {
                              showToastTip('金额错误');
                              return;
                            }
                            if (dizhi_balance_model.usdt_balance < balance) {
                              showToastTip("当前包余额不足～");
                              return;
                            }

                            if (mounted) {
                              Routes.popPage(context);
                            }
                            await showComfire(context);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future showComfire(BuildContext buildContext) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('出款详情'),
          content: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${_amoutController.text} USDT",
                    style: TextStyle(fontSize: 14.w),
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Row(
                    children: [
                      Text(
                        "收款地址",
                        style: TextStyle(fontSize: 14.w),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: Text(
                          _addrController.text,
                          maxLines: 3,
                          style: TextStyle(fontSize: 14.w),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Row(
                    children: [
                      Text(
                        "付款包名:",
                        style: TextStyle(fontSize: 14.w),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text(
                        "${dizhi_bagname_model.select_books_name}",
                        style: TextStyle(fontSize: 14.w),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showInformationDialog(context);
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (mounted) {
                            Routes.popPage(context);
                          }
                          final to_addr = _addrController.text.trim();
                          final amount =
                              double.tryParse(_amoutController.text.trim());
                          showGoogleDialog(context, mounted,
                              onResult: (result) async {
                            if (!result) return;
                            final bb = await chukuanMgr.new_transfer_task(
                                dizhi_bagname_model.select_books_name,
                                to_addr,
                                amount!,
                                dizhi_bagname_model.selectWalletType,
                                remark: _remarkController.text);
                            if (!bb) return;
                            _addrController.clear();
                            _amoutController.clear();
                            _remarkController.clear();
                          });
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),
        );
      },
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  String get_collect_status(int status) {
    return TRANSFER_TASK_LIST[status.toString()] ?? '-';
  }

  getBtn(String str, {void Function()? onTap}) {
    return InkWell(
      onTap: () {
        showGoogleDialog(context, mounted, onResult: (result) async {
          if (!result) return;
          onTap!();
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: 40.w,
          height: 20.w,
          decoration: BoxDecoration(
              border: Border.all(color: mainColor, width: 1.w),
              color: mainColor,
              borderRadius: BorderRadius.circular(8.w)),
          child: Center(
            child: Text(
              str,
              style: TextStyle(color: Colors.white, fontSize: 12.w),
            ),
          )),
    );
  }

  //当前每行显示数组
  showRowCell(data) {
    if (data == null) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
      height: 200.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "出款包名：",
                        style: TextStyle(fontSize: 12.w),
                      ),
                      Expanded(
                          child: Text(
                        (data.fromBagName ?? '').toString(),
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      )),
                    ],
                  ),
                ),
                Text(
                  DateTimeFormat.toLong(data.updateTime! * 1000),
                  style: TextStyle(fontSize: 12.w),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "钱包类型：",
                        style: TextStyle(fontSize: 12.w),
                      ),
                      Expanded(
                          child: Text(
                        (data.walletType ?? '').toString(),
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      )),
                    ],
                  ),
                ),
              ],
            ),

            // 出款地址:
            Row(
              children: [
                Text("出款地址：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.toAddr ?? '').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                (data.toAddr == null || data.toAddr.isEmpty)
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          copyStr((data.toAddr ?? '').toString());
                          showToastTip(
                              "复制成功:${(data.toAddr ?? '').toString()}");
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 2.w),
                          width: 40.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                              border: Border.all(color: mainColor, width: 1.w),
                              color: mainColor,
                              borderRadius: BorderRadius.circular(6.w)),
                          child: Center(
                            child: Text(
                              '复制',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.w),
                            ),
                          ),
                        ),
                      ),
              ],
            ),

            // 金额
            Row(
              children: [
                Text("已完成：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.finishAmount ?? '0').toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                Text("出款中：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.tarningAmount ?? '0').toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                Text("金额：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.amount ?? '0').toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
              ],
            ),
            // 状态
            Row(
              children: [
                Text("状态：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    get_collect_status(data.status ?? 0),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                SizeBoxIconButton(
                  onPressed: () async {
                    await chukuan_model.debounceRefresh();
                  },
                ),
                Text("描述：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    data.remark.toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                )
              ],
            ),

            (data.status != TRANSFER_TASK_STATUS_NONE &&
                    data.status != TRANSFER_TASK_STATUS_NOT_USDT)
                ? const SizedBox.shrink()
                : (data.status == TRANSFER_TASK_STATUS_NONE
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getBtn(
                            '出款',
                            onTap: () async {
                              final count = await chukuanMgr.begin_tran(data);
                              if (count) {
                                setState(() {
                                  data.status = TRANSFER_TASK_STATUS_ACCEPT;
                                });
                              }
                            },
                          ),
                          getBtn(
                            '拒绝',
                            onTap: () async {
                              final count = await chukuanMgr.reject_tran(data);
                              if (count) {
                                setState(() {
                                  data.status = TRANSFER_TASK_STATUS_REJECT;
                                });
                              }
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getBtn(
                            '重试',
                            onTap: () async {
                              final count = await chukuanMgr.begin_tran(data);
                              if (count) {
                                setState(() {
                                  data.status = TRANSFER_TASK_STATUS_ACCEPT;
                                });
                              }
                            },
                          ),
                          getBtn(
                            '作废',
                            onTap: () async {
                              final count = await chukuanMgr.invalid_tran(data);
                              if (count) {
                                setState(() {
                                  data.status = TRANSFER_TASK_STATUS_INVALID;
                                });
                              }
                            },
                          ),
                        ],
                      ))
          ],
        ),
      ),
    );
  }

  // 暂时没数据
  Widget get errorView {
    return const Text("暂时没数据");
  }

  otherView() {
    return CustomScrollView(slivers: <Widget>[
      Consumer<ChuKuanModel>(
        builder: (context, value, child) {
          return value.list.isNotEmpty
              ? SliverList(
                  delegate: SliverChildBuilderDelegate((c, i) {
                  return showRowCell(value.list.isEmpty ? null : value.list[i]);
                }, childCount: value.list.length))
              : SliverPadding(
                  padding: EdgeInsets.only(top: 200.w),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.center,
                      child: errorView,
                    ),
                  ),
                );
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '出款',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // 时间
            DateTimePicker(
              // key: widget.key,
              startDate: startDate,
              endDate: endDate,
              onFinish: (s, e) {
                chukuan_model.startDate = s;
                chukuan_model.endDate = e;
                chukuan_model.debounceRefresh();
              },
            ),
            // 列表
            Expanded(
                child: RefreshConfiguration.copyAncestor(
              footerTriggerDistance: 1000,
              maxUnderScrollExtent: 30,
              enableLoadingWhenNoData: true,
              context: context,
              child: SmartRefresher(
                controller: chukuan_model.refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: chukuan_model.loadInit,
                onLoading: chukuan_model.loadMore,
                child: otherView(),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: Provider.of<RootSceneModel>(context).currentPage ==
              RootScenePage.ChuKuan
          ? FloatingActionButton(
              onPressed: () async {
                if (confMgr.google_key.isEmpty) {
                  eventBus.emit(EventEnums.showGoogleDialog);
                } else {
                  await showInformationDialog(context);
                }
              },
              backgroundColor: mainColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24.0,
              ),
            )
          : null,
    );
  }
}
