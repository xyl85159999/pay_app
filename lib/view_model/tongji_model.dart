import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/utils/utility.dart';

class TongjiModel extends ViewStateRefreshListModel {
  bool _canClean = false;

  // 开始时间
  DateTime? startDate;

  // 结束时间
  DateTime? endDate;

  // 包名
  String? baoMing;

  TongjiModel() {
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
  Future<List> loadData({int? pageNum}) async {
    if (_canClean) {
      _canClean = false;
      list = [];
      currentPageNum = 1;
      pageNum = 1;
    }
    return await serviceVossTj.getTransactionLogList(pageNum ?? 1, 20,
        bn: baoMing, bt: getTime(startDate), et: getTime(endDate, isEnd: true));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
