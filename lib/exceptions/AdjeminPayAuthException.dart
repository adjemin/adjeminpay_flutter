class AdjeminPayAuthException implements Exception {

  final String msg;
  final int statusCode;

  AdjeminPayAuthException(this.msg, this.statusCode);

  @override
  String toString() {
    return 'AdjeminPayAuthException{msg: $msg, statusCode: $statusCode}';
  }
}
