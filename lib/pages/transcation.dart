// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/manager/data/transcation_log_data.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/transcation_model.dart';
import 'package:bobi_pay_out/widgets/date_time_picker.dart';
import 'package:bobi_pay_out/widgets/sizebox_icon_button.dart';

class TranscationPage extends StatefulWidget {
  const TranscationPage({Key? key}) : super(key: key);

  @override
  State<TranscationPage> createState() => _TranscationPageState();
}

class _TranscationPageState extends State<TranscationPage> {
  late TranscationModel _transcationLogModel;

  @override
  void initState() {
    _transcationLogModel =
        Provider.of<TranscationModel>(context, listen: false);
    super.initState();
  }

  onSelectedList(BuildContext context, String str) {
    Routes.navigateTo(context, Routes.tongjiDetail, params: {
      "bao_ming": str,
      "startDate":
          _transcationLogModel.startDate?.microsecondsSinceEpoch.toString(),
      "endDate": _transcationLogModel.endDate?.microsecondsSinceEpoch.toString()
    });
  }

  String get_transfer_status(String status) {
    return COLLECTION_LIST[status] ?? '';
  }

  //当前每行显示数组
  showRowCell(dd) {
    if (dd == null) return const SizedBox.shrink();
    final data = dd as TranscationLogData;
    return Container(
      margin: EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
      padding: EdgeInsets.all(8.w),
      height: 250.w,
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
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
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
                        "出款金额：",
                        style: TextStyle(fontSize: 12.w),
                      ),
                      Expanded(
                          child: Text(
                        "-${data.usdtVal ?? '-'}",
                        maxLines: 3,
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

            // 出款包名:
            Row(
              children: [
                Text("钱包类型：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.walletType ?? '').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("出款包名：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.fromBagName ?? '').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
              ],
            ),
            // 付款钱包:
            Row(
              children: [
                Text("付款钱包：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.fromAddr ?? '').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                (data.fromAddr == null || data.fromAddr!.isEmpty)
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          copyStr((data.fromAddr ?? '').toString());
                          showToastTip(
                              "复制成功:${(data.fromAddr ?? '').toString()}");
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

            // 收款钱包:
            Row(
              children: [
                Text("收款钱包：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.toAddr ?? '-').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                (data.toAddr == null || data.toAddr!.isEmpty)
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
            // 交易id
            Row(
              children: [
                Text("交易单号：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data.transactionId ?? '-').toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                (data.transactionId == null || data.transactionId!.isEmpty)
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          copyStr((data.transactionId ?? '').toString());
                          showToastTip(
                              "复制成功:${(data.transactionId ?? '').toString()}");
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
            // 状态
            Row(
              children: [
                Text("交易状态：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    get_transfer_status(data.status.toString()),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                SizeBoxIconButton(
                  onPressed: () async {
                    await _transcationLogModel.debounceRefresh();
                  },
                ),
              ],
            ),
            data.remark == null || data.remark!.isEmpty
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Text("描述：", style: TextStyle(fontSize: 12.w)),
                      Expanded(
                        child: Text(
                          data.remark ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 12.w,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        ),
                      )
                    ],
                  )
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
      Consumer<TranscationModel>(
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
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '记录',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        backgroundColor: mainColor,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 时间
          DateTimePicker(
            key: widget.key,
            startDate: _transcationLogModel.startDate,
            endDate: _transcationLogModel.endDate,
            onFinish: (s, e) {
              _transcationLogModel.startDate = s;
              _transcationLogModel.endDate = e;
              _transcationLogModel.debounceRefresh();
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
                  controller: _transcationLogModel.refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: _transcationLogModel.loadInit,
                  onLoading: _transcationLogModel.loadMore,
                  child: otherView(),
                )),
          ),
        ],
      ),
    );
  }
}
