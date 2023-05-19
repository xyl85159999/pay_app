import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';

import 'bytes.dart' as bytes;
import 'rlp.dart' as Rlp;
import 'package:pointycastle/pointycastle.dart';

///
/// Creates Keccak hash of the input
///
Uint8List keccak(dynamic a, {int bits: 256}) {
  a = bytes.toBuffer(a);
  Digest digest = new KeccakDigest(bits);
  return digest.process(a);
}

///
/// Creates Keccak-256 hash of the input, alias for keccak(a, 256).
///
Uint8List keccak256(dynamic a) {
  return keccak(a);
}

///
/// Creates SHA hash of the input.
///
Uint8List sha3(dynamic a,{int bits: 256}) {
   a = bytes.toBuffer(a);
  Digest digest = new Digest('SHA3-${bits}');
  return digest.process(a);
}

///
/// Creates SHA256 hash of the input.
///
Uint8List sha3_256(dynamic a) {
 return sha3(a);
}

///
/// Creates RIPEMD160 hash of the input.
///
Uint8List ripemd160(dynamic a, {bool padded: false}) {
  a = bytes.toBuffer(a);
  Digest rmd160 = new Digest('RIPEMD-160');
  var hash = rmd160.process(a);
  if (padded) {
    return bytes.setLength(hash, 32);
  } else {
    return hash;
  }
}

///
/// Creates SHA-3 hash of the RLP encoded version of the input.
///
Uint8List rlphash(dynamic a) {
  a = bytes.toBuffer(a);
  return keccak(Rlp.encode(a));
}
