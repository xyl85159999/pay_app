

import 'package:flutter_tron_api/eth_global.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' show Client;

class EthGrpcClient {
  static Map<String, ClientChannelManagerObject> clientChannels = Map();
  // 连接上限数
  static int maxChannelNumber = 10;
  // 优先级最低的key
  static String exitKey = '';

  static Web3Client getChannel() {
    String rpcUrl = ethGlobal.ethRpc;
    //连接存在 取缓存 不存在则创建
    if (clientChannels.containsKey(rpcUrl)) {
      //每取一次请求数量加1
      clientChannels[rpcUrl]!.number =
          clientChannels[rpcUrl]!.number! + 1;
      Future(() {
        sort();
      });
      return clientChannels[rpcUrl]!.clientChannel!;
    } else {
      return createChannel(rpcUrl);
    }
  }

  static Web3Client createChannel(String rpcUrl) {
    //如果超过连接上限数
    if (clientChannels.length >= maxChannelNumber) {
      ClientChannelManagerObject object = clientChannels[exitKey]!;
      object.httpClient!.close(); // 关闭优先级最低的连接
      object.clientChannel!.dispose(); // 关闭优先级最低的连接
      clientChannels.remove(exitKey); // 清出连接池
    }
    Client httpClient = Client();
    Web3Client channel = new Web3Client(rpcUrl,httpClient);
    clientChannels[rpcUrl] = ClientChannelManagerObject()
      ..clientChannel = channel
      ..httpClient = httpClient
      ..number = 1
      ..createTime = new DateTime.now().millisecondsSinceEpoch;
    Future(() {
      sort();
    });
    return channel;
  }

  static void sort() {
    // 计算优先级
    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    double maxProportion = 0.0;
    clientChannels.forEach((String key, ClientChannelManagerObject value) {
      value.proportion = (currentTime - value.createTime!) /
          (value.number! * 1.0); //时长除以次数，越小优先级越高
      if (value.proportion! > maxProportion) {
        maxProportion = value.proportion!;
        exitKey = key;
      }
    });
  }
}

class ClientChannelManagerObject {
  Web3Client? clientChannel;
  Client? httpClient;
  int? number; //总共请求次数
  int? createTime; //第一次创建时间
  double? proportion; //时长除以次数，越小优先级越高
}
