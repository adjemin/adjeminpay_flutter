import 'package:adjeminpay_flutter/AdjeminPayService.dart';
import 'package:adjeminpay_flutter/model/AccessTokenResult.dart';
import 'package:adjeminpay_flutter/model/PaymentResult.dart';

class AdjeminPayServiceImpl implements AdjeminPayService{

  static final String BASE_URL = "https://api.adjeminpay.net";
  static final String VERSION = "v1";
  static final String API_URL = "$BASE_URL/$VERSION";

  @override
  Future<PaymentResult> doTransactionOperation({double amount, String operator, String clientReference, String currencyCode, String designation, String notifyUrl, String clientId, int orangeOtp, String buyerName, String transactionId}) {
    // TODO: implement doTransactionOperation
    throw UnimplementedError();
  }

  @override
  Future<AccessTokenResult> getAccessToken(String clientId, String clientSecret) {

    // TODO: implement getAccessToken
    throw UnimplementedError();
  }





}