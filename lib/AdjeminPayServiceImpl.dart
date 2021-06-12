import 'dart:convert';

import 'package:adjeminpay_flutter/AdjeminPayService.dart';
import 'package:adjeminpay_flutter/exceptions/AdjeminPayAuthException.dart';
import 'package:adjeminpay_flutter/exceptions/AdjeminPayException.dart';
import 'package:adjeminpay_flutter/models/AccessTokenResult.dart';
import 'package:adjeminpay_flutter/models/Application.dart';
import 'package:adjeminpay_flutter/models/StatusCode.dart';
import 'package:adjeminpay_flutter/models/TransactionStatus.dart';
import 'package:http/http.dart' as http;

class AdjeminPayServiceImpl implements AdjeminPayService{

  static final String BASE_URL = "https://api.adjeminpay.net";
  static final String VERSION = "v2";
  static final String API_URL = "$BASE_URL/$VERSION";


  @override
  Future<AccessTokenResult> getAccessToken(String clientId, String clientSecret)async {

    final String url = "$BASE_URL/oauth/token";
    final http.Response response = await http.post(
        Uri.parse(url),
        body: {
          "grant_type": "client_credentials",
          "client_id": clientId,
          "client_secret":clientSecret
        },
        headers: {
          'Accept':'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        }
    );
    if(response.statusCode == 200){
      final Map json = jsonDecode(response.body);
      final AccessTokenResult accessTokenResult = AccessTokenResult.fromJson(json);
      return accessTokenResult;
    }else{
      var message = "";
      if(response.headers['content-type'] == 'application/json'){
        final Map json = jsonDecode(response.body);

        if(json.containsKey('message')){
          message = json['message'] as String;

        }
      }else{
        message  = "Client authentication failed";
      }
      throw new AdjeminPayAuthException(message, response.statusCode);
    }


  }

  @override
  Future<TransactionStatus> getPaymentStatus(
      String clientId,
      String clientSecret,
      String transactionReference)async {
    AccessTokenResult accessTokenResult = await this.getAccessToken(clientId, clientSecret);

    if(accessTokenResult == null){
      final message =  'The requested service needs credentials, but the ones provided were invalid.';
      throw  new AdjeminPayAuthException(message,401);
    }

    final String url = "$API_URL/transactions/$transactionReference";
    final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization' : 'Bearer ${accessTokenResult.accessToken}',
          'Accept':'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        }
    );

    if(response.statusCode == 200){
      final Map json = jsonDecode(response.body);
      final TransactionStatus result = TransactionStatus.fromJson(json);
      return result;
    }else{
      var message = StatusCode.messages[StatusCode.OPERATION_ERROR];
      var code = StatusCode.codes[StatusCode.OPERATION_ERROR];
      var status = StatusCode.OPERATION_ERROR;
      if(response.headers['content-type'] == 'application/json'){
        final Map json = jsonDecode(response.body);

        if(json.containsKey('message')){
          message = json['message'] as String;

        }

        if(json.containsKey('code')){
          code = json['code'] as int;
        }

        if(json.containsKey('status')){
          status = json['status'] as String;
        }

      }else{
        message  = "Payment has failed";
      }

      throw new AdjeminPayException(message, response.statusCode, code,status);
    }
  }

  @override
  Future<TransactionStatus> doTransactionOperation({
    String clientId,
    String clientSecret,
    String merchantTransactionId,
    String designation,
    String currencyCode,
    String buyerName,
    String buyerReference,
    String notificationUrl,
    String paymentMethodReference,
    int amount,
    int otp}) async{

    AccessTokenResult accessTokenResult = await this.getAccessToken(clientId, clientSecret);

    if(accessTokenResult == null){
      final message =  'The requested service needs credentials, but the ones provided were invalid.';
      throw  new AdjeminPayAuthException(message,401);
    }

    final String url = "$API_URL/transactions";
    final http.Response response = await http.post(
        Uri.parse(url),
        body: {
          "merchant_transaction_id": merchantTransactionId,
          "designation": designation,
          "buyer_name":buyerName??"",
          "buyer_reference":buyerReference,
          "notification_url":notificationUrl,
          "payment_method_reference":paymentMethodReference,
          "amount":"$amount",
          "currency_code":currencyCode,
          "otp":otp??""
        },
        headers: {
          'Authorization' : 'Bearer ${accessTokenResult.accessToken}',
          'Accept':'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        }
    );

    print("waiting for httpResponse !");
    print('============ Response Initiate Payment ==========');
    print(response.statusCode);
    print('============ Response Initiate Payment status ==========');

    print(response.body);

    if(response.statusCode == 200){
      final Map json = jsonDecode(response.body);
      final TransactionStatus result = TransactionStatus.fromJson(json);
      return result;
    }else{
      var message = StatusCode.messages[StatusCode.OPERATION_ERROR];
      var code = StatusCode.codes[StatusCode.OPERATION_ERROR];
      var status = StatusCode.OPERATION_ERROR;
      if(response.headers['content-type'] == 'application/json'){
        final Map json = jsonDecode(response.body);

        if(json.containsKey('message')){
          message = json['message'] as String;

        }

        if(json.containsKey('code')){
          code = json['code'] as int;
        }

        if(json.containsKey('status')){
          status = json['status'] as String;
        }

      }else{
        message  = "Payment has failed";
      }

      throw new AdjeminPayException(message, response.statusCode, code,status);
    }
  }

  @override
  Future<Application> getApplication(String clientId, String clientSecret) async{
    AccessTokenResult accessTokenResult = await this.getAccessToken(clientId, clientSecret);

    if(accessTokenResult == null){
      final message =  'The requested service needs credentials, but the ones provided were invalid.';
      throw  new AdjeminPayAuthException(message,401);
    }

    final String url = "$API_URL/merchants/applications/current";
    final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization' : 'Bearer ${accessTokenResult.accessToken}',
          'Accept':'application/json'
        }
    );

    if(response.statusCode == 200){
      final Map json = jsonDecode(response.body);
      final Application result = Application.fromJson(json);
      return result;
    }else{
      var message = StatusCode.messages[StatusCode.OPERATION_ERROR];
      var code = StatusCode.codes[StatusCode.OPERATION_ERROR];
      var status = StatusCode.OPERATION_ERROR;
      if(response.headers['content-type'] == 'application/json'){
        final Map json = jsonDecode(response.body);

        if(json.containsKey('message')){
          message = json['message'] as String;
        }

        if(json.containsKey('code')){
          code = json['code'] as int;
        }

        if(json.containsKey('status')){
          status = json['status'] as String;
        }

      }else{
        message  = "Payment has failed";
      }

      throw new AdjeminPayException(message, response.statusCode, code,status);
    }
  }









}