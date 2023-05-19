import 'package:bobi_pay_out/manager/timer_mgr.dart';
import 'package:bobi_pay_out/service/service_bobi.dart';

final PayOutMgr guiJiMgr = PayOutMgr();

class PayOutMgr extends OnUpdateActor {
  @override
  Future<void> updateTick(int diff) async {
    List res = await serviceBobi.getPayOutTask();
    if (res.isEmpty) return;
  }
}
