
import 'package:adjeminpay_flutter/AdjeminPayServiceImpl.dart';
import 'package:adjeminpay_flutter/util/AdpAsset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'AdjeminPayServiceImplTest.dart';

void main() {


  test("getLogo() will return Image", (){

    final actual = getLogo();
    expect(actual is Image && actual != null, true);

  });

  test("getMerchantLogo() will return Image", ()async{

    final actual = await getMerchantLogo();
    print("getMerchantLogo() >>> Actual $actual");
    expect(actual is ImageProvider && actual != null, true);

  });

  test("getConfigLogo() will return Image", ()async{

    final actual = await getConfigLogo();
    print("getConfigLogo() >>> Actual $actual");
    expect(actual is Image && actual != null, true);

  });


}

dynamic getLogo(){
  // *** Network assets
  final imageLogo = Image.network(AdpAsset.logo);

  return imageLogo;
}

Future<dynamic> getMerchantLogo() async{
  final String clientId = "";
  final String clientSecret = "";

  final application = await new AdjeminPayServiceImpl().getApplication(clientId, clientSecret);
  // *** Network assets
  String _imageMerchantLogo = "https://merchant.adjeminpay.net/storage/${application.logo}";

  // **** Setup and Preload images
  return Image.network(_imageMerchantLogo).image;
}

Image getConfigLogo(){

  final imageBackground = Image.network(AdpAsset.background);
  final imageMobileMoney = Image.network(AdpAsset.mobile_money);
  final imageMtn = Image.network(AdpAsset.mtn);
  final imageOrange = Image.network(AdpAsset.orange);
  final imageMoov = Image.network(AdpAsset.moov);
  final imageBank = Image.network(AdpAsset.bank);
  final imageVisa = Image.network(AdpAsset.visa);
  final imageMastercard = Image.network(AdpAsset.mastercard);
  final imageCheck = Image.network(AdpAsset.check);
  final imageSuccessful = Image.network(AdpAsset.successful);
  final imageFailed = Image.network(AdpAsset.failed);

  return imageFailed;
}

