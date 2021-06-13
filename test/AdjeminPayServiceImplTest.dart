
import 'package:adjeminpay_flutter/AdjeminPayServiceImpl.dart';
import 'package:adjeminpay_flutter/models/AccessTokenResult.dart';
import 'package:adjeminpay_flutter/models/Application.dart';
import 'package:adjeminpay_flutter/models/TransactionStatus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as m;

final String clientId = "";
final String clientSecret = "";

void main(){
  
  test("getAccessToken will return an AccessTokenResult instance and has Token", ()async{
    final actual = await new AdjeminPayServiceImpl().getAccessToken(clientId, clientSecret);
    print("Token ${actual.accessToken}");
    expect(actual is AccessTokenResult && actual.accessToken != null, true);
  });

  test("getApplication will return an Application instance", ()async{
    final actual = await new AdjeminPayServiceImpl().getApplication(clientId, clientSecret);
    print("Application ${actual}");
    expect(actual is Application, true);
  });

  test("doTransactionOperation will return an TransactionStatus instance and Transaction is not null", ()async{
    final actual = await new AdjeminPayServiceImpl().doTransactionOperation(
        clientId:clientId,
        clientSecret:clientSecret,
        merchantTransactionId: generateUUID(),
        designation: "Commande de produit",
        currencyCode: "XOF",
        buyerName:"Ange Bagui",
        buyerReference:"2250556888385",
        notificationUrl: "https://api.exemple.com/epayment/callback",
        paymentMethodReference: "MTN_CI",
        amount: 10,
        otp: -1
    );
    print("TransactionStatus ${actual.toJson()}");
    expect(actual is TransactionStatus && actual.data != null, true);
  });

  test("getPaymentStatus will return an TransactionStatus instance and Transaction is not null", ()async{
    final actual = await new AdjeminPayServiceImpl().getPaymentStatus(
        clientId,
        clientSecret,
        "F9625F6E-537B-4793-B20D-D610CAD65B72"
    );
    print("TransactionStatus ${actual.toJson()}");
    expect(actual is TransactionStatus && actual.data != null, true);
  });


}

 String generateUUID() {
var rnd = new m.Random.secure();

var bytes = new List<int>.generate(16, (_) => rnd.nextInt(256));
bytes[6] = (bytes[6] & 0x0F) | 0x40;
bytes[8] = (bytes[8] & 0x3f) | 0x80;

var chars = bytes
    .map((b) => b.toRadixString(16).padLeft(2, '0'))
    .join()
    .toUpperCase();

return '${chars.substring(0, 8)}-${chars.substring(8, 12)}-'
'${chars.substring(12, 16)}-${chars.substring(16, 20)}-${chars.substring(20, 32)}';
}

