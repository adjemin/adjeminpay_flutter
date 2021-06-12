import 'package:adjeminpay_flutter/models/AccessTokenResult.dart';
import 'package:adjeminpay_flutter/models/Application.dart';
import 'package:adjeminpay_flutter/models/TransactionStatus.dart';

abstract class AdjeminPayService{

  Future<AccessTokenResult> getAccessToken(String clientId, String clientSecret);

  Future<Application> getApplication(String clientId, String clientSecret);

  Future<TransactionStatus> doTransactionOperation(
      {
        String clientId,
        String clientSecret,
        String merchantTransactionId,
        String designation,
        String currencyCode,
        String buyerName,
        String buyerReference,
        String notificationUrl,
        String paymentMethodReference,
        double amount,
        int otp,
      });

  Future<TransactionStatus> getPaymentStatus(
      String clientId,
      String clientSecret,
      String transactionReference);


}