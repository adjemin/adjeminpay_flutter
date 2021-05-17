import 'package:adjeminpay_flutter/model/AccessTokenResult.dart';
import 'package:adjeminpay_flutter/model/PaymentResult.dart';

abstract class AdjeminPayService{


  Future<AccessTokenResult> getAccessToken(String clientId, String clientSecret);

  Future<PaymentResult> doTransactionOperation(
      {
        double amount,
        String operator,
        String clientReference,
        String currencyCode,
        String designation,
        String notifyUrl,
        String clientId,
        int orangeOtp,
        String buyerName,
        String transactionId
      });

}