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
  String amount;
  String type;
  int paymentMethodId;
  bool isWaiting;
  bool isCanceled;
  String cardProviderId;
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
  String providerPaymentId;
  String orangePaymentUrl;
  String orangePayToken;
  String buyerName;
  String paymentMethodCode;
  String phoneNumber;
  bool isInitiated;
  bool isCompleted;
  String returnUrl;
  String cancelUrl;

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
        this.cardProviderId,
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
        this.providerPaymentId,
        this.orangePaymentUrl,
        this.orangePayToken,
        this.buyerName,
        this.paymentMethodCode,
        this.phoneNumber,
        this.isInitiated,
        this.isCompleted,
        this.returnUrl,
        this.cancelUrl});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchantId = json['merchant_id'];
    userId = json['user_id'];
    applicationId = json['application_id'];
    currencyCode = json['currency_code'];
    amount = json['amount'];
    type = json['type'];
    paymentMethodId = json['payment_method_id'];
    isWaiting = json['is_waiting'];
    isCanceled = json['is_canceled'];
    cardProviderId = json['card_provider_id'];
    isApprouved = json['is_approuved'];
    canceledAt = json['canceled_at'];
    approuvedAt = json['approuved_at'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reference = json['reference'];
    designation = json['designation'];
    clientReference = json['client_reference'];
    reason = json['reason'];
    notifUrl = json['notif_url'];
    errorMetaTransaction = json['error_meta_data'];
    buyerReference = json['buyer_reference'];
    providerPaymentId = json['provider_payment_id'];
    orangePaymentUrl = json['orange_payment_url'];
    orangePayToken = json['orange_pay_token'];
    buyerName = json['buyer_name'];
    paymentMethodCode = json['payment_method_code'];
    phoneNumber = json['phone_number'];
    isInitiated = json['is_initiated'];
    isCompleted = json['is_completed'];
    returnUrl = json['return_url'];
    cancelUrl = json['cancel_url'];
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
    data['payment_method_id'] = this.paymentMethodId;
    data['is_waiting'] = this.isWaiting;
    data['is_canceled'] = this.isCanceled;
    data['card_provider_id'] = this.cardProviderId;
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
    data['buyer_reference'] = this.buyerReference;
    data['provider_payment_id'] = this.providerPaymentId;
    data['orange_payment_url'] = this.orangePaymentUrl;
    data['orange_pay_token'] = this.orangePayToken;
    data['buyer_name'] = this.buyerName;
    data['payment_method_code'] = this.paymentMethodCode;
    data['phone_number'] = this.phoneNumber;
    data['is_initiated'] = this.isInitiated;
    data['is_completed'] = this.isCompleted;
    data['return_url'] = this.returnUrl;
    data['cancel_url'] = this.cancelUrl;
    return data;
  }
}