import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/event_bus.dart';
import 'package:bobi_pay_out/utils/string.dart';

import 'view_state_list_model.dart';

/// 基于
abstract class ViewStateRefreshListModel<T> extends ViewStateListModel<T> {
  /// 分页第一页页码
  static const int pageNumFirst = 1;

  /// 分页条目数量
  static const int pageSize = 20;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  /// 当前页码
  int _currentPageNum = pageNumFirst;

  int get currentPageNum => _currentPageNum;
  set currentPageNum(int? val) {
    _currentPageNum = val!;
  }

  ViewStateRefreshListModel() {
    eventBus.on(EventEnums.appInitData, (arg) async {
      await initData();
    });
  }

  /// 下拉刷新
  ///
  /// [init] 是否是第一次加载
  /// true:  Error时,需要跳转页面
  /// false: Error时,不需要跳转页面,直接给出提示
  @override
  Future<List<T>?> refresh({bool init = false}) async {
    try {
      if (_currentPageNum > 1) {
        _currentPageNum--;
      } else {
        _currentPageNum = pageNumFirst;
      }
      var data = await loadData(pageNum: _currentPageNum);
      if (data.isEmpty) {
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        // 小于分页的数量,禁止上拉加载更多
        if (data.length < pageSize) {
          refreshController.loadNoData();
        } else {
          //防止上次上拉加载更多失败,需要重置状态
          refreshController.loadComplete();
        }
        setIdle();
      }
      return data;
    } catch (e, s) {
      /// 页面已经加载了数据,如果刷新报错,不应该直接跳转错误页面
      /// 而是显示之前的页面数据.给出错误提示
      if (init) list.clear();
      refreshController.refreshFailed();
      setError(e, s);
      return null;
    }
  }

  /// 上拉加载更多
  Future<List<dynamic>?> loadInit() async {
    try {
      var data = await refresh(init: false);
      if (data != null && data.isEmpty) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
      return data;
    } catch (e) {
      refreshController.loadNoData();
      return null;
    }
  }

  /// 上拉加载更多
  Future<List<T>?> loadMore() async {
    try {
      var data = await loadData(pageNum: ++_currentPageNum);
      if (data.isEmpty) {
        _currentPageNum--;
        refreshController.loadNoData();
      } else {
        onCompleted(data);
        list.addAll(data);
        if (data.length < pageSize) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
        notifyListeners();
      }
      return data;
    } catch (e, s) {
      _currentPageNum--;
      refreshController.loadNoData();
      mypdebug('error--->\n$e');
      mypdebug('statck--->\n$s');
      return null;
    }
  }

  // 加载数据
  @override
  Future<List<T>> loadData({int? pageNum});

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}
