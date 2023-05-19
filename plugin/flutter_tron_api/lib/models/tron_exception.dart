class TronException implements Exception {
  final _message;
  final _prefix;

  TronException([this._prefix, this._message]);

  String toString() {
    return '$_prefix$_message';
  }

}

class ParameterException extends TronException {
  ParameterException([String message = ''])
      : super('', message);
}