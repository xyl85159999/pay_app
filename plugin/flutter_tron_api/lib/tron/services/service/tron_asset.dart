// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:bs58check/bs58check.dart';
// import 'package:flutter_tron_api/tron/entity/tron/abi_entity.dart';
// import 'package:flutter_tron_api/tron/entity/tron/asset_entity.dart';
// import 'package:flutter_tron_api/tron/services/api/api.pbgrpc.dart';
// import 'package:flutter_tron_api/tron/services/core/Contract.pb.dart' as Contract;
// import 'package:flutter_tron_api/tron/services/core/SmartContract.pb.dart';
// import 'package:flutter_tron_api/tron/services/core/Tron.pb.dart';
// import 'package:flutter_tron_api/tron/services/grpc/grpc_client.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:web3dart/crypto.dart';
// import 'package:flutter_tron_api/tron/eth/abi.dart' as abi;
//
// class TronAsset {
//   Future<bool> getAsset(BuildContext context, String userAddress,
//       List<TokenRows> tokenList) async {
//     //print('TronAsset getAsset');
//     String tronGrpcIP = GlobalService.to.tronGrpcIP;
//     List<AssetEntity> list = [];
//     final channel = ClientChannelManager.getChannel(tronGrpcIP);
//     final stub = WalletClient(channel);
//     Uint8List originAddress = base58.decode(userAddress).sublist(0, 21);
//     try {
//       Account response =
//           await stub.getAccount(Account()..address = originAddress);
//       //print('getAsset response:\n ${response.toProto3Json().toString()}');
//       for (int i = 0; i < tokenList.length; i++) {
//         if (tokenList[i].tokenType == 1) {
//           AssetEntity trxEntity =
//               TronAsset().getTrxBalance(response, userAddress, tokenList[i]);
//           list.add(trxEntity);
//         } else if (tokenList[i].tokenType == 2) {
//           AssetEntity trc20Balance = await TronAsset()
//               .getTrc20Balance(stub, userAddress, tokenList[i]);
//           list.add(trc20Balance);
//         }
//       }
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }
//
//   AssetEntity getTrxBalance(
//       Account response, String userAddress, TokenRows item) {
//     AssetEntity entity = AssetEntity(
//       type: 1,
//       address: item.tokenAddress,
//       name: item.tokenShort,
//       precision: item.tokenPrecision,
//       balance: 0,
//       usd: 0,
//       logoUrl: item.logoUrl,
//       originBalance: '0',
//     );
//     if (response != null && response.balance != null) {
//       double trxBalance =
//           response.balance.toDouble() / getPrecision(item.tokenPrecision);
//       entity.balance = trxBalance;
//       entity.usd = trxBalance * item.priceUsd;
//       entity.originBalance = response.balance.toString();
//     }
//     return entity;
//   }
//
//   Future<AssetEntity> getTrc20Balance(
//       WalletClient stub, String userAddress, TokenRows item) async {
//     AssetEntity entity = AssetEntity(
//       type: 2,
//       address: item.tokenAddress,
//       name: item.tokenShort,
//       precision: item.tokenPrecision,
//       balance: 0,
//       usd: 0,
//       logoUrl: item.logoUrl,
//       originBalance: '0',
//     );
//     try {
//       SmartContract response = await stub.getContract(BytesMessage()
//         ..value = base58.decode(item.tokenAddress).sublist(0, 21));
//       String abiCode = jsonEncode(response.abi.toProto3Json()).substring(10);
//       abiCode = abiCode.substring(0, abiCode.length - 1);
//
//       String abiUserAddress = getAbiTronAddress(userAddress);
//       String functionName = 'balanceOf';
//
//       AbiEntity abiEntity = AbiEntity.fromJson(
//           response.abi.toProto3Json() as Map<String, dynamic>);
//       List<String> inputList = [];
//       if (abiEntity != null && abiEntity.entrys != null) {
//         for (Entrys item in abiEntity.entrys) {
//           if (functionName == item.name) {
//             if (item.inputs != null) {
//               for (Inputs input in item.inputs) {
//                 inputList.add(input.type);
//               }
//             }
//           }
//         }
//       }
//       Uint8List methodID = abi.methodID(functionName, inputList);
//       Uint8List rawEncode = abi.rawEncode(inputList, [abiUserAddress]);
//       Uint8List dataList =
//           hexToBytes(bytesToHex(methodID) + bytesToHex(rawEncode));
//
//       Contract.TriggerSmartContract req = Contract.TriggerSmartContract();
//       req.ownerAddress = base58.decode(userAddress).sublist(0, 21);
//       req.contractAddress = base58.decode(item.tokenAddress).sublist(0, 21);
//       req.data = dataList;
//
//       final result = await stub.triggerContract(req);
//       if (result != null &&
//           result.constantResult != null &&
//           result.constantResult.length > 0) {
//         double balance = bytesToInt(result.constantResult[0]).toDouble() /
//             getPrecision(item.tokenPrecision);
//         entity.balance = balance;
//         entity.usd = balance * item.priceUsd;
//         entity.originBalance = bytesToInt(result.constantResult[0]).toString();
//       }
//     } catch (e) {
//       print(e);
//     }
//     return entity;
//   }
//
//   String getAbiTronAddress(String base58Address) {
//     Uint8List address = base58.decode(base58Address).sublist(1, 21);
//     return '0x' + bytesToHex(address);
//   }
//
//   double getPrecision(int precision) {
//     double result = 1;
//     double baseValue = 10;
//     for (int i = 0; i < precision; i++) {
//       result = result * baseValue;
//     }
//     return result;
//   }
// }
