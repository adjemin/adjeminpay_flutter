import 'package:adjeminpay_flutter/models/Transaction.dart';

class TransactionStatus {
  final int code;
  final String status;
  final String message;
  final Transaction data;

  const TransactionStatus({this.code, this.status, this.message, this.data});

  static TransactionStatus fromJson(Map<String, dynamic> json) {
    return new TransactionStatus(
      code: json['code'] as int,
      status: json['status'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? new Transaction.fromJson(json['data']) : null
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}



