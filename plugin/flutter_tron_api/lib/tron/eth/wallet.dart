import 'dart:typed_data';

import 'bytes.dart';
import 'signature.dart';

class Wallet {
  Uint8List _privKey = Uint8List.fromList([]);
  Uint8List _pubKey = Uint8List.fromList([]);

  Wallet.fromPrivateKey(Uint8List key) {
    this._privKey = key;
    this._pubKey = privateKeyToPublicKey(key);
  }

  String getAddressString() {
    return bufferToHex(publicKeyToAddress(_pubKey));
  }

  Uint8List getPrivateKey() {
    return this._privKey;
  }
}
