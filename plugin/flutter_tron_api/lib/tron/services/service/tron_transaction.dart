import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58check/bs58check.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_tron_api/tron_global.dart';
import 'package:flutter_tron_api/tron/eth/abi.dart' as abi;
import 'package:fixnum/fixnum.dart';
import 'package:flutter_tron_api/tron/entity/tron/abi_entity.dart';
import 'package:flutter_tron_api/tron/services/api/api.pbgrpc.dart';
import 'package:flutter_tron_api/tron/services/core/Contract.pb.dart'
    as Contract;
import 'package:flutter_tron_api/tron/services/core/SmartContract.pb.dart';
import 'package:flutter_tron_api/tron/services/core/Tron.pb.dart';
import 'package:flutter_tron_api/tron/services/grpc/grpc_client.dart';
import 'package:grpc/src/client/http2_channel.dart';
import 'package:protobuf_google/protobuf_google.dart' as protobuf;
import 'package:web3dart/crypto.dart';

import 'msg_signature.dart';

class TronTransaction {
  Future<List<dynamic>?> transTrx(
    String fromAddress,
    String privateKey,
    String toAddress,
    Int64 amount,
  ) async {
    final ClientChannel channel = ClientChannelManager.getChannel();
    final WalletClient stub = WalletClient(channel);
    Uint8List originFromAddress = base58.decode(fromAddress).sublist(0, 21);
    Uint8List originToAddress = base58.decode(toAddress).sublist(0, 21);
    try {
      Contract.TransferContract tc = Contract.TransferContract();
      tc.ownerAddress = originFromAddress;
      tc.toAddress = originToAddress;
      tc.amount = amount * tronGlobal.AMOUNT_SUN;

      TransactionExtention trxResult = await stub.createTransaction2(tc);
      Transaction transaction = trxResult.transaction;
      Transaction_raw rawData = trxResult.transaction.rawData;
      rawData.timestamp = Int64(DateTime.now().toUtc().millisecondsSinceEpoch);
      rawData.expiration = Int64(DateTime.now()
          .toUtc()
          .add(Duration(seconds: 60))
          .millisecondsSinceEpoch);
      Uint8List hash =
          Uint8List.fromList(sha256.convert(rawData.writeToBuffer()).bytes);

      MsgSignature msgSignature = sign(hash, hexToBytes(privateKey));

      TronMsgSignature msgSignature2 = TronMsgSignature(
        intToBytes(msgSignature.r),
        intToBytes(msgSignature.s),
        msgSignature.v,
      );
      Uint8List ms2 = msgSignature2.getSignature();

      transaction.signature.add(ms2);

      String hashStr = bytesToHex(hash);
      return [hashStr, broadcastTransaction, stub, transaction];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<double?> estimateenergy(
    String contractAddress,
    String fromAddress,
    String toAddress,
    double amount,
  ) async {
    final ClientChannel channel = ClientChannelManager.getChannel();
    final WalletClient stub = WalletClient(channel);
    try {
      SmartContract response = await stub.getContract(BytesMessage()
        ..value = base58.decode(contractAddress).sublist(0, 21));
      String abiCode = jsonEncode(response.abi.toProto3Json());

      String functionName = 'transfer';
      AbiEntity abiEntity = AbiEntity.fromJson(json.decode(abiCode));
      List<String> inputList = [];
      if (abiEntity.entrys != null) {
        for (Entrys item in abiEntity.entrys!) {
          if (functionName == item.name) {
            if (item.inputs != null) {
              for (Inputs input in item.inputs!) {
                inputList.add(input.type!);
              }
            }
            break;
          }
        }
      }

      Uint8List methodID = abi.methodID(functionName, inputList);

      String abiToAddress = getAbiTronAddress(toAddress);
      String amoutStr = (amount * tronGlobal.AMOUNT_SUN).toInt().toString();
      Uint8List rawEncode = abi.rawEncode(inputList, [abiToAddress, amoutStr]);
      Uint8List dataList =
          hexToBytes(bytesToHex(methodID) + bytesToHex(rawEncode));

      final Contract.TriggerSmartContract req = Contract.TriggerSmartContract();
      req.ownerAddress = base58.decode(fromAddress).sublist(0, 21);
      req.contractAddress = base58.decode(contractAddress).sublist(0, 21);
      req.callValue = Int64(0);
      req.data = dataList;

      TransactionExtention transactionExtention =
          await stub.triggerConstantContract(req);
      if (transactionExtention.result
              .toProto3Json()
              .toString()
              .contains('true') ==
          true) {
        final double energyUsed = transactionExtention.energyUsed.toDouble();
        return energyUsed * tronGlobal.trx_price / tronGlobal.AMOUNT_SUN;
      } else {
        return tronGlobal.trx_fee_limit * 1.0;
      }
    } catch (e) {
      print(e);
      return tronGlobal.trx_fee_limit * 1.0;
    }
  }

  Future<List<dynamic>?> transTrc20(
      String contractAddress,
      String fromAddress,
      String toAddress,
      double amount,
      String privateKey,
      double? trxBalance) async {
    final double? energyUsed =
        await estimateenergy(contractAddress, fromAddress, toAddress, amount);
    if (energyUsed == null) {
      return [false, 'triggerConstantContract result is false'];
    }

    final double max_energy_used = energyUsed;
    if (trxBalance == null || trxBalance < max_energy_used) {
      return [true, '消耗能量上限不足 最低需要 $max_energy_used trx'];
    }

    final ClientChannel channel = ClientChannelManager.getChannel();
    final WalletClient stub = WalletClient(channel);
    try {
      SmartContract response = await stub.getContract(BytesMessage()
        ..value = base58.decode(contractAddress).sublist(0, 21));
      String abiCode = jsonEncode(response.abi.toProto3Json());

      String functionName = 'transfer';
      AbiEntity abiEntity = AbiEntity.fromJson(json.decode(abiCode));
      List<String> inputList = [];
      if (abiEntity.entrys != null) {
        for (Entrys item in abiEntity.entrys!) {
          if (functionName == item.name) {
            if (item.inputs != null) {
              for (Inputs input in item.inputs!) {
                inputList.add(input.type!);
              }
            }
            break;
          }
        }
      }

      Uint8List methodID = abi.methodID(functionName, inputList);

      String abiToAddress = getAbiTronAddress(toAddress);
      String amoutStr = (amount * tronGlobal.AMOUNT_SUN).toInt().toString();
      Uint8List rawEncode = abi.rawEncode(inputList, [abiToAddress, amoutStr]);
      Uint8List dataList =
          hexToBytes(bytesToHex(methodID) + bytesToHex(rawEncode));

      final Contract.TriggerSmartContract req = Contract.TriggerSmartContract();
      req.ownerAddress = base58.decode(fromAddress).sublist(0, 21);
      req.contractAddress = base58.decode(contractAddress).sublist(0, 21);
      req.callValue = Int64(0);
      req.data = dataList;

      List<dynamic> list = await buildTransaction(
          stub,
          req,
          privateKey,
          Transaction_Contract_ContractType.TriggerSmartContract,
          dataList,
          trxBalance.ceil());
      Transaction trans = list.first;
      Uint8List hash = list.last;
      String hashStr = bytesToHex(hash);
      return [hashStr, broadcastTransaction, stub, trans];
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<dynamic>> broadcastTransaction(
      WalletClient stub, Transaction trans) async {
    Return result = await stub.broadcastTransaction(trans);
    return [
      result.toProto3Json().toString().contains('true') == true,
      result.code.toString()
    ];
  }

  Future<List<dynamic>> buildTransaction(
      WalletClient stub,
      Contract.TriggerSmartContract req,
      String hexPrivateKey,
      Transaction_Contract_ContractType ctxType,
      Uint8List data,
      int trx_fee_limit) async {
    Transaction trans = Transaction();
    trans.rawData = Transaction_raw();
    Transaction_Contract transContract = Transaction_Contract();
    transContract.type = ctxType;
    transContract.parameter = protobuf.Any.pack(req);
    trans.rawData.contract.add(transContract);

    BlockExtention resp = await stub.getNowBlock2(EmptyMessage());
    trans.rawData.refBlockBytes = resp.blockHeader.rawData.number
        .toBytes()
        .reversed
        .toList()
        .sublist(6, 8);
    trans.rawData.refBlockHash = sha256
        .convert(resp.blockHeader.rawData.writeToBuffer())
        .bytes
        .sublist(8, 16);
    trans.rawData.timestamp =
        Int64(DateTime.now().toUtc().millisecondsSinceEpoch);
    trans.rawData.feeLimit = Int64(trx_fee_limit * tronGlobal.AMOUNT_SUN);
    ;
    trans.rawData.expiration = Int64(DateTime.now()
        .toUtc()
        .add(Duration(seconds: 60))
        .millisecondsSinceEpoch);

    Uint8List hash =
        Uint8List.fromList(sha256.convert(trans.rawData.writeToBuffer()).bytes);

    MsgSignature msgSignature = sign(hash, hexToBytes(hexPrivateKey));

    TronMsgSignature msgSignature2 = TronMsgSignature(
        intToBytes(msgSignature.r), intToBytes(msgSignature.s), msgSignature.v);
    Uint8List ms2 = msgSignature2.getSignature();
    trans.signature.add(ms2);
    return [trans, hash];
  }

  String getAbiTronAddress(String base58Address) {
    Uint8List address = base58.decode(base58Address).sublist(1, 21);
    return bytesToHex(address, include0x: true);
  }
}
