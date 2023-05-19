///
//  Generated code. Do not modify.
//  source: core/Contract.proto

import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class ResourceCode extends $pb.ProtobufEnum {
  static const ResourceCode BANDWIDTH = ResourceCode._(0, 'BANDWIDTH');
  static const ResourceCode ENERGY = ResourceCode._(1, 'ENERGY');

  static const $core.List<ResourceCode> values = <ResourceCode> [
    BANDWIDTH,
    ENERGY,
  ];

  static final $core.Map<$core.int, ResourceCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ResourceCode valueOf($core.int value) => _byValue[value]!;

  const ResourceCode._($core.int v, $core.String n) : super(v, n);
}

