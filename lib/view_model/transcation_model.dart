import 'package:bobi_pay_out/manager/pay_out_mgr.dart';
import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';

class TranscationModel extends ViewStateRefreshListModel {
  bool _canClean = false;
  // 开始时间
  DateTime? startDate;

  // 结束时间
  DateTime? endDate;

  /// 上拉加载更多
  @override
  Future<List<dynamic>?> loadInit() async {
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
    return payOutMgr.getTodayData();
    // return await transactionMgr.get_transaction_log_list(pageNum ?? 1, 20,
    //     begin_time: getTime(startDate),
    //     end_time: getTime(endDate, isEnd: true));
  }
}
