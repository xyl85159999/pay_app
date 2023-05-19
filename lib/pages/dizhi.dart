import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/dizhi_bagname_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_model.dart';

class DizhiPage extends StatefulWidget {
  const DizhiPage({Key? key}) : super(key: key);

  @override
  State<DizhiPage> createState() => _DizhiPageState();
}

class _DizhiPageState extends State<DizhiPage> {
  late DiZhiModel _diZhiModel;
  @override
  void initState() {
    _diZhiModel = Provider.of<DiZhiModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedIdx = -1;
  List<Widget> view(List? list, Function(String) onSelected) {
    if (list == null) return [];
    List<Widget> v = [];
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      v.add(
        InkWell(
          onTap: () {
            _selectedIdx = i;
            onSelected(data["books_name"]);
          },
          child: Container(
            margin: EdgeInsets.only(left: 2.w, right: 2.w),
            padding: EdgeInsets.all(5.w),
            height: 30.w,
            decoration: BoxDecoration(
                border: Border.all(color: mainColor, width: 1.w),
                color: _selectedIdx == i ? mainColor : Colors.white,
                borderRadius: BorderRadius.circular(6.w)),
            child: Center(
              child: Text(
                data["books_name"],
                style: TextStyle(
                    color: _selectedIdx == i ? Colors.white : mainColor),
              ),
            ),
          ),
        ),
      );
    }
    return v;
  }

  //当前每行显示数组
  showRowCell(data) {
    return Container(
        margin:
            EdgeInsets.only(left: 20.w, top: 10.w, right: 20.w, bottom: 10.w),
        height: 100.w,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "地址：",
                    style: TextStyle(fontSize: 12.w),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: Text(
                      data["addr"].toString(),
                      maxLines: 3,
                      style: TextStyle(fontSize: 12.w, color: mainColor),
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

              // 出款地址：
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                            "trx余额：${data['trx_balance'].toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 12.w))),
                    Expanded(
                      child: Text(
                          "usdt余额：${data['usdt_balance'].toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 12.w)),
                    )
                  ],
                ),
              )
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
      Consumer<DiZhiModel>(builder: (context, value, child) {
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
      })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiZhiBagNameModel>(
      builder: (context, value, child) {
        return DefaultTabController(
            initialIndex: 0,
            length: value.listBagName.length,
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                tabController.addListener(() {
                  mypdebug("New tab index: ${tabController.index}");
                  if (value.listBagName.isNotEmpty) {
                    _diZhiModel.bagName =
                        value.listBagName[tabController.index]['books_name'];
                    _diZhiModel.debounceRefresh();
                  }
                });
                return Scaffold(
                    appBar: AppBar(
                      backgroundColor: mainColor,
                      title: const Text(
                        '地址',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      centerTitle: true,
                      toolbarHeight: 48,
                    ),
                    body: Column(
                      children: [
                        Builder(builder: ((context) {
                          if (value.listBagName.isNotEmpty) {
                            _diZhiModel.bagName =
                                value.listBagName.first['books_name'];
                            _diZhiModel.debounceRefresh();
                          }
                          return TabBar(
                            isScrollable: true,
                            labelStyle: TextStyle(fontSize: 14.w),
                            labelColor: mainColor,
                            unselectedLabelColor: Colors.grey,
                            tabs: value.listBagName
                                .map((e) => Tab(text: e['books_name']))
                                .toList(),
                          );
                        })),
                        Expanded(
                            child: RefreshConfiguration.copyAncestor(
                                footerTriggerDistance: 1000,
                                maxUnderScrollExtent: 30,
                                enableLoadingWhenNoData: true,
                                context: context,
                                child: SmartRefresher(
                                  controller: _diZhiModel.refreshController,
                                  enablePullDown: true,
                                  enablePullUp: true,
                                  onRefresh: _diZhiModel.loadInit,
                                  onLoading: _diZhiModel.loadMore,
                                  child: otherView(),
                                ))),
                      ],
                    ));
              },
            ));
      },
    );
  }
}
