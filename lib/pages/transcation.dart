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
import 'package:scalable_data_table/scalable_data_table.dart';

import '../manager/data/pay_out_task.dart';
import '../manager/pay_out_mgr.dart';

class TranscationPage extends StatefulWidget {
  const TranscationPage({Key? key}) : super(key: key);

  @override
  State<TranscationPage> createState() => _TranscationPageState();
}

class _TranscationPageState extends State<TranscationPage> {
  late TranscationModel _transcationLogModel;

  final RefreshController refreshController = RefreshController(initialRefresh: false);

  List<PayOutTask> payoutTaskList = [];

  @override
  void initState() {
    super.initState();
    _transcationLogModel = Provider.of<TranscationModel>(context, listen: false);
    _transcationLogModel.startDate = DateTime.now();
    _transcationLogModel.endDate = DateTime.now();
    _transcationLogModel.loadData();
  }

  onSelectedList(BuildContext context, String str) {
    Routes.navigateTo(context, Routes.tongjiDetail, params: {
      "bao_ming": str,
      "startDate": _transcationLogModel.startDate?.microsecondsSinceEpoch.toString(),
      "endDate": _transcationLogModel.endDate?.microsecondsSinceEpoch.toString()
    });
  }

  String get_transfer_status(String status) {
    return COLLECTION_LIST[status] ?? '';
  }

  //当前每行显示数组
  showRowCell(dd) {
    if (dd == null) return const SizedBox.shrink();
    final data = dd as PayOutTask;
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
                        "-${data.amount ?? '-'}",
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
                    (data.taskId ?? '').toString(),
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
                    (data.status ?? '').toString(),
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
                (data.fromAddr!.isEmpty)
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
                (data.transactionId!.isEmpty)
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
            data.remark!.isEmpty
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
    return Consumer<TranscationModel>(
      builder: (context, value, child) {
        return value.list.isNotEmpty
            ? _tableView(value.list)
            : Container();
      },
    );
  }
  
  _tableView(List<dynamic> list){
    return ScalableDataTable(
      header: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
        ),
        child: ScalableTableHeader(
          columnWrapper: columnWrapper,
          children: const [
            Text('任务ID'),
            Text('状态'),
            Text('类型'),
            Text('出款地址'),
            Text('首款地址'),
            Text('金额'),
            Text('交易ID'),
            Text('备注'),
            Text('更新时间'),
            Text('创建时间'),
          ],
        ),
      ),
      rowBuilder: (context, index) {
        final PayOutTask task = list[index] as PayOutTask;
        return ScalableTableRow(
          columnWrapper: columnWrapper,
          color: MaterialStateColor.resolveWith((states) =>
          (index % 2 == 0) ? Colors.grey[200]! : Colors.transparent),
          children: [
            Text('${task.taskId}'),
            Text(task.status.name),
            Text(task.walletType),
            Text(task.fromAddr),
            Text(task.toAddr),
            Text('${task.amount}'),
            Text(task.transactionId),
            Text(task.remark),
            Text('${task.updateTime}'),
            Text('${task.createTime}'),
          ],
        );
      },
      emptyBuilder: (context) => const Text('No users yet...'),
      itemCount: list.length,
      minWidth: 1300, // max(MediaQuery.of(context).size.width, 1000),
      textStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
    );
  }

  Widget columnWrapper(BuildContext context, int columnIndex, Widget child) {
    const padding = EdgeInsets.symmetric(horizontal: 10);
    switch (columnIndex) {
      case 0:
        return Container(
          width: 70,
          padding: padding,
          child: child,
        );
      case 1:
      case 2:
        return Container(
          width: 60,
          padding: padding,
          child: child,
        );
      case 3:
      case 4:
      case 6:
        return Container(
          width: 200,
          padding: padding,
          child: child,
        );
      case 5:
        return Container(
          width: 120,
          padding: padding,
          child: child,
        );
      default:
        return Expanded(
          child: Container(
            padding: padding,
            child: child,
          ),
        );
    }
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
