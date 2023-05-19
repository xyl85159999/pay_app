// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/guiji_model.dart';
import 'package:bobi_pay_out/widgets/date_time_picker.dart';
import 'package:bobi_pay_out/widgets/sizebox_icon_button.dart';

class GuiJiPage extends StatefulWidget {
  const GuiJiPage({Key? key}) : super(key: key);

  @override
  State<GuiJiPage> createState() => _TongJiPageState();
}

class _TongJiPageState extends State<GuiJiPage> {
  late GuiJiModel _guiJiModel;

  @override
  void initState() {
    _guiJiModel = Provider.of<GuiJiModel>(context, listen: false);
    super.initState();
  }

  String get_collect_status(String status) {
    return COLLECTION_LIST[status] ?? '';
  }

  //当前每行显示数组
  showRowCell(data) {
    if (data == null) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
      padding: EdgeInsets.all(8.w),
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
                        "归集金额：",
                        style: TextStyle(fontSize: 12.w),
                      ),
                      Expanded(
                          child: Text(
                        (data["amount"] ?? '-').toString(),
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ))
                    ],
                  ),
                ),
                Text(
                  DateTimeFormat.toLong(data["update_time"] * 1000),
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
                        (data["wallet_type"] ?? '-').toString(),
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ))
                    ],
                  ),
                ),
              ],
            ),
            // 出款地址:
            Row(
              children: [
                Text("钱包地址：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data["addr"] ?? '').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                InkWell(
                  onTap: () {
                    copyStr(data["addr"].toString());
                    showToastTip("复制成功:${data["addr"].toString()}");
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
                        style: TextStyle(color: Colors.white, fontSize: 12.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 入款地址:
            Row(
              children: [
                Text("归集地址：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    (data["to_addr"] ?? '-').toString(),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                data["to_addr"] == null || data["to_addr"].isEmpty
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          copyStr(data["to_addr"].toString());
                          showToastTip("复制成功:${data["to_addr"].toString()}");
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
                    (data["transaction_id"] ?? '-').toString(),
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                data["transaction_id"] == null || data["transaction_id"].isEmpty
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          copyStr(data["transaction_id"].toString());
                          showToastTip(
                              "复制成功:${data["transaction_id"].toString()}");
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
                Text("归集状态：", style: TextStyle(fontSize: 12.w)),
                Expanded(
                  child: Text(
                    get_collect_status(data["status"].toString()),
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                ),
                SizeBoxIconButton(
                  onPressed: () async {
                    await _guiJiModel.debounceRefresh();
                  },
                ),
              ],
            ),
            data["remark"] == null || data["remark"].isEmpty
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Text("描述：", style: TextStyle(fontSize: 12.w)),
                      Expanded(
                        child: Text(
                          data["remark"] ?? '',
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
      Consumer<GuiJiModel>(
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
          '归集',
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
            startDate: _guiJiModel.startDate,
            endDate: _guiJiModel.endDate,
            onFinish: (s, e) {
              _guiJiModel.startDate = s;
              _guiJiModel.endDate = e;
              _guiJiModel.debounceRefresh();
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
                  controller: _guiJiModel.refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: _guiJiModel.loadInit,
                  onLoading: _guiJiModel.loadMore,
                  child: otherView(),
                )),
          ),
        ],
      ),
      // floatingActionButton: Provider.of<RootSceneModel>(context).currentPage ==
      //         RootScenePage.GuiJi
      //     ? FloatingActionButton(
      //         onPressed: () async {},
      //         backgroundColor: mainColor,
      //         child: Switch(
      //           onChanged: (bool value) {
      //             setState(() {
      //               guiJiMgr.guiji_switch = value;
      //             });
      //           },
      //           value: guiJiMgr.guiji_switch,
      //           activeColor: Colors.green,
      //         ),
      //       )
      //     : null,
    );
  }
}
