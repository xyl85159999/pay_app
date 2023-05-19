// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tron_transaction_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TronTransactionHistory _$TronTransactionHistoryFromJson(
        Map<String, dynamic> json) =>
    TronTransactionHistory()
      ..total = json['total'] as int?
      ..rangeTotal = json['rangeTotal'] as int?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList()
      ..wholeChainTxCount = json['wholeChainTxCount'] as int?
      ..contractMap = (json['contractMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      )
      ..contractInfo = (json['contractInfo'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      );

Map<String, dynamic> _$TronTransactionHistoryToJson(
        TronTransactionHistory instance) =>
    <String, dynamic>{
      'total': instance.total,
      'rangeTotal': instance.rangeTotal,
      'data': instance.data,
      'wholeChainTxCount': instance.wholeChainTxCount,
      'contractMap': instance.contractMap,
      'contractInfo': instance.contractInfo,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data()
  ..block = json['block'] as int?
  ..hash = json['hash'] as String?
  ..timestamp = json['timestamp'] as int?
  ..ownerAddress = json['ownerAddress'] as String?
  ..toAddressList = (json['toAddressList'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..toAddress = json['toAddress'] as String?
  ..contractType = json['contractType'] as int?
  ..confirmed = json['confirmed'] as bool?
  ..revert = json['revert'] as bool?
  ..contractData = json['contractData'] == null
      ? null
      : ContractData.fromJson(json['contractData'] as Map<String, dynamic>)
  ..smartCalls = json['SmartCalls'] as String?
  ..events = json['Events'] as String?
  ..id = json['id'] as String?
  ..data = json['data'] as String?
  ..fee = json['fee'] as String?
  ..contractRet = json['contractRet'] as String?
  ..result = json['result'] as String?
  ..amount = json['amount'] as String?
  ..cost = json['cost'] == null
      ? null
      : Cost.fromJson(json['cost'] as Map<String, dynamic>)
  ..tokenInfo = json['tokenInfo'] == null
      ? null
      : TokenInfo.fromJson(json['tokenInfo'] as Map<String, dynamic>)
  ..triggerInfo = json['trigger_info'] == null
      ? null
      : TriggerInfo.fromJson(json['trigger_info'] as Map<String, dynamic>);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'block': instance.block,
      'hash': instance.hash,
      'timestamp': instance.timestamp,
      'ownerAddress': instance.ownerAddress,
      'toAddressList': instance.toAddressList,
      'toAddress': instance.toAddress,
      'contractType': instance.contractType,
      'confirmed': instance.confirmed,
      'revert': instance.revert,
      'contractData': instance.contractData,
      'SmartCalls': instance.smartCalls,
      'Events': instance.events,
      'id': instance.id,
      'data': instance.data,
      'fee': instance.fee,
      'contractRet': instance.contractRet,
      'result': instance.result,
      'amount': instance.amount,
      'cost': instance.cost,
      'tokenInfo': instance.tokenInfo,
      'trigger_info': instance.triggerInfo,
    };

ContractData _$ContractDataFromJson(Map<String, dynamic> json) => ContractData()
  ..data = json['data'] as String?
  ..ownerAddress = json['owner_address'] as String?
  ..contractAddress = json['contract_address'] as String?;

Map<String, dynamic> _$ContractDataToJson(ContractData instance) =>
    <String, dynamic>{
      'data': instance.data,
      'owner_address': instance.ownerAddress,
      'contract_address': instance.contractAddress,
    };

Cost _$CostFromJson(Map<String, dynamic> json) => Cost()
  ..netUsage = json['net_usage'] as int?
  ..netFee = json['net_fee'] as int?
  ..energyUsage = json['energy_usage'] as int?
  ..energyFee = json['energy_fee'] as int?
  ..energyUsageTotal = json['energy_usage_total'] as int?
  ..fee = json['fee'] as int?
  ..originEnergyUsage = json['origin_energy_usage'] as int?;

Map<String, dynamic> _$CostToJson(Cost instance) => <String, dynamic>{
      'net_usage': instance.netUsage,
      'net_fee': instance.netFee,
      'energy_usage': instance.energyUsage,
      'energy_fee': instance.energyFee,
      'energy_usage_total': instance.energyUsageTotal,
      'fee': instance.fee,
      'origin_energy_usage': instance.originEnergyUsage,
    };

TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => TokenInfo()
  ..tokenId = json['tokenId'] as String?
  ..tokenName = json['tokenName'] as String?
  ..tokenDecimal = json['tokenDecimal'] as int?
  ..tokenCanShow = json['tokenCanShow'] as int?
  ..tokenType = json['tokenType'] as String?
  ..tokenLevel = json['tokenLevel'] as String?
  ..vip = json['vip'] as bool?;

Map<String, dynamic> _$TokenInfoToJson(TokenInfo instance) => <String, dynamic>{
      'tokenId': instance.tokenId,
      'tokenName': instance.tokenName,
      'tokenDecimal': instance.tokenDecimal,
      'tokenCanShow': instance.tokenCanShow,
      'tokenType': instance.tokenType,
      'tokenLevel': instance.tokenLevel,
      'vip': instance.vip,
    };

TriggerInfo _$TriggerInfoFromJson(Map<String, dynamic> json) => TriggerInfo()
  ..data = json['data'] as String?
  ..parameter = json['parameter'] as Map<String, dynamic>?
  ..methodName = json['methodName'] as String?
  ..contractAddress = json['contract_address'] as String?
  ..callValue = json['call_value'] as int?;

Map<String, dynamic> _$TriggerInfoToJson(TriggerInfo instance) =>
    <String, dynamic>{
      'data': instance.data,
      'parameter': instance.parameter,
      'methodName': instance.methodName,
      'contract_address': instance.contractAddress,
      'call_value': instance.callValue,
    };
