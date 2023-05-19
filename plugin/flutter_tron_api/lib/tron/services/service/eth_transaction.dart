import 'dart:math';
import 'dart:typed_data';

import 'package:eip1559/eip1559.dart';
import 'package:flutter_tron_api/eth_global.dart';
import 'package:flutter_tron_api/tron/eth/abi.dart' as abi;
import 'package:flutter_tron_api/tron/services/grpc/eth_grpc_client.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class EthTransaction {
  Future<List<dynamic>?> transEth(
    String from_address,
    String private_key,
    String to_address,
    double amount,
  ) async {
    final Web3Client client = EthGrpcClient.getChannel();

    try {
      // 获取钱包地址
      EthereumAddress address = EthereumAddress.fromHex(from_address);

      // 钱包地址和接收地址
      EthereumAddress toAddress = EthereumAddress.fromHex(to_address);

      // 设置交易金额 EtherUnit.gwei BigInt.from(10).pow(18)
      EtherAmount value = EtherAmount.inWei(BigInt.from(pow(10, 18) * amount));
      final double balance = await getEthBalance(from_address);
      if (balance < 0 || balance < amount) {
        return [false, 'eth balance is not enough'];
      }

      final List<Fee> fee_list = await client.getGasInEIP1559();
      final Fee fee = fee_list.first;

      BigInt needGas = fee_list.last.estimatedGas;
      BigInt hasGas = BigInt.from(pow(10, 18) * balance);

      if (hasGas < needGas) {
        return [false, 'eth needGas is not enough'];
      }

      final Transaction transaction = Transaction(
        from: address,
        to: toAddress,
        value: value,
        maxFeePerGas: EtherAmount.inWei(fee.maxFeePerGas),
        maxPriorityFeePerGas: EtherAmount.inWei(fee.maxPriorityFeePerGas),
        nonce: await client.getTransactionCount(address),
      );

      Credentials cred = EthPrivateKey.fromHex(private_key);
      Uint8List signedTransaction =
          await client.signTransaction(cred, transaction);

      if (transaction.isEIP1559) {
        signedTransaction = prependTransactionType(0x02, signedTransaction);
      }

      final String hashStr =
          bytesToHex(keccak256(signedTransaction), include0x: true);
      print('===========transEth: signHash        $hashStr');

      return [hashStr, broadcastTransaction, client, signedTransaction];
    } catch (e) {
      print('transEth error $e');
      return null;
    }
  }

  Future<double?> estimateenergy(
    String contract_address,
    String from_address,
    String to_address,
    double tokenAmount,
  ) async {
    double? ethBalance = await getEthBalance(from_address);
    if (ethBalance == null) {
      return null;
    }

    if (ethBalance == 0) {
      return ethGlobal.eth_gas_limit;
    }

    final Web3Client client = EthGrpcClient.getChannel();
    try {
      // 定义代币合约地址
      final EthereumAddress tokenContractAddress =
          EthereumAddress.fromHex(contract_address);

      // 获取钱包地址
      EthereumAddress address = EthereumAddress.fromHex(from_address);

      // 接收地址
      final EthereumAddress recipientAddress =
          EthereumAddress.fromHex(to_address);

      // EtherUnit.mwei
      EtherAmount value =
          EtherAmount.inWei(BigInt.from(pow(10, 6) * tokenAmount));

      final List<String> inputList = ['address', 'uint256'];
      Uint8List methodID = abi.methodID('transfer', inputList);
      final String abiToAddress = recipientAddress.hex;
      String amoutStr = value.getInWei.toString();
      Uint8List rawEncode = abi.rawEncode(inputList, [abiToAddress, amoutStr]);
      Uint8List dataList =
          hexToBytes(bytesToHex(methodID) + bytesToHex(rawEncode));

      final List<Fee> fee_list = await client.getGasInEIP1559();
      final Fee fee = fee_list.first;

      final BigInt gas_limit = await client.estimateGas(
        sender: address,
        to: tokenContractAddress,
        maxFeePerGas: EtherAmount.inWei(fee.maxFeePerGas),
        maxPriorityFeePerGas: EtherAmount.inWei(fee.maxPriorityFeePerGas),
        data: dataList,
      );

      final EtherAmount gasPrice = await client.getGasPrice();
      final double energyUsed =
          gas_limit.toInt() * gasPrice.getInWei.toInt() / pow(10, 18);

      return energyUsed;
    } catch (e) {
      if(e != null && e.toString().contains('-32000')){
        return ethGlobal.eth_gas_limit;
      }
      print('estimateenergy error $e');
      return null;
    }
  }

  Future<List<dynamic>?> transErc20(
      String contract_address,
      String from_address,
      String private_key,
      String to_address,
      double tokenAmount,
      double? ethBalance) async {
    final double? energyUsed = await estimateenergy(
        contract_address, from_address, to_address, tokenAmount);
    if (energyUsed == null) {
      return [false, 'triggerConstantContract result is false'];
    }

    final double max_energy_used = energyUsed;
    if (ethBalance == null || ethBalance < max_energy_used) {
      return [true, '消耗能量上限不足 最低需要 $max_energy_used eth'];
    }

    final Web3Client client = EthGrpcClient.getChannel();
    try {
      // 定义代币合约地址
      final EthereumAddress tokenContractAddress =
          EthereumAddress.fromHex(contract_address);

      // 获取钱包地址
      EthereumAddress address = EthereumAddress.fromHex(from_address);

      // 接收地址
      final EthereumAddress recipientAddress =
          EthereumAddress.fromHex(to_address);

      // EtherUnit.mwei
      EtherAmount value =
          EtherAmount.inWei(BigInt.from(pow(10, 6) * tokenAmount));

      final List<String> inputList = ['address', 'uint256'];
      Uint8List methodID = abi.methodID('transfer', inputList);
      final String abiToAddress = recipientAddress.hex;
      String amoutStr = value.getInWei.toString();
      Uint8List rawEncode = abi.rawEncode(inputList, [abiToAddress, amoutStr]);
      Uint8List dataList =
          hexToBytes(bytesToHex(methodID) + bytesToHex(rawEncode));

      final List<Fee> fee_list = await client.getGasInEIP1559();
      final Fee fee = fee_list.first;

      // Define the transaction
      final Transaction transaction = Transaction(
        from: address,
        to: tokenContractAddress,
        maxFeePerGas: EtherAmount.inWei(fee.maxFeePerGas),
        maxPriorityFeePerGas: EtherAmount.inWei(fee.maxPriorityFeePerGas),
        data: dataList,
        nonce: await client.getTransactionCount(address),
      );

      Credentials cred = EthPrivateKey.fromHex(private_key);
      // String transactionHash = await client.sendTransaction(cred, transaction);
      Uint8List signedTransaction =
          await client.signTransaction(cred, transaction);
      if (transaction.isEIP1559) {
        signedTransaction = prependTransactionType(0x02, signedTransaction);
      }
      final String hashStr =
          bytesToHex(keccak256(signedTransaction), include0x: true);
      print('===========transErc20: signHash        $hashStr');

      return [hashStr, broadcastTransaction, client, signedTransaction];
    } catch (e) {
      print('transErc20 error $e');
      return null;
    }
  }

  Future<List<dynamic>?> broadcastTransaction(
      Web3Client client, Uint8List signedTransaction) async {
    try {
      final String transactionHash =
          await client.sendRawTransaction(signedTransaction);
      // TransactionReceipt? receipt =
      //     await client.getTransactionReceipt(transactionHash);
      return [transactionHash != null && transactionHash.isNotEmpty == true];
    } catch (e) {
      print('broadcastTransaction error $e');
      return null;
    }
  }

  Future<double> getEthBalance(String userAddress) async {
    final Web3Client client = EthGrpcClient.getChannel();
    try {
      final EthereumAddress address = EthereumAddress.fromHex(userAddress);
      EtherAmount etherAmount = await client.getBalance(address);
      double balance = etherAmount.getValueInUnit(EtherUnit.ether);
      print('=================getEthBalance: $balance');
      return balance;
    } catch (e) {
      print('getEthBalance error $e');
      return -1;
    }
  }

  Future<dynamic> getErc20Balance(
      String user_address, String contract_address) async {
    final Web3Client client = EthGrpcClient.getChannel();
    try {
      final EthereumAddress contractAddress =
          EthereumAddress.fromHex(contract_address);
      DeployedContract contract = DeployedContract(
          ContractAbi.fromJson(
              '[{"constant":true,"inputs":[{"name":"who","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]',
              'balanceOf'),
          contractAddress);

      // Call the balanceOf function of the token contract and retrieve the balance
      final EthereumAddress address = EthereumAddress.fromHex(user_address);
      ContractFunction contractFunction = contract.function('balanceOf');
      final List list = await client.call(
          contract: contract, function: contractFunction, params: [address]);

// Decode the result of the function call to get the actual balance
      final EtherAmount etherAmount = EtherAmount.inWei(list[0]);
      double balance = etherAmount.getValueInUnit(EtherUnit.mwei);
      print('=================getErc20Balance: $balance');
      return balance;
    } catch (e) {
      print('getErc20Balance error $e');
      return -1;
    }
  }

  // 通过交易id获取交易数据
  Future<dynamic> gettransactionbyid(String transactionHash) async {
    final Web3Client client = EthGrpcClient.getChannel();
    try {
      TransactionReceipt? receipt =
          await client.getTransactionReceipt(transactionHash);
      print('===========transErc20: transactionHash $transactionHash $receipt');
      if (receipt == null) {
        return null;
      }
      if (receipt.status == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('gettransactionbyid error $e');
      return null;
    }
  }
}
