import 'package:bobi_pay_out/manager/guiji_mgr.dart';
import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/utils/utility.dart';

class GuiJiModel extends ViewStateRefreshListModel {
  bool _canClean = false;

  // 开始时间
  DateTime? startDate;

  // 结束时间
  DateTime? endDate;

  GuiJiModel() {
    guiJiMgr;
    loadInit();
  }

  /// 上拉加载更多
  @override
  Future<List<dynamic>?> loadInit() async {
    // _canUpdate = !_canUpdate;
    _canClean = true;
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

  @override
  Future<List<dynamic>> loadData({int? pageNum}) async {
    if (_canClean) {
      _canClean = false;
      list = [];
      currentPageNum = 1;
      pageNum = 1;
    }

    final beginTime = getTime(startDate);
    final endTime = getTime(endDate, isEnd: true);

    final result = await serviceVossTj.get_collection_task_list(
        page: pageNum, page_size: 20, begin_time: beginTime, end_time: endTime);
    return result ?? [];
  }

  @override
  void dispose() {
    list.clear();
    super.dispose();
  }
}
