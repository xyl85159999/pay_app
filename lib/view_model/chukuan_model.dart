// ignore_for_file: non_constant_identifier_names

import 'package:bobi_pay_out/manager/chukuan_mgr.dart';
import 'package:bobi_pay_out/manager/data/chu_kuan_data.dart';
import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';
import 'package:bobi_pay_out/utils/utility.dart';

ChuKuanModel chukuan_model = ChuKuanModel();

class ChuKuanModel extends ViewStateRefreshListModel {
  bool _canClean = false;

  // 开始时间
  DateTime? startDate;

  // 结束时间
  DateTime? endDate;

  // 包名
  String? bagName;

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
  Future<List<ChuKuanData>> loadData({int? pageNum}) async {
    if (_canClean) {
      _canClean = false;
      list = [];
      currentPageNum = 1;
      pageNum = 1;
    }

    return await chukuanMgr.get_transfer_task(pageNum ?? 1, 20,
        books_name: bagName,
        begin_time: getTime(startDate),
        end_time: getTime(endDate, isEnd: true));
  }

  @override
  void dispose() {
    list.clear();
    super.dispose();
  }
}
