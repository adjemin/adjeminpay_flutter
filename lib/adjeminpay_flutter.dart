import 'dart:io';
import 'dart:async';
import 'package:adjeminpay_flutter/AdjeminPayServiceImpl.dart';
import 'package:adjeminpay_flutter/exceptions/AdjeminPayAuthException.dart';
import 'package:adjeminpay_flutter/exceptions/AdjeminPayException.dart';
import 'package:adjeminpay_flutter/models/AdpOperator.dart';
import 'package:adjeminpay_flutter/models/AdpPaymentOperator.dart';
import 'package:adjeminpay_flutter/models/AdpPaymentState.dart';
import 'package:adjeminpay_flutter/models/PaymentMethod.dart';
import 'package:adjeminpay_flutter/models/StatusCode.dart';
import 'package:adjeminpay_flutter/models/Transaction.dart';
import 'package:adjeminpay_flutter/models/TransactionStatus.dart';
import 'package:adjeminpay_flutter/util/AdpAsset.dart';
import 'package:adjeminpay_flutter/util/AdpColors.dart';
import 'package:adjeminpay_flutter/util/AdpInfoText.dart';
import 'package:adjeminpay_flutter/util/AdpTextStyles.dart';
import 'package:flutter/material.dart';

import 'models/AdpPaymentMethod.dart';

class AdjeminPay extends StatefulWidget {

  final String clientId;
  final String clientSecret;
  final String merchantTransactionId;
  final String designation;
  final String buyerName;
  final String buyerReference;
  final String notificationUrl;
  final int amount;
  final String currencyCode;
  final String locale;
  final Function callback;

  const AdjeminPay({
    @required this.clientId,
    @required this.clientSecret,
    @required this.merchantTransactionId,
    @required this.designation,
    @required this.amount,
    @required this.currencyCode,
    @required this.notificationUrl,
    this.buyerName,
    this.buyerReference,
    this.locale = 'fr_FR',
    this.callback,
  })  : assert(clientId != null, "clientId must not be null"),
        assert(clientSecret != null, "clientSecret must not be null"),
        assert(merchantTransactionId != null, "merchantTransactionId must not be null"),
        assert(amount != null, "amount must not be null"),
        assert(currencyCode != null, "currencyCode must not be null"),
        assert(designation != null, "designation must not be null"),
        assert(notificationUrl != null, "notificationUrl must not be null");

  @override
  _AdjeminPayState createState() => _AdjeminPayState();
}

