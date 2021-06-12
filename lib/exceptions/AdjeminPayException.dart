class AdjeminPayException implements Exception {

  final String msg;
  final int code;
  final int statusCode;
  final String status;

  const AdjeminPayException(this.msg, this.statusCode, this.code, this.status);

  @override
  String toString() {
    return 'AdjeminPayException{msg: $msg, statusCode: $statusCode}';
  }
}
