import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/manager/data/tongji_data.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/datetime_format.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';
import 'package:bobi_pay_out/view_model/tongji_model.dart';
import 'package:bobi_pay_out/widgets/date_time_picker.dart';
import 'package:bobi_pay_out/widgets/sizebox_icon_button.dart';

class TongJiPage extends StatefulWidget {
  const TongJiPage({Key? key}) : super(key: key);

  @override
  State<TongJiPage> createState() => _TongJiPageState();
}

class _TongJiPageState extends State<TongJiPage> {
  late TongjiModel _tongjiModel;

  @override
  void initState() {
    _tongjiModel = Provider.of<TongjiModel>(context, listen: false);
    super.initState();
  }

  onSelectedList(BuildContext context, String str) {
    Routes.navigateTo(context, Routes.tongjiDetail, params: {
      "bao_ming": str,
      "startDate": _tongjiModel.startDate?.microsecondsSinceEpoch.toString(),
      "endDate": _tongjiModel.endDate?.microsecondsSinceEpoch.toString()
    });
  }

  //当前每行显示数组
  showRowCell(BuildContext context, dd) {
    if (dd == null) return const SizedBox.shrink();
    final data = TongjiData.fromJson(dd);
    return InkWell(
      onTap: () => onSelectedList(context, data.booksName!),
      child: Container(
        margin:
            EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
        height: 130.w,
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
        child: Column(children: [
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
                            fontWeight: FontWeight.bold,
                            fontSize: 12.w,
                            color: mainColor),
                      ),
                    ),
                  ],
                ),
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
                      '包名：',
                      style: TextStyle(fontSize: 12.w),
                    ),
                    Expanded(
                      child: Text(
                        (data.booksName ?? '').toString(),
                        maxLines: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.w,
                            color: mainColor),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizeBoxIconButton(
                    onPressed: () async {
                      await _tongjiModel.debounceRefresh();
                    },
                  ),
                  Text(
                    DateTimeFormat.toLong(data.updateTime! * 1000),
                    style: TextStyle(fontSize: 12.w),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 地址数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            '地址数:  ',
                            style: TextStyle(fontSize: 12.w),
                          ),
                        ),
                        Text(
                          (data.addrNum ?? '').toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.w,
                              color: mainColor),
                        ),
                      ],
                    ),

                    // 入款/笔
                    SizedBox(
                      height: 2.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            '入款/笔: ',
                            style: TextStyle(fontSize: 12.w),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            (data.rukuanB ?? '').toString(),
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.w,
                                color: mainColor),
                          ),
                        )
                      ],
                    ),

                    // 出款/笔
                    SizedBox(
                      height: 2.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            '出款/笔: ',
                            style: TextStyle(fontSize: 12.w),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            (data.chukuanB ?? '').toString(),
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.w,
                                color: mainColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.w, bottom: 10.w),
                height: 40.w,
                decoration: BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 1.w, color: mainColor))),
              ),

              // 余额
              SizedBox(
                width: 100.w,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          '余额',
                          style: TextStyle(fontSize: 12.w),
                        ),
                      ),
                      Center(
                        child: Text(
                          (data.amout ?? 0).toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.w,
                              color: mainColor),
                        ),
                      )
                    ]),
              )
            ],
          )
        ]),
      ),
    );
  }

  // 暂时没数据
  Widget get errorView {
    return const Text("暂时没数据");
  }

  otherView() {
    return CustomScrollView(slivers: <Widget>[
      Consumer<TongjiModel>(
        builder: (context, value, child) {
          return value.list.isNotEmpty
              ? SliverList(
                  delegate: SliverChildBuilderDelegate((c, i) {
                  return showRowCell(
                      context, value.list.isEmpty ? null : value.list[i]);
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
          '统计',
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
            startDate: _tongjiModel.startDate,
            endDate: _tongjiModel.endDate,
            onFinish: (s, e) {
              _tongjiModel.startDate = s;
              _tongjiModel.endDate = e;
              _tongjiModel.debounceRefresh();
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
                  controller: _tongjiModel.refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: _tongjiModel.loadInit,
                  onLoading: _tongjiModel.loadMore,
                  child: otherView(),
                )),
          ),
        ],
      ),
    );
  }
}