class _AdjeminPayState extends State<AdjeminPay>
    with SingleTickerProviderStateMixin {
  // dynamic
  // final String merchantIconUrl = "https://adjemin.com/img/logo.png";
  final String adpIconUrl = "https://api.adjeminpay.net/img/logo.png";

  var imageMerchantlogo;
  var imageBackground;
  var imageMobileMoney;
  var imageMtn;
  var imageOrange;
  var imageMoov;
  var imageBank;
  var imageVisa;
  var imageMastercard;
  var imageCheck;
  var imageSuccessful;
  var imageFailed;

  // *** payment Input data
  // ** Input Data
  // text controllers
  // default selected methods
  var _selectedMethod = AdpPaymentMethod.mobile;
  var _selectedOperator = AdpPaymentOperator.mtn;

  // String _transactionId;

  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _clientPhoneController = TextEditingController(text:"0556888385");
  TextEditingController _clientOrangeOtpController = TextEditingController();

  // final _adpForm = GlobalKey<FormState>();

  AnimationController _animationController;
  // close button
  // AnimationController _closeBtnAnimationController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  String _nameErrorText = '';
  String _phoneErrorText = '';
  String _otpErrorText = '';

  final _clientNameFocusNode = FocusNode();
  final _clientPhoneFocusNode = FocusNode();
  final _clientOrangeOtpFocusNode = FocusNode();

  var _isPageLoading = true;
  var _paymentReloadIsEnabled = false;
  var _paymentAbortIsEnabled = false;
  var _isInfoContainerClosed = false;
  String _reloadInfoText = "";

  //
  String _notificationText = "";
  String _notificationColor = "info";
  //
  var _pageLoadingTexts = [
    "Initialisation...",
    "Connexion...",
    "Configuration...",
    "Chargement.  ",
    "Chargement.. ",
    "Chargement...",
  ];
  var _z = 0;

  void _iz() {
    setState(() {
      _z++;
    });
  }

  void _dz() {
    setState(() {
      _z -= 2;
    });
  }

  AdpPaymentState _paymentState = AdpPaymentState.empty;
  Map<String, dynamic> _paymentResult = {
    'code': '',
    'status': '',
    'message': '',
  };

  bool _isShowingDialog = false;

  void _makePayment() async {
    print("=== ADP $_paymentState");
    print("pressed !");

    // ** Form validation
    if (widget.buyerName == null) {
      if (!_validateName(_clientNameController.text)) return;
    }
    if (!_validatePhone(_clientPhoneController.text)) return;
    //
    if (_selectedOperator == AdpPaymentOperator.orange) {
      if (!_validateOrangeOtp(_clientOrangeOtpController.text)) return;
    }
    print("=== ADP $_paymentState");
    print("validated !");

    // ******* HTTP API REQUESTS
    // STARTING API TREATMENT

    setState(() {
      _paymentState = AdpPaymentState.initiated;
    });

    print("=== ADP $_paymentState");
    print("body set !");

    print(">> ADP $_paymentState");
    final params = <String, dynamic>{
      "clientId": widget.clientId,
      "clientSecret": widget.clientSecret,
      "merchantTransactionId": widget.merchantTransactionId,
      "designation": widget.designation,
      "amount": widget.amount,
      "currencyCode": widget.currencyCode,
      "buyerName": _clientNameController.text,
      "buyerReference": '225'+_clientPhoneController.text,
      "otp": _selectedMethod == AdpPaymentMethod.mobile && PaymentMethod.isORANGE(paymentOperatorText(_selectedOperator))?(_clientOrangeOtpController.text.trim().isNotEmpty?int.parse(_clientOrangeOtpController.text):-1):-1,
      "paymentMethodReference": paymentOperatorText(_selectedOperator)
    };
    print(">> PARAMS $params");

    try{

      /*final TransactionStatus transactionStatus = await new AdjeminPayServiceImpl().doTransactionOperation(
          clientId: widget.clientId,
          clientSecret: widget.clientSecret,
          merchantTransactionId: widget.merchantTransactionId,
          designation: widget.designation,
          amount: widget.amount,
          currencyCode: widget.currencyCode,
          buyerName: _clientNameController.text,
          buyerReference: '225'+_clientPhoneController.text,
          otp: _selectedMethod == AdpPaymentMethod.mobile && PaymentMethod.isORANGE(paymentOperatorText(_selectedOperator))?(_clientOrangeOtpController.text.trim().isNotEmpty?int.parse(_clientOrangeOtpController.text):-1):-1,
          paymentMethodReference: paymentOperatorText(_selectedOperator)
      );*/

      final TransactionStatus transactionStatus = await new AdjeminPayServiceImpl().doTransactionOperation(
              clientId:"41",
              clientSecret:"Y4R91969G3GYKV1JKvKQaaliK95yluEWKbHKPrfj",
              merchantTransactionId: widget.merchantTransactionId,
              designation: "Commande de produit",
              currencyCode: "XOF",
              buyerName:"Ange Bagui",
              buyerReference:"2250556888385",
              notificationUrl: "https://api.exemple.com/epayment/callback",
              paymentMethodReference: "MTN_CI",
              amount: 10,
              otp: -1
      );

      print(">>>>>>>>>>>>>>>>> Response Initiated 200 >>>>>>>>>>>>>>>>>>>>>");

      print("${transactionStatus.toJson()}");
      print("${transactionStatus.data}");
      if(mounted){
        setState(() {
          _paymentState = AdpPaymentState.pending;
        });
      }

      
      if(transactionStatus != null && transactionStatus.data != null){

        if(PaymentMethod.isMobilePayment(transactionStatus.data.paymentMethodCode)){
          if(PaymentMethod.isORANGE(transactionStatus.data.paymentMethodCode)){

            print(">>>>>> Orange Response");
            print(transactionStatus.toJson());

            if (transactionStatus.status == StatusCode.SUCCESS) {
              setState(() {
                _paymentState = AdpPaymentState.successful;
                _paymentResult = {
                  'code': transactionStatus.code ?? StatusCode.codes[StatusCode.SUCCESS],
                  'status': transactionStatus.status ?? StatusCode.SUCCESS,
                  'message': "Paiement réussi !"
                };
              });

              print(transactionStatus.status);
            }else if(transactionStatus.status == StatusCode.EXPIRED){
              setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = {
                  'code': transactionStatus.code??StatusCode.codes[StatusCode.EXPIRED],
                  'status': transactionStatus.status??StatusCode.EXPIRED,
                  'message': "Le code a expiré !"
                };
              });
              print(transactionStatus.status);
            }else {
              setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = {
                  'code': transactionStatus.code??StatusCode.codes[StatusCode.FAILED],
                  'status': transactionStatus.status??StatusCode.FAILED,
                  'message': "Le paiement a échoué !"
                };
              });
              // modal("Transaction Terminée", response.message, "Echec");
              print(transactionStatus.status);
            }

          }else if(PaymentMethod.isMTN(transactionStatus.data.paymentMethodCode)){

            if (transactionStatus.status == StatusCode.PENDING) {
              print("Payment Pending...");


              // Launch confirmation wait
              if(mounted){
                setState(() {
                _paymentState = AdpPaymentState.waiting;
                _paymentResult = {
                  'status': StatusCode.PENDING,
                  'message': "Le paiement en attente !"
                };
              });
              }
              _activateReload();
              _activateAbort(10);

              // ********* Checking transaction status
              // ********* And allowing transaction check

              // var checkStatusBody = {'transaction_id': widget.transactionId};
              int _checkStatusTriesCount = 0;
              int _maxCheckStatusTries = 1; // TODO make this a config var

              finalResponseLoop:
              do {
                _checkStatusTriesCount++;
                try{

                  // Wait for approx 3 minutes 5secs if user doesn't approve or refuse
                  print('============ Mtn Follow Transaction ==========');
                  // print(finalMtnResponse.body);
                  print("Essais restants");
                  print(5 - _checkStatusTriesCount);

                  var finalMtnResponse = await new AdjeminPayServiceImpl().getPaymentStatus(widget.clientId, widget.clientSecret, widget.merchantTransactionId);

                  if(finalMtnResponse != null){

                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                    if (finalMtnResponse.status == StatusCode.PENDING) {
                      print("<<<<<<<<<AWAITING>>>>>>>>>");
                      // Payment still pending, run check status erry 5 sec for 10 min
                      continue finalResponseLoop;
                    }

                    print("<<<<<<<<<<<<<<<<<<<<<<<< TERMINATED <<<<<<<<<<< ");

                    if (finalMtnResponse.status == StatusCode.SUCCESS) {
                      _paymentState = AdpPaymentState.successful;
                      _paymentResult = {
                        'code': finalMtnResponse.code ?? StatusCode.codes[StatusCode.SUCCESS],
                        'status': finalMtnResponse.status ?? StatusCode.SUCCESS,
                        'message': "Paiement réussi !"
                      };
                      print("===> going notify success");
                      if(mounted){
                        setState(() {});
                      }

                    }else if (finalMtnResponse.status == StatusCode.EXPIRED) {
                      // check for payment timeout
                      // ! flutter sdk specific
                      if (_checkStatusTriesCount > 3) {
                        print("<<<< Timeout close");
                        _paymentState = AdpPaymentState.expired;
                        _paymentResult = {
                          'code': finalMtnResponse.code?? StatusCode.codes[StatusCode.EXPIRED],
                          'status': finalMtnResponse.status ?? StatusCode.EXPIRED,
                          'message': "Le paiement a expiré"
                        };
                        print("===> going notify expired");
                        if(mounted){
                          setState(() {});
                        }

                      }
                    }else if (finalMtnResponse.status == StatusCode.CANCELLED) {

                        print("<<< Payment refused");
                        _paymentState = AdpPaymentState.cancelled;
                        _paymentResult = {
                          'code': finalMtnResponse.code?? StatusCode.codes[StatusCode.CANCELLED],
                          'status': finalMtnResponse.status?? StatusCode.CANCELLED,
                          'message': "Le paiement a été refusé"
                        };
                        if(mounted){
                          setState(() {});
                        }
                    }else if (transactionStatus.status == StatusCode.FAILED) {
                      _paymentState = AdpPaymentState.failed;
                      _paymentResult = {
                        'code': transactionStatus.code?? StatusCode.codes[StatusCode.FAILED],
                        'status': transactionStatus.status?? StatusCode.FAILED,
                        'message': "Le paiement a échoué !"
                      };
                      print("===> going notify failed");
                      if(mounted){
                          setState(() {});
                      }

                      print("<=== finished notify failed");
                    }else{

                    }
                    // **** Sending notification to ?notifyUrl

                    break finalResponseLoop;

                    return;
                  }
                }catch(error){

                  // throw payUrlResponse;
                  print('============ Mtn Follow Transaction Error ==========');
                  setState(() {
                    // _paymentState = AdpPaymentState.errorHttp;
                    _paymentResult = {
                      'code': StatusCode.codes[StatusCode.OPERATION_ERROR],
                      'status': StatusCode.OPERATION_ERROR,
                      'message':
                      "En attente de paiement du client. Mais Impossible de suivre le status du paiement"
                    };
                  });

                  print("====== Retrying ");
                  await Future.delayed(Duration(seconds: 5));

                }
              } while (_checkStatusTriesCount <= _maxCheckStatusTries ||
                  _paymentState == AdpPaymentState.waiting);
              // ******* Immediate fail if solde insuffisant
            } else if (transactionStatus.status == StatusCode.FAILED) {
              print("Payment Failed...");
              print(transactionStatus.message);
              if(mounted){
                setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = {
                  'code': transactionStatus.code?? StatusCode.codes[StatusCode.FAILED],
                  'status': transactionStatus.status?? StatusCode.FAILED,
                  'message': "Le paiement a échoué !"
                };
              });
              }

              return;
            }

          }else{
            // TODO Other payment method
          }
        }else{
          // TODO Other payment method type
        }

      }



    }catch(error){

      print('_makePayment() ====>>> Error $error');

      if(error is AdjeminPayException){

        print("=== ADP $_paymentState");

        // throw payUrlResponse;
        print('============ Response Error ==========');

        if (PaymentMethod.isMobilePayment(paymentOperatorText(_selectedOperator))) {

          if (PaymentMethod.isMTN(paymentOperatorText(_selectedOperator))) {
            _paymentState = AdpPaymentState.failed;
            _paymentResult = {
              'code': StatusCode.codes[StatusCode.FAILED],
              'status':StatusCode.FAILED,
              'message': "La requete de paiement a échoué",
            };

            setState(() {

            });

            return;
          }else if(PaymentMethod.isORANGE(paymentOperatorText(_selectedOperator))){
            _paymentState = AdpPaymentState.failed;
            _paymentResult = {
              'code': StatusCode.codes[StatusCode.FAILED],
              'status':StatusCode.FAILED,
              'message': "La requete de paiement a échoué",
            };

            setState(() {

            });

            return;
          }else{

          }

        }


      }else if(error is SocketException){
        _paymentState = AdpPaymentState.errorHttp;
        _paymentResult = {
          'code': -1,
          'status': "ERROR_HTTP",
          'message': "Vérifiez votre connexion internet !",
        };
        setState(() {});
        return;

      }else{
        _paymentState = AdpPaymentState.error;
        _paymentResult = {
          'code': StatusCode.codes[StatusCode.FAILED],
          'status': StatusCode.FAILED,
          'message': "La requete de paiement a échoué",
        };
        setState(() {});
        return;
      }

    }
    Future.delayed(Duration(minutes: 2)).then((value) => setState(() {
      // _paymentState = AdpPaymentState.empty;
      Navigator.of(context).pop(_paymentResult);
    }));
  }

  // ********** OPERATIONS

  @override
  void initState() {
    super.initState();

    _clientNameController.text = widget.buyerName ?? "";
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    Timer.run((){

      print("initState() >>> loadPage()");
      loadPage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //loadPage();
  }

  @override
  void dispose() {
    super.dispose();
    //
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientOrangeOtpController.dispose();
    //
    _clientNameFocusNode.dispose();
    _clientPhoneFocusNode.dispose();
    _clientOrangeOtpFocusNode.dispose();
    //
    _animationController.dispose();
  }

  void loadPage() async {
    if (widget.clientId == null) {
      exitWithError({
        'code': StatusCode.codes[StatusCode.INVALID_PARAMS],
        'status': StatusCode.INVALID_PARAMS,
        'message': "Missing clientId"
      });
      return;
    }
    if (widget.clientSecret == null) {
      exitWithError({
        'code': StatusCode.codes[StatusCode.INVALID_PARAMS],
        'status': StatusCode.INVALID_PARAMS,
        'message': "Missing clientSecret"
      });
      return;
    }

    // *** Network assets
    final imageLogo = Image.network(AdpAsset.logo);

    await precacheImage(imageLogo.image, context);
    // **** Check auth

    _iz();
    try{
      var application = await new AdjeminPayServiceImpl().getApplication(widget.clientId, widget.clientSecret);

      print('Application ${application.toJson()}');
      _iz();
      if(application != null){

        String _imageMerchantlogo = "https://merchant.adjeminpay.net/storage/${application.logo}";

        // **** Setup and Preload images
        imageMerchantlogo = Image.network(_imageMerchantlogo);
        imageBackground = Image.network(AdpAsset.background);
        imageMobileMoney = Image.network(AdpAsset.mobile_money);
        imageMtn = Image.network(AdpAsset.mtn);
        imageOrange = Image.network(AdpAsset.orange);
        imageMoov = Image.network(AdpAsset.moov);
        imageBank = Image.network(AdpAsset.bank);
        imageVisa = Image.network(AdpAsset.visa);
        imageMastercard = Image.network(AdpAsset.mastercard);
        imageCheck = Image.network(AdpAsset.check);
        imageSuccessful = Image.network(AdpAsset.successful);
        imageFailed = Image.network(AdpAsset.failed);

        _iz();
        await precacheImage(imageMerchantlogo.image, context);
        _iz();
        await precacheImage(imageBackground.image, context);
        _dz();

        await precacheImage(imageMobileMoney.image, context);
        _iz();
        await precacheImage(imageMtn.image, context);
        _iz();
        await precacheImage(imageOrange.image, context);

        _dz();
        await precacheImage(imageMoov.image, context);
        _iz();
        await precacheImage(imageBank.image, context);
        _iz();
        await precacheImage(imageVisa.image, context);

        _dz();
        await precacheImage(imageMastercard.image, context);

        _iz();

        await precacheImage(imageCheck.image, context);
        _iz();

        await precacheImage(imageSuccessful.image, context);
        _dz();
        await precacheImage(imageFailed.image, context);
        _iz();

        await Future.delayed(Duration(milliseconds: 100))
            .then((value){
              if(mounted){
                setState(() {
                  _isPageLoading = false;
                });
              }
        });

      }else{
        _paymentResult = {
          'code': StatusCode.codes[StatusCode.INVALID_PARAMS],
          'status': StatusCode.INVALID_PARAMS,
          'message': StatusCode.messages[StatusCode.INVALID_PARAMS]
        };
      }
    }catch(error){

      _iz();

      if(error is AdjeminPayAuthException){
        _paymentResult = {
          'code': StatusCode.codes[StatusCode.INVALID_CREDENTIALS],
          'status': StatusCode.INVALID_CREDENTIALS,
          'message': error.msg
        };
      }else if(error is AdjeminPayException){

        _paymentResult = {
          'code': StatusCode.codes[StatusCode.OPERATION_ERROR],
          'status': StatusCode.OPERATION_ERROR,
          'message': error.msg
        };
      }else{
        _paymentResult = {
          'code': StatusCode.codes[StatusCode.OPERATION_ERROR],
          'status': StatusCode.OPERATION_ERROR,
          'message': error.msg
        };
      }

      print(">>>>> ADP ${_paymentResult['status']}");
      print("Error $error");

      Navigator.of(context).pop(_paymentResult);
      return;
    }




  }

  void exitWithError(result) {
    print(">>>>> ADP INVALID_PARAMS");
    if(mounted){
      setState(() {
        _isPageLoading = false;
        _paymentState = AdpPaymentState.error;
        _paymentResult = result;
      });
    }
  }

  // payment function
  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: _isPageLoading
              ? Center(
               child: Container(
              // height: 400,
              padding: EdgeInsets.all(20),
              child: ALoader(
                size: 150,
                backgroundImage: NetworkImage(AdpAsset.logo),
                // backgroundImage: AssetImage(AdpAsset.logo),
                text: "${_pageLoadingTexts[_z] ?? 'Chargement...'}",
                textSpacing: 20,
                textPadding: EdgeInsets.only(left: 40),
                textStyle: AdpTextStyles.primary_bolder,
                isTextCentered: false,
              ),
            ),
                )
              : buildPage(),
        ),
      ),
    );
  }

  Container buildAdjeminPayForm() {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        // ***** Main Content
        child: Flex(
          direction: Axis.vertical,
          children: [
            // ** Icons : Merchant and AdjeminPay
            buildLogos(),
            // ** Amount to pay
            Container(
              height: 150,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.network(AdpAsset.background),
                    // child: Image.asset(AdpAsset.background),
                  ),
                  // Text Overlay
                  Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total à payer",
                        style: AdpTextStyles.white,
                      ),
                      // ** Amount
                      Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.amount}",
                            style: AdpTextStyles.white_bold,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${widget.currencyCode ?? 'FCFA'}",
                            style: AdpTextStyles.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // ** Designation
                      Text(
                        "${widget.designation}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdpTextStyles.white_semi_bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ***** Payment Forms
            buildPaymentForm(),
          ],
        ),
      ),
    );
  }

  Flex buildLogos() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Merchant Icon
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 80,
            maxWidth: 100,
          ),
          child: imageMerchantlogo,
          // Image.network(
          //   // child: Image.asset(
          //   // ******* MERCHANT IMAGE // ADJEMIN
          //   // merchantIconUrl,
          //   imageMerchantlogo,
          //   fit: BoxFit.contain,
          // ),
        ),
        // AdjeminPay Icon
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 80,
            maxWidth: 100,
          ),
          child: Image.network(
            // child: Image.asset(
            // ******* MERCHANT IMAGE // ADJEMIN
            AdpAsset.logo,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ***** Payment Forms
  buildPaymentForm() {
    return Form(
      // key : _adpForm,
      child: Container(
        child: Flex(
          direction: Axis.vertical,
          children: [
            // **** Form begins
            Row(
              children: [
                Text(
                  "Sélectionnez un moyen de paiemennt",
                  style: AdpTextStyles.primary_bold,
                ),
              ],
            ),
            SizedBox(height: 10),
            // **** Payment Methods
            Flex(
              direction: Axis.horizontal,
              children: [
                // **** Single Payment method Button
                buildPaymentMethod(
                  "Mobile \n Money",
                  AdpAsset.mobile_money,
                  AdpPaymentMethod.mobile,
                ),
                SizedBox(width: 20),
                // **** Single Payment method Button
                buildPaymentMethod(
                  "Carte \n Bancaire",
                  AdpAsset.bank,
                  AdpPaymentMethod.bank,
                ),
              ],
            ),
            SizedBox(height: 10),
            // **** Payment Providers
            Flex(
              direction: Axis.horizontal,
              children: [
                // **** Single Payment method Button
                buildPaymentProvider(
                  "Mtn \n Money",
                  AdpAsset.mtn,
                  AdpPaymentOperator.mtn,
                ),
                // **** Single Payment method Button
                buildPaymentProvider(
                  "Orange \n Money",
                  AdpAsset.orange,
                  AdpPaymentOperator.orange,
                ),
                // **** Single Payment method Button
                buildPaymentProvider(
                  "Moov \n Money",
                  AdpAsset.moov,
                  AdpPaymentOperator.moov,
                ),
              ],
            ),
            // **** User Info Input
            Flex(
              direction: Axis.vertical,
              children: [
                // *** Name INPUT
                widget.buyerName == null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Nom et prénoms",
                            style: AdpTextStyles.primary_bold,
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: _nameErrorText.isEmpty ? 0 : 20,
                      margin: EdgeInsets.only(
                        left: 5,
                        bottom: 5,
                      ),
                      child: Text(
                        "$_nameErrorText",
                        style: AdpTextStyles.error,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _nameErrorText.isEmpty
                              ? AdpColors.primary
                              : AdpColors.red,
                          width: 1.3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _clientNameController,
                        focusNode: _clientNameFocusNode,
                        keyboardType: TextInputType.name,
                        onChanged: (_) {
                         if(mounted){
                           setState(() {
                             _nameErrorText = '';
                           });
                         }
                        },
                        onSubmitted: _validateName,
                        style: _nameErrorText.isEmpty
                            ? AdpTextStyles.primary_bold
                            : AdpTextStyles.error,
                        cursorColor: _nameErrorText.isEmpty
                            ? AdpColors.primary
                            : AdpColors.red,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          hintText: "Nom et prénom",
                          hintStyle: _nameErrorText.isEmpty
                              ? AdpTextStyles.primary_bold
                              : AdpTextStyles.error,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(),
                // *** Phone INPUT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Compte Mobile Money",
                            style: AdpTextStyles.primary_bold,
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: _phoneErrorText.isEmpty ? 0 : 20,
                      margin: EdgeInsets.only(
                        left: 5,
                        bottom: 5,
                      ),
                      child: Text(
                        "$_phoneErrorText",
                        style: AdpTextStyles.error,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _phoneErrorText.isEmpty
                              ? AdpColors.primary
                              : AdpColors.red,
                          width: 1.3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // padding: EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Container(
                              color: AdpColors.primary100,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              child: Text(
                                "+225",
                                style: _phoneErrorText.isEmpty
                                    ? AdpTextStyles.primary_bold
                                    : AdpTextStyles.error,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: _clientPhoneController,
                                keyboardType: TextInputType.phone,
                                focusNode: _clientPhoneFocusNode,
                                style: _phoneErrorText.isEmpty
                                    ? AdpTextStyles.primary_bold
                                    : AdpTextStyles.error,
                                cursorColor: _phoneErrorText.isEmpty
                                    ? AdpColors.primary
                                    : AdpColors.red,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  hintText:
                                  _phoneErrorText.isEmpty ? "0000000000" : "",
                                  hintStyle: AdpTextStyles.primary_bold,
                                  border: InputBorder.none,
                                  counter: Container(),
                                ),
                                maxLength: 10,
                                // maxLengthEnforced: true,
                                onChanged: (_) {
                                  if(mounted){
                                    setState(() {
                                      _phoneErrorText = '';
                                    });
                                  }
                                },
                                onSubmitted: _validatePhone,
                                onEditingComplete: () {
                                  if (_selectedOperator !=
                                      AdpPaymentOperator.orange) {
                                    _makePayment();
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 30,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Image.network(
                                    // child: Image.asset(
                                    _selectedOperator ==
                                        AdpPaymentOperator.orange
                                        ? AdpAsset.orange
                                        : _selectedOperator ==
                                        AdpPaymentOperator.moov
                                        ? AdpAsset.moov
                                        : AdpAsset.mtn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // *** Code d'autorisation // only orange

                FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: _getOrangeOtpHeight(),
                      child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _selectedOperator == AdpPaymentOperator.orange
                              ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5),
                                child: Text(
                                  "Code d'autorisation",
                                  style: AdpTextStyles.primary_bold,
                                ),
                              ),
                            ],
                          )
                              : Container(),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: _otpErrorText.isEmpty ? 0 : 20,
                            margin: EdgeInsets.only(
                              left: 5,
                              bottom: 5,
                            ),
                            child: Text(
                              "$_otpErrorText",
                              style: AdpTextStyles.error,
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _otpErrorText.isEmpty
                                      ? AdpColors.primary
                                      : AdpColors.red,
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: _clientOrangeOtpController,
                                focusNode: _clientOrangeOtpFocusNode,
                                cursorColor: _otpErrorText.isEmpty
                                    ? AdpColors.primary
                                    : AdpColors.red,
                                keyboardType: TextInputType.number,
                                style: _otpErrorText.isEmpty
                                    ? AdpTextStyles.primary_bold
                                    : AdpTextStyles.error,
                                maxLength: 4,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(0),
                                    hintStyle: AdpTextStyles.primary_bold,
                                    border: InputBorder.none,
                                    counter: Container()),
                                onChanged: (_) {
                                 if(mounted){
                                   setState(() {
                                     _otpErrorText = '';
                                   });
                                 }
                                },
                                onSubmitted: _validateOrangeOtp,
                                onEditingComplete: () {
                                  _makePayment();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    // : Container(),
                    ,
                  ),
                ),
              ],
            ),
            // *** Info container
            Container(
              //
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdpColors.primary,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(10),
                color: AdpColors.primary100,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 5, bottom: 10),
              child: Text(
                _selectedOperator == AdpPaymentOperator.orange
                    ? '${AdpInfoText.orange}'
                    : _selectedOperator == AdpPaymentOperator.moov
                    ? "${AdpInfoText.moov}"
                    : "${AdpInfoText.mtn}",
                style: AdpTextStyles.primary_bold,
              ),
            ),
            // ******* Pay button
            Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                    color: AdpColors.accent,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: _paymentState != AdpPaymentState.empty
                        ? CircularProgressIndicator()
                        : Text(
                      "Payer",
                      style: AdpTextStyles.white_bold,
                    ),
                    onPressed: _paymentState != AdpPaymentState.empty
                        ? null
                        : _makePayment),
              ),
            ),
            // ****** Cancel button
            _paymentState == AdpPaymentState.empty
                ? Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Annuler",
                    style: AdpTextStyles.error_semi_bold,
                  ),
                  onPressed: _showAbortDialog,
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  // Payment Method card
  Expanded buildPaymentMethod(
      String name, String image, AdpPaymentMethod paymentMethod) {
    bool _isSelected = paymentMethod == _selectedMethod;

    return Expanded(
      child: InkWell(
        onTap: () {
          // ** Select current method
          if (paymentMethod != AdpPaymentMethod.bank) {
            if(mounted){
              setState(() {
                _selectedMethod = paymentMethod;
              });
            }
          }
        },
        child: Container(
          //
          decoration: BoxDecoration(
            border: Border.all(
              color: AdpColors.primary,
              width: _isSelected ? 2 : 0,
            ),
            color: _isSelected ? AdpColors.primary100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 30,
                ),
                child: Image.network(
                  // child: Image.asset(
                  image ?? "",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "$name",
                style: AdpTextStyles.primary_bold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Payment Provider card
  Expanded buildPaymentProvider(
      String name, String image, AdpPaymentOperator paymentOperator) {
    bool _isSelected = paymentOperator == _selectedOperator;

    return Expanded(
      child: InkWell(
        onTap: () {
          // ** Select current operator
          if (paymentOperator != AdpPaymentOperator.moov) {
            if(mounted){
              setState(() {
                _selectedOperator = paymentOperator;
                _phoneErrorText = '';

                if (paymentOperator == AdpPaymentOperator.orange) {
                  _animationController.forward();
                } else {
                  _otpErrorText = '';
                  // _clientOrangeOtpController.text = '';
                  _animationController.reverse();
                }
              });
            }
          }
        },
        child: Container(
          //
          decoration: BoxDecoration(
            border: _isSelected
                ? Border.all(
              color: AdpColors.primary,
              width: 1.3,
            )
                : null,
            borderRadius: BorderRadius.circular(10),
            color: _isSelected ? AdpColors.primary100 : Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 30,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.network(
                    // child: Image.asset(
                    image ?? "",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text(
                "$name",
                style: AdpTextStyles.primary_bold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Payment result Builder
  // ******************* PAGE BUILDER
  buildPage() {
    // Abort dialog
    if (_isShowingDialog) {
      return buildShowDialog();
    } else {
      if (_paymentState == AdpPaymentState.empty ||
          _paymentState == AdpPaymentState.initiated) {
        return buildAdjeminPayForm();
      } else if (_paymentState == AdpPaymentState.pending ||
          _paymentState == AdpPaymentState.waiting) {
        return buildPendingPaymentView();
      } else {
        return buildPaymentResultView();
      }
    }
  }

  Widget buildPendingPaymentView() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceIn,
          right: 20,
          top: _paymentAbortIsEnabled ? 20 : -100,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdpColors.primary100,
            ),
            child: InkWell(
              child: Icon(
                Icons.close,
                color: AdpColors.red,
                size: 35,
              ),
              onTap: _showAbortDialog,
            ),
          ),
        ),
        Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isInfoContainerClosed ? 0 : 400,
            padding: EdgeInsets.all(20),
            child: ALoader(
              backgroundImage: NetworkImage(
                // backgroundImage: AssetImage(
                _selectedOperator == AdpPaymentOperator.orange
                    ? AdpAsset.orange
                    : _selectedOperator == AdpPaymentOperator.moov
                    ? AdpAsset.moov
                    : AdpAsset.mtn,
              ),
              text: _selectedOperator == AdpPaymentOperator.orange
                  ? "Paiement en cours..."
                  : _selectedOperator == AdpPaymentOperator.moov
                  ? "Veuillez approuver le paiement"
                  : (_paymentReloadIsEnabled
                  ? "En attente du retour de MTN - Côte d'Ivoire.."
                  : "Veuillez taper *133# puis 1 puis 1 pour confirmer le paiement"),
              textSpacing: 20,
              textStyle: AdpTextStyles.primary_bold,
            ),
          ),
        ),
        // if (_paymentReloadIsEnabled)
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          bottom: _paymentReloadIsEnabled ? 20 : -100,
          left: 20,
          right: 20,
          // width: MediaQuery.of(context).size.width*.8,
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            child: Column(
              children: [
                _buildStatusNotification(),
                Text(
                  "$_reloadInfoText",
                  style: AdpTextStyles.primary_bold.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                  color: AdpColors.primary200,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      ">Vérifier le paiement<",
                      // style: AdpTextStyles.primary_bold,
                      style: AdpTextStyles.white_semi_bold,
                    ),
                  ),
                  onPressed: _checkPaymentStatus,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusNotification() {
    var textColor;
    // var textColor = Colors.white;
    switch (_notificationColor) {
      case "success":
        textColor = AdpColors.accent;
        break;
      case "danger":
        textColor = AdpColors.red;
        break;
      case "error":
        textColor = AdpColors.red;
        break;
      default:
        textColor = AdpColors.primary;
        break;
    }
    return AnimatedContainer(
      width: double.infinity,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _notificationText.isEmpty ? 0 : 45,
      margin: EdgeInsets.only(
        bottom: 5,
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Center(
        child: Text(
          "$_notificationText",
          style: AdpTextStyles.primary_bold.copyWith(
            color: textColor,
            fontSize: _notificationText.length > 20 ? 14 : 16,
            // fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  // Confirm dialog for payment abort
  Widget buildShowDialog() {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Spacer(),
              SizedBox(height: 30),
              Expanded(
                flex: 0,
                child: Container(
                  child: Text("Voulez-vous vraiment annuler le paiement ?",
                      textAlign: TextAlign.center,
                      style: AdpTextStyles.primary_bolder),
                ),
              ),
              Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Non, continuer",
                        style: AdpTextStyles.white_medium_bold,
                      ),
                    ),
                    color: AdpColors.primary,
                    onPressed: _closeAbortDialog,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FlatButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Oui, annuler paiement",
                        style: AdpTextStyles.error_semi_bold,
                      ),
                    ),
                    // color: AdpColors.red,
                    onPressed: _abortPayment,
                  ),
                ),
              ),
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  buildPaymentResultView() {
    return Center(
      child: Container(
        // height: _paymentState == AdpPaymentState.successful ? 700 : 500,
        // height: MediaQu,
        padding: _paymentState == AdpPaymentState.successful
            ? EdgeInsets.all(0)
            : EdgeInsets.all(20),
        child: Column(
          children: [
            Spacer(),
            Expanded(
              flex: 0,
              child: Container(
                // height: 200,
                width: _paymentState == AdpPaymentState.successful
                    ? double.infinity
                    : 200,
                child: Image.network(
                  // child: Image.asset(
                  _paymentState == AdpPaymentState.successful
                      ? AdpAsset.successful
                      : _paymentState == AdpPaymentState.terminated
                      ? AdpAsset.logo
                      : _paymentState == AdpPaymentState.cancelled
                      ? AdpAsset.logo
                      : AdpAsset.failed,
                  fit: BoxFit.contain,
                ),
              ),
              // ),
            ),
            SizedBox(height: 30),
            Expanded(
              flex: 0,
              child: Container(
                child: Text(
                  _paymentState == AdpPaymentState.error
                      ? "Erreur :("
                      : _paymentState == AdpPaymentState.errorHttp
                      ? "Erreur Réseau :("
                      : _paymentState == AdpPaymentState.failed
                      ? "Echec du paiement"
                      : _paymentState == AdpPaymentState.cancelled
                      ? "Paiement Annulé !"
                      : _paymentState == AdpPaymentState.successful
                      ? "Paiement réussi !"
                      : _paymentState == AdpPaymentState.expired
                      ? "Paiement Expiré"
                      : "Paiement Terminé",
                  style: _paymentState == AdpPaymentState.successful
                      ? AdpTextStyles.accent_bold
                      : _paymentState == AdpPaymentState.terminated
                      ? AdpTextStyles.primary_bolder
                      : AdpTextStyles.error_bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _paymentState == AdpPaymentState.error
                      ? "${_paymentResult['message'] ?? ''}"
                      : _paymentState == AdpPaymentState.errorHttp
                      ? "${_paymentResult['message'] ?? 'Vérifiez votre connexion et réessayez'}"
                      : _paymentState == AdpPaymentState.failed
                      ? "${_paymentResult['message'] ?? ''}"
                      : _paymentState == AdpPaymentState.successful
                      ? "${_paymentResult['message'] ?? ''}"
                      : _paymentState == AdpPaymentState.cancelled
                      ? "Le paiement a été refusé"
                      : _paymentState == AdpPaymentState.expired
                      ? "${_paymentResult['message'] ?? ''}"
                      : "Merci d'avoir utilisé AdjeminPay !",
                  textAlign: TextAlign.center,
                  style: AdpTextStyles.primary_bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal:
                  _paymentState == AdpPaymentState.successful ? 20 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: RaisedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Terminer",
                      style: AdpTextStyles.white_medium_bold,
                    ),
                  ),
                  color: _paymentState == AdpPaymentState.successful
                      ? AdpColors.accent
                      : _paymentState == AdpPaymentState.terminated
                      ? AdpColors.primary
                      : _paymentState == AdpPaymentState.cancelled
                      ? AdpColors.primary
                      : AdpColors.red,
                  onPressed: _exit,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // ***** LYTS
  _activateReload([int seconds]) {
    print(">> activating reload");
    Future.delayed(Duration(seconds: seconds ?? 30)).then((_) {
      print("<< reload activated");
      if(mounted){
        setState(() {
          _paymentReloadIsEnabled = true;
          _reloadInfoText = "En attente de la mise à jour du status..";
        });
      }
    });
    //
    Future.delayed(Duration(seconds: 50)).then((_) {
      if(mounted){
        setState(() => _reloadInfoText =
        "En attente de la mise à jour du status de paiement par MTN - Côte d'Ivoire..");
      }
    });
    Future.delayed(Duration(seconds: 50+30)).then((_) {
     if(mounted){
       setState(() => _reloadInfoText = "Le retour de MTN prend un temps anormalement long, cliquez sur ce bouton pour actualiser le status");
     }
    });
    Future.delayed(Duration(seconds: 50+30+60)).then((_) {
     if(mounted){
       setState(() => _reloadInfoText =
       "L'actualisation du status de paiement par MTN met anormalement de temps, cliquez sur ce bouton pour actualiser");
     }
    });
    Future.delayed(Duration(seconds: 50+30+60+30)).then((_) {
     if(mounted){
       setState(() => _reloadInfoText =
       "Si vous avez été débité, nous vous prions de patienter encore un peu");
     }
    });
    Future.delayed(Duration(seconds: 50+30+60+30+5)).then((_) {
      if(mounted){
        setState(() => _reloadInfoText =
        "Veuillez cliquer sur le bouton ci-dessous pour actualiser manuellement..");
      }
    });
    Future.delayed(Duration(seconds: 50+30+60+30+5+15)).then((_) {
      if(mounted){
        setState(() => _reloadInfoText =
        "L'actualisation du status de paiement par MTN met anormalement de temps, cliquez sur ce bouton pour actualiser");
      }
    });
  }

  _activateAbort([int seconds]) {
    print(">> activating abort");
    Future.delayed(Duration(seconds: seconds ?? 10)).then((_) {
      print("<< abort activated");
      if(mounted){
        setState(() => _paymentAbortIsEnabled = true);
      }
    });
  }

  // ******* HELPERS
  // *** Input Validation
  bool _validateName(String clientName) {
    // bool _isPhoneValid = true;

    clientName = clientName.trimLeft();
    clientName = clientName.trimRight();

    FocusScope.of(context).requestFocus(_clientNameFocusNode);
    if (clientName.isEmpty) {
     if(mounted){
       setState(() {
         _nameErrorText = "Veuillez entrer votre nom et prénoms";
       });
     }
      return false;
    }

    RegExp illegalCharacters = RegExp(r"\d|\W");

    // if (illegalCharacters.hasMatch(clientName)) {
    if (clientName.contains(illegalCharacters)) {
      if(mounted){
        setState(() {
          _nameErrorText = "Nom et prénoms invalide";
        });
      }
      return false;
    }

    if (clientName.length < 3) {
      if(mounted){
        setState(() {
          _nameErrorText = "Nom et prénoms trop court";
        });
      }
      return false;
    }

    _clientNameController.text = clientName;

    FocusScope.of(context).requestFocus(_clientPhoneFocusNode);

    return true;
  }

  bool _validatePhone(String clientPhone) {
    // bool _isPhoneValid = true;

    clientPhone = clientPhone.trim();

    FocusScope.of(context).requestFocus(_clientPhoneFocusNode);
    if (clientPhone.isEmpty) {
      if(mounted){
        setState(() {
          _phoneErrorText =
          "Veuillez entrer votre numéro ${_selecteOperatorName(_selectedOperator)} money";
        });
      }
      return false;
    }

    RegExp illegalCharacters = RegExp(r"\D");

    // if (illegalCharacters.hasMatch(clientPhone)) {
    if (clientPhone.contains(illegalCharacters)) {
      _phoneErrorText = "Numéro de téléphone invalide";
      if(mounted)setState(() {});
      return false;
    }

    if (clientPhone.length != 10) {
      _phoneErrorText = "Le téléphone doit être de 10 chiffres";
      if(mounted)setState(() {});
      return false;
    }


    String clientPrefix = clientPhone.substring(0, 2);

    switch (_selectedOperator) {
      case AdpPaymentOperator.moov:
        var legalPrefixes = AdpOperator.moovPrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro Moov valide";
          if(mounted)setState(() {});
          return false;
        }
        break;
      case AdpPaymentOperator.mtn:
        var legalPrefixes = AdpOperator.mtnPrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro MTN valide";
          if(mounted)setState(() {});
          return false;
        }
        break;
      case AdpPaymentOperator.orange:
        var legalPrefixes = AdpOperator.orangePrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro Orange valide";
          if(mounted)setState(() {});
          print(">>>> validation");
          return false;
        }
        break;
      default:
        _phoneErrorText = "Téléphone introuvable";
        print(">>>> validation");
        if(mounted)setState(() {});
        return false;
        break;
    }

    _clientPhoneController.text = clientPhone;

    if (_selectedOperator == AdpPaymentOperator.orange) {
      FocusScope.of(context).requestFocus(_clientOrangeOtpFocusNode);
      // _validateOrangeOtp(_clientOrangeOtpController.text);
      return true;
    } else {
      FocusScope.of(context).unfocus();
      return true;
    }
  }

  bool _validateOrangeOtp(String orangeOtp) {
    FocusScope.of(context).requestFocus(_clientOrangeOtpFocusNode);
    if (orangeOtp.isEmpty) {
      if(mounted){
        setState(() {
          _otpErrorText = "Tapez #144*82# pour obtenir le code Otp";
        });
      }

      return false;
    }
    if (orangeOtp.length != 4) {
      if(mounted){
        setState(() {
          _otpErrorText = "Otp doit être de 4 chiffres";
        });
      }
      return false;
    }
    RegExp illegalCharacters = RegExp(r"\D");

    if (illegalCharacters.hasMatch(orangeOtp)) {
      print(">>>>>>>>>>>");
      if(mounted){
        setState(() {
          _otpErrorText = "Otp doit être des chiffres";
        });
      }
      return false;
    }

    if (_validatePhone(_clientPhoneController.text)) {
      FocusScope.of(context).unfocus();

      return true;
    }
    return false;
  }

  double _getOrangeOtpHeight() {
    if (_selectedOperator == AdpPaymentOperator.orange) {
      if (_otpErrorText.isNotEmpty) {
        return 115;
      }
      return 95;
    }
    return 0;
  }

  // Notify payment status
  _notifyStatus(
      String message, {
        int duration,
        String type,
        int delay,
      }) {
    print(">>_notify $message");
    if(mounted){
      setState(() {
        _notificationText = "";
      });
    }
    Future.delayed(Duration(milliseconds: delay ?? 300)).then((_) {
      if(mounted){
        setState(() {
          _notificationText = message;
          _notificationColor = type ?? "info";
        });
      }

      Future.delayed(Duration(seconds: duration ?? 5))
          .then((value){
            if(mounted){
              setState(() => _notificationText = "");
            }
      });
    });
  }


  // _selectedOperator == AdpPaymentOperator.orange ? 90 : 0,
  // Show Abort dialog view
  _showAbortDialog() {
    if(mounted){
      setState(() {
        _isShowingDialog = true;
      });
    }
    _animationController.forward();
  }

  // Reloads the payment status from mtn
  _checkPaymentStatus() async {
    print(">> realoading status");
    // ********* And allowing transaction check
    // var checkStatusBody = {'transaction_id': widget.transactionId};
    _notifyStatus("Vérification paiement..");
    var finalMtnResponse = await new AdjeminPayServiceImpl().getPaymentStatus(widget.clientId, widget.clientSecret, widget.merchantTransactionId);
    // Wait for approx 3 minutes 5secs if user doesn't approve or refuse
    print('============ Mtn Manual Check Transaction ==========');
    try {
      if (finalMtnResponse != null) {

        print("response <<< ");
        print(finalMtnResponse);
        final finalResponseData = finalMtnResponse.data;

        _notifyStatus(finalResponseData.status);
        if (finalResponseData.status == Transaction.SUCCESSFUL) {
          _paymentState = AdpPaymentState.successful;
          _paymentResult = {
            'status': Transaction.SUCCESSFUL,
            'message': "Paiement réussi !"
          };
          print("===> going notify success");
          if(mounted){
            setState(() {});
          }
          print("<=== finished notify success");
        }
        if (finalResponseData.status == Transaction.CANCELLED) {
          // check for payment timeout
          // ! flutter sdk specific
          print("<<< Payment refused");
          _paymentState = AdpPaymentState.cancelled;
          _paymentResult = {
            'status': Transaction.CANCELLED,
            'message': "Le paiement a été refusé"
          };
          print("===> going notify refused");
          if(mounted){
            setState(() {});
          }
          print("<=== finished notify refused");
        }

        if (finalResponseData.status == Transaction.FAILED) {
          _paymentState = AdpPaymentState.failed;
          _paymentResult = {
            'status': Transaction.FAILED,
            'message': "Le paiement a échoué !"
          };
          print("===> going notify failed");
          if(mounted){
            setState(() {});
          }

        }
        // **** Sending notification to ?notifyUrl
        _notifyStatus("Paiement en attente");
        return;
      } else {
        // throw payUrlResponse;
        print('============ Mtn Manual Follow Transaction Error ==========');
        print(finalMtnResponse.toJson());
        if(mounted){
          setState(() {
            // _paymentState = AdpPaymentState.errorHttp;
            _paymentResult = {
              'code': "00",
              'status': "ERROR_STATUS",
              'message':
              "En attente de paiement du client. Mais Impossible de suivre le status du paiement"
            };
          });
        }
        return;
        // _notifyStatus("Veuillez réessayer", type: "error");
        // // _notifyStatus("Erreur status", type: "error");
        // _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
      }
    } catch (error) {
      print("<< check error caught");
      print(error);
    }
    // ******* Immediate fail if solde insuffisant
  }

  _closeAbortDialog() {
    _animationController.reverse();
    Future.delayed(Duration(milliseconds: 100)).then((_) {
     if(mounted){
       setState(() {
         _isShowingDialog = false;
       });
     }
    });
  }

  // Abort payment
  _abortPayment() async {
    // TODO pay
    print(">>aborting payment");
    _paymentResult = {
      'code': 405,
      'status': "CANCELLED",
      'message': "Paiement annulé"
    };
    if(mounted){
      setState(() {
        _paymentState = AdpPaymentState.cancelled;
      });
    }
    _closeAbortDialog();
    // _exit();
  }
  // Exit the screen with the payment result
  _exit() {
    Navigator.of(context).pop(_paymentResult);
  }
}

// **** GLOBAL FUNCTIONS

// **** DEPENDANCIES

class ALoader extends StatelessWidget {
  final Widget child;
  final double size;
  final Animation<Color> valueColor;
  final ImageProvider backgroundImage;
  final Color backgroundColor;
  final EdgeInsets padding;
  // final Text text;
  final String text;
  final TextStyle textStyle;
  final double textSpacing;
  final bool isTextCentered;
  final Alignment imageAlignment;
  final EdgeInsets textPadding;

  ALoader({
    this.child,
    this.backgroundImage,
    this.text,
    this.textStyle,
    this.textSpacing,
    this.valueColor,
    this.backgroundColor,
    this.size = 100,
    this.padding,
    this.isTextCentered = true,
    this.imageAlignment,
    this.textPadding,
  });
  // const ALoaderr({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: size + 50 + textSpacing ?? 0,
        child: Column(
          crossAxisAlignment: isTextCentered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Align(
              alignment: imageAlignment ?? Alignment.center,
              child: Container(
                height: size,
                width: size,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        valueColor: valueColor ?? null,
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: padding ?? EdgeInsets.all(10),
                        child: CircleAvatar(
                          child: child ?? Container(),
                          backgroundImage: backgroundImage ?? null,
                          backgroundColor:
                          backgroundColor ?? Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //
            SizedBox(height: textSpacing ?? 5),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: textPadding ?? EdgeInsets.all(0),
              child: Text(text ?? "",
                  textAlign: isTextCentered ? TextAlign.center : TextAlign.left,
                  style: textStyle ?? null),
            ),
          ],
        ),
      ),
    );
  }
}




String paymentMethodText(AdpPaymentMethod method) {
  return method == AdpPaymentMethod.mobile ? "mobile" : "bank";
}

String paymentOperatorText(AdpPaymentOperator op) {
  return op == AdpPaymentOperator.mtn
      ? "MTN_CI"
      : op == AdpPaymentOperator.orange
      ? "ORANGE_CI"
      : "Moov_CI";
}

String _selecteOperatorName(op) {
  return op == AdpPaymentOperator.mtn
      ? "MTN"
      : op == AdpPaymentOperator.orange
      ? "Orange"
      : "Moov";
}









