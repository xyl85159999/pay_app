// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/manager/data/tongji_detail_data.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/tongji_detail_model.dart';
import 'package:bobi_pay_out/widgets/date_time_picker.dart';

class TongJiDetailPage extends StatefulWidget {
  String baoMing;
  DateTime? startDate;
  DateTime? endDate;
  TongJiDetailPage(this.baoMing, {this.startDate, this.endDate, Key? key})
      : super(key: key);

  @override
  State<TongJiDetailPage> createState() => _TongJiDetailPageState();
}

class _TongJiDetailPageState extends State<TongJiDetailPage> {
  late TongjiDetailModel _tongjiDetailModel;
  @override
  void initState() {
    _tongjiDetailModel = Provider.of<TongjiDetailModel>(context, listen: false);
    _tongjiDetailModel.bagName = widget.baoMing;
    _tongjiDetailModel.startDate = widget.startDate;
    _tongjiDetailModel.endDate = widget.endDate;
    _tongjiDetailModel.debounceRefresh();

    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  //当前每行显示数组
  showRowCell(dd) {
    if (dd == null) return const SizedBox.shrink();
    final data = TongjiDetailData.fromJson(dd);
    final isChuKuan = data.chukuan != 0;
    return Container(
        margin:
            EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
        height: 180.w,
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
                          isChuKuan ? "出款金额：" : "入款金额：",
                          style: TextStyle(fontSize: 12.w),
                        ),
                        Expanded(
                            child: Text(
                          isChuKuan
                              ? "-${data.chukuan ?? '-'}"
                              : "+${data.rukuan ?? '-'}",
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
                          (data.walletType ?? '-').toString(),
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

              // 出款地址：
              Row(
                children: [
                  Text(
                    "出款地址：",
                    style: TextStyle(fontSize: 12.w),
                  ),
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
                                border:
                                    Border.all(color: mainColor, width: 1.w),
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

              // 入款地址：
              Row(
                children: [
                  Text(
                    "入款地址：",
                    style: TextStyle(fontSize: 12.w),
                  ),
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
                                border:
                                    Border.all(color: mainColor, width: 1.w),
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
              // 交易id：
              Row(
                children: [
                  Text(
                    "交易单号：",
                    style: TextStyle(fontSize: 12.w),
                  ),
                  Expanded(
                    child: Text(
                      (data.transactionId ?? '').toString(),
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
                                border:
                                    Border.all(color: mainColor, width: 1.w),
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
            ],
          ),
        ));
  }

  // 暂时没数据
  Widget get errorView {
    return const Text("暂时没数据");
  }

  otherView() {
    return CustomScrollView(slivers: <Widget>[
      Consumer<TongjiDetailModel>(
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
          '统计详情',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        leading: const BackButton(color: Colors.white),
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
              startDate: widget.startDate,
              endDate: widget.endDate,
              onFinish: (s, e) {
                _tongjiDetailModel.startDate = s;
                _tongjiDetailModel.endDate = e;
                _tongjiDetailModel.debounceRefresh();
              },
            ),

            Expanded(
              child: RefreshConfiguration.copyAncestor(
                  footerTriggerDistance: 1000,
                  maxUnderScrollExtent: 30,
                  enableLoadingWhenNoData: true,
                  context: context,
                  child: SmartRefresher(
                    controller: _tongjiDetailModel.refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: _tongjiDetailModel.loadInit,
                    onLoading: _tongjiDetailModel.loadMore,
                    child: otherView(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
