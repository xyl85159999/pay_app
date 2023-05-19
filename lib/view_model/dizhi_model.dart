import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';

class DiZhiModel extends ViewStateRefreshListModel {
  String _conText = '';
  set searchContext(String contexr) {
    _conText = contexr;
  }

  String _bagName = '';
  set bagName(String v) {
    _bagName = v;
  }

  /// 上拉加载更多
  @override
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

  @override
  Future<List<dynamic>> loadData({int? pageNum}) async {
    // return await serviceVossTj.getAddressList(
    //     pageNum ?? 1, 20, _bagName,
    //     key: _conText);
    if (dizhi_bagname_model.listBagName.isEmpty) {
      await dizhi_bagname_model.init();
    }
    if (_bagName.isEmpty) return [];
    return await serviceVossTj.getAddressList(pageNum ?? 1, 20, _bagName,
        key: _conText);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
