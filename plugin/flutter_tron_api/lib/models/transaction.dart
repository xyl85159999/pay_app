import 'dart:convert';

class Transaction {
  String txID;
  int amount = 0;
  String type;
  String toAddress;
  String fromAddress;
  String refBlockBytes;
  String refBlockHash;
  int expiration = 0;
  int timestamp = 0;
  String rawDataHex;
  List<String> signature = <String>[];
  String value;

  Transaction({
    this.txID = '',
    this.amount = 0,
    this.type = '',
    this.toAddress = '',
    this.fromAddress = '',
    this.refBlockBytes = '',
    this.refBlockHash = '',
    this.expiration = 0,
    this.timestamp = 0,
    this.rawDataHex = '',
    this.value = '',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    Transaction transaction = Transaction();
    transaction.txID = json['txID'];
    transaction.amount =
        json['raw_data']['contract'][0]['parameter']['value']['amount'];
    transaction.fromAddress =
        json['raw_data']['contract'][0]['parameter']['value']['owner_address'];
    transaction.toAddress =
        json['raw_data']['contract'][0]['parameter']['value']['to_address'];
    transaction.refBlockBytes = json['raw_data']['ref_block_bytes'];
    transaction.refBlockHash = json['raw_data']['ref_block_hash'];
    transaction.type = json['raw_data']['contract'][0]['type'];
    transaction.expiration = json['raw_data']['expiration'];
    transaction.timestamp = json['raw_data']['timestamp'];
    transaction.rawDataHex = json['raw_data_hex'];
    return transaction;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'visible': false,
        'txID': this.txID,
        'raw_data': json.encode(<String, dynamic>{
          'contract': <Map<String, dynamic>>[
            <String, dynamic>{
              'parameter': <String, dynamic>{
                'value': <String, dynamic>{
                  'amount': this.amount,
                  'owner_address': this.fromAddress,
                  'to_address': this.toAddress
                },
                'type_url': 'type.googleapis.com/protocol.TransferContract'
              },
              'type': this.type
            }
          ],
          'ref_block_bytes': this.refBlockBytes,
          'ref_block_hash': this.refBlockHash,
          'expiration': this.expiration,
          'timestamp': this.timestamp
        }),
        'raw_data_hex': this.rawDataHex,
        'signature': this.signature
      };
}
