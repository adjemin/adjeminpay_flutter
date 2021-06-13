class Transaction {

  static final String SUCCESSFUL = "SUCCESSFUL";
  static final String FAILED = "FAILED";
  static final String INITIATED = "INITIATED";
  static final String PENDING = "PENDING";
  static final String CANCELLED = "CANCELLED";
  static final String EXPIRED = "EXPIRED";

  int id;
  int merchantId;
  int userId;
  int applicationId;
  String currencyCode;
  int amount;
  int type;
  int paymentMethodId;
  bool isWaiting;
  bool isCanceled;
  bool isApprouved;
  String canceledAt;
  String approuvedAt;
  String status;
  String deletedAt;
  String createdAt;
  String updatedAt;
  String reference;
  String designation;
  String clientReference;
  String reason;
  String notifUrl;
  String errorMetaTransaction;
  String buyerReference;
  String orangePaymentUrl;
  String orangePayToken;
  String buyerName;
  String paymentMethodCode;
  String phoneNumber;
  bool isInitiated;
  bool isCompleted;

  Transaction(
      {this.id,
        this.merchantId,
        this.userId,
        this.applicationId,
        this.currencyCode,
        this.amount,
        this.type,
        this.paymentMethodId,
        this.isWaiting,
        this.isCanceled,
        this.isApprouved,
        this.canceledAt,
        this.approuvedAt,
        this.status,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.reference,
        this.designation,
        this.clientReference,
        this.reason,
        this.notifUrl,
        this.errorMetaTransaction,
        this.buyerReference,
        this.orangePaymentUrl,
        this.orangePayToken,
        this.buyerName,
        this.paymentMethodCode,
        this.phoneNumber,
        this.isInitiated,
        this.isCompleted
      });

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    merchantId = json['merchant_id']  as int;
    userId = json['user_id'] as int;
    applicationId = json['application_id'] as int;
    currencyCode = json['currency_code'];
    amount = json['amount'] as int;
    type = json['type'] as int;
    isWaiting = json['is_waiting'] as bool;
    isCanceled = json['is_canceled'] as bool;
    isApprouved = json['is_approuved'] as bool;
    canceledAt = json['canceled_at'] as String;
    approuvedAt = json['approuved_at'] as String;
    status = json['status'] as String;
    deletedAt = json['deleted_at'] as String;
    createdAt = json['created_at'] as String;
    updatedAt = json['updated_at'] as String;
    reference = json['reference'] as String;
    designation = json['designation'] as String;
    clientReference = json['client_reference'] as String;
    reason = json['reason'] as String;
    notifUrl = json['notif_url'] as String;
    errorMetaTransaction = json['error_meta_data'] as String;
    buyerReference = json['buyer_reference'] as String;
    buyerName = json['buyer_name'] as String;
    orangePaymentUrl = json['orange_payment_url'] as String;
    orangePayToken = json['orange_pay_token'] as String;
    paymentMethodId = json['payment_method_id'] as int;
    paymentMethodCode = json['payment_method_code'] as String;
    phoneNumber = json['phone_number'] as String;
    isInitiated = json['is_initiated'] as bool;
    isCompleted = json['is_completed'] as bool;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['merchant_id'] = this.merchantId;
    data['user_id'] = this.userId;
    data['application_id'] = this.applicationId;
    data['currency_code'] = this.currencyCode;
    data['amount'] = this.amount;
    data['type'] = this.type;

    data['is_waiting'] = this.isWaiting;
    data['is_canceled'] = this.isCanceled;
    data['is_approuved'] = this.isApprouved;
    data['canceled_at'] = this.canceledAt;
    data['approuved_at'] = this.approuvedAt;
    data['status'] = this.status;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['reference'] = this.reference;
    data['designation'] = this.designation;
    data['client_reference'] = this.clientReference;
    data['reason'] = this.reason;
    data['notif_url'] = this.notifUrl;
    data['error_meta_data'] = this.errorMetaTransaction;
    data['buyer_name'] = this.buyerName;
    data['buyer_reference'] = this.buyerReference;
    data['orange_payment_url'] = this.orangePaymentUrl;
    data['orange_pay_token'] = this.orangePayToken;
    data['payment_method_id'] = this.paymentMethodId;
    data['payment_method_code'] = this.paymentMethodCode;
    data['phone_number'] = this.phoneNumber;
    data['is_initiated'] = this.isInitiated;
    data['is_completed'] = this.isCompleted;
    return data;
  }
}