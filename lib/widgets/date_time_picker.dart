// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';

import '../manager/pay_out_mgr.dart';

class DateTimePicker extends StatefulWidget {
  DateTime? startDate;
  DateTime? endDate;
  Function(DateTime?, DateTime?)? onFinish;
  DateTimePicker({
    Key? key,
    this.startDate,
    this.endDate,
    this.onFinish,
  }) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Tab>? _tabs;

  Color btnColor1 = mainColor;
  Color btnColor2 = Colors.white;
  Color btnColor3 = Colors.transparent;

  Color textColor1 = Colors.white;
  Color textColor2 = mainColor;
  Color textColor3 = Colors.grey;

  bool enableBtn2 = true;
  bool enableBtn3 = false;
  bool enableClearBtn = true;

  // 显示日期
  String _displayDate = '';
  setDisplayDate() {
    if (widget.startDate == null || widget.endDate == null) {
      enableClearBtn = false;
      _displayDate = '全部';
    } else {
      enableClearBtn = true;
      var st = DateTimeFormat.toShort(widget.startDate!.millisecondsSinceEpoch);
      var dt = DateTimeFormat.toShort(widget.endDate!.millisecondsSinceEpoch);
      _displayDate = "$st-$dt";
    }
  }

  @override
  void initState() {
    super.initState();

    setDisplayDate();
    updateBtnStatus(widget.startDate, widget.endDate, isReset: true);
    _tabController = TabController(vsync: this, length: 2);
    _tabs = [const Tab(text: "开始时间"), const Tab(text: "结束时间")];
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // 更新
  void _refresh() {
    if (mounted) {
      setState(() {
        setDisplayDate();
        if (widget.onFinish != null) {
          widget.onFinish!(widget.startDate, widget.endDate);
        }
      });
    }
  }

  // 点击今日
  void onSelectOne() {
    var d = DateTime.now();
    btnColor1 = mainColor;
    btnColor2 = Colors.white;
    btnColor3 = Colors.transparent;

    textColor1 = Colors.white;
    textColor2 = mainColor;
    textColor3 = Colors.grey;

    enableBtn3 = false;
    enableBtn2 = true;

    widget.startDate = d;
    widget.endDate = d;

    payOutMgr.getPreviousDayData();
    _refresh();
  }

  // 点击上一日
  void onSelectTow() {
    if (!enableBtn2) return;
    var d = widget.startDate!.subtract(const Duration(days: 1));

    btnColor1 = Colors.white;
    btnColor2 = mainColor;
    btnColor3 = Colors.white;

    textColor1 = mainColor;
    textColor2 = Colors.white;
    textColor3 = mainColor;

    enableBtn3 = true;

    widget.startDate = d;
    widget.endDate = d;

    payOutMgr.getNextDayData();
    _refresh();
  }

  // 点击下一日
  void onSelectThree() {
    if (!enableBtn3) return;

    btnColor1 = Colors.white;
    btnColor2 = Colors.white;
    btnColor3 = mainColor;

    textColor1 = mainColor;
    textColor2 = mainColor;
    textColor3 = Colors.white;

    var d = widget.endDate!.add(const Duration(days: 1));
    widget.startDate = d;
    widget.endDate = d;
    updateBtnStatus(widget.startDate!, widget.endDate!);
    _refresh();
  }

  // isReset 状态重置
  void updateBtnStatus(DateTime? start, DateTime? end, {bool isReset = false}) {
    if (isReset) {
      btnColor1 = Colors.white;
      btnColor2 = Colors.white;
      btnColor3 = Colors.white;

      textColor1 = mainColor;
      textColor2 = mainColor;
      textColor3 = mainColor;
    }
    final bool isNull = start == null || end == null;
    if (isNull) {
      btnColor2 = btnColor3 = Colors.transparent;
      textColor2 = textColor3 = Colors.grey;
      enableBtn2 = enableBtn3 = false;
      return;
    }
    DateTime now = DateTime.now();
    // 是否是同一天
    bool istoday = end.difference(now).inDays == 0;
    enableBtn3 = !istoday;
    enableBtn2 = true;
    if (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch == 0 &&
        istoday) {
      btnColor1 = mainColor;
      btnColor2 = Colors.white;
      btnColor3 = Colors.transparent;

      textColor1 = Colors.white;
      textColor2 = mainColor;
      textColor3 = Colors.grey;
    }
  }

  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.55,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                title: TabBar(
                  controller: _tabController,
                  tabs: _tabs!,
                  labelColor: mainColor,
                  indicatorColor: mainColor,
                ),
              ),
              body: Stack(
                children: <Widget>[
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: _tabController,
                      children: _tabs!.map((Tab tab) {
                        return CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          use24hFormat: true,
                          initialDateTime: DateTime.now(),
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            if (tab.text == _tabs?.first.text) {
                              widget.startDate = newDateTime;
                            } else {
                              widget.endDate = newDateTime;
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(right: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Routes.popPage(context);
                          },
                          child: const Text("取消"),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Routes.popPage(context);
                            DateTime now = DateTime.now();
                            widget.startDate ??= now;
                            widget.endDate ??= now;
                            if (widget.endDate!.isBefore(widget.startDate!)) {
                              widget.endDate = widget.startDate;
                            }
                            updateBtnStatus(widget.startDate, widget.endDate,
                                isReset: true);
                            _refresh();
                          },
                          child: const Text("确认"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  //清理按钮
  clearButton() {
    return InkWell(
      onTap: () {
        widget.startDate = null;
        widget.endDate = null;
        updateBtnStatus(widget.startDate, widget.endDate, isReset: true);
        _refresh();
      },
      child: Container(
        height: 20.w,
        width: 20.w,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.w),
            borderRadius: BorderRadius.circular(10.w)),
        child: Center(
          child: Icon(
            Icons.clear,
            size: 12.w,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 10.w, bottom: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Row(children: [
              Text(
                "时间：",
                style: TextStyle(fontSize: 12.w),
              ),
              // 寻查时间
              InkWell(
                onTap: () => _showDatePicker(context),
                child: Container(
                  height: 20.w,
                  width: 120.w,
                  alignment: Alignment.center,
                  child: Text(
                    _displayDate,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.w),
                  ),
                ),
              ),
              // clear button
              enableClearBtn ? clearButton() : const SizedBox.shrink(),
            ]),
          ),

          // 按钮
          Row(
            children: [
              InkWell(
                onTap: onSelectOne,
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 45.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      border: Border.all(color: mainColor, width: 1.w),
                      color: btnColor1,
                      borderRadius: BorderRadius.circular(6.w)),
                  child: Center(
                    child: Text(
                      '今日',
                      style: TextStyle(color: textColor1, fontSize: 12.w),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onSelectTow,
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 55.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              enableBtn2 ? mainColor : const Color(0xffdcdee2),
                          width: 1.w),
                      color: enableBtn2 ? btnColor2 : const Color(0xfff7f7f7),
                      borderRadius: BorderRadius.circular(6.w)),
                  child: Center(
                    child: Text(
                      '上一日',
                      style: TextStyle(color: textColor2, fontSize: 12.w),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onSelectThree,
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 55.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              enableBtn3 ? mainColor : const Color(0xffdcdee2),
                          width: 1.w),
                      color: enableBtn3 ? btnColor3 : const Color(0xfff7f7f7),
                      borderRadius: BorderRadius.circular(6.w)),
                  child: Center(
                    child: Text(
                      '下一日',
                      style: TextStyle(color: textColor3, fontSize: 12.w),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
