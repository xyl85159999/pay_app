//最近浏览
import 'package:bobi_pay_out/provider/view_state_refresh_list_model.dart';

class RecentModel extends ViewStateRefreshListModel {
  RecentModel() {
    init();
  }

  @override
  Future<List<dynamic>> loadData({int? pageNum}) async {
    var result = [];
    filterInfo();
    return result;
  }

  /// 增加对象更新监听及从硬盘load取数据
  init() {}

  /// 增加配置数组
  addValues(List _) {
    filterInfo();
  }

  //根据传入的数据排序以及去掉已经过期的数据
  filterInfo() async {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
