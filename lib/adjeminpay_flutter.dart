import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdjeminPay extends StatefulWidget {
  final String apiKey;
  final String applicationId;

  final String notifyUrl;
  final String transactionId;

  final int amount;
  final String currency;
  final String designation;
  final String payerName;

  final String locale;

  final Function callback;

  AdjeminPay({
    @required this.apiKey,
    @required this.applicationId,
    this.notifyUrl,
    @required this.transactionId,
    @required this.amount,
    this.currency,
    @required this.designation,
    this.payerName,
    this.locale = 'fr_FR',
    this.callback,
  })  : assert(apiKey != null, "apiKey must not be null"),
        assert(applicationId != null, "applicationId must not be null"),
        assert(transactionId != null, "transactionId must not be null"),
        assert(amount != null, "amount must not be null"),
        assert(designation != null, "designation must not be null");

  @override
  _AdjeminPayState createState() => _AdjeminPayState();
}

class _AdjeminPayState extends State<AdjeminPay>
    with SingleTickerProviderStateMixin {
  // dynamic
  // final String merchantIconUrl = "https://adjemin.com/img/logo.png";
  final String adpIconUrl = "https://api.adjeminpay.net/img/logo.png";

  // *** Network assets
  final imageLogo = Image.network(AdpAsset.logo);
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
  TextEditingController _clientPhoneController = TextEditingController();
  TextEditingController _clientOrangeOtpController = TextEditingController();

  // final _adpForm = GlobalKey<FormState>();

  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  String _nameErrorText = '';
  String _phoneErrorText = '';
  String _otpErrorText = '';

  final _clientNameFocusNode = FocusNode();
  final _clientPhoneFocusNode = FocusNode();
  final _clientOrangeOtpFocusNode = FocusNode();

  var _isPageLoading = true;
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

  // bool _isLoading = false;
  // bool _isPaymentPending = false;
  // bool _isPaymentSuccessful = false;
  // bool _isPaymentFail = false;

  void _makePayment() async {
    print("=== ADP $_paymentState");
    print("pressed !");

    // ** Form validation
    if (widget.payerName == null) {
      if (!_validateName(_clientNameController.text)) return;
    }
    if (!_validatePhone(_clientPhoneController.text)) return;
    //
    if (_selectedOperator == AdpPaymentOperator.orange) {
      if (!_validateOrangeOtp(_clientOrangeOtpController.text)) return;
    }

    // setState(() {
    //   _paymentState = AdpPaymentState.started;
    // });
    print("=== ADP $_paymentState");
    print("validated !");

    // _transactionId =
    //     widget.transactionId ?? "Adjemin" + DateTime.now().toString();

    String _designation = widget.designation.length > 191
        ? widget.designation.substring(0, 191)
        : widget.designation;

    // ******* HTTP API REQUESTS
    // STARTING API TREATMENT

    var headers = {
      'Authorization': "Bearer FlutterApKAdjemin",
      'Content-Type': "application/json",
      'Accept': "application/json"
    };

    var body = {
      'adp_apikey': widget.apiKey,
      'adp_application_id': widget.applicationId,
      'adp_transaction_id': widget.transactionId,
      'adp_designation': _designation,
      'adp_amount': widget.amount,
      'adp_currency': "XOF",

      'method': paymentMethodText(_selectedMethod),
      'operator': paymentOperatorText(_selectedOperator),

      'name': widget.payerName ?? _clientNameController.text,
      'phone_number': _clientPhoneController.text,
      'otp': _clientOrangeOtpController.text,
      // 'card_name': paymentData['card_name'],
      // 'card_number': paymentData['card_number'],
      // 'card_month': paymentData['card_month'],
      // 'card_year': paymentData['card_year'],
      // 'card_ccv': paymentData['card_ccv'],
      // 'crypted_transaction_id': paymentData['transaction_token']
    };
    // Get token
    print(">>>>body data");
    print(body);

    setState(() {
      _paymentState = AdpPaymentState.initiated;
    });

    print("=== ADP $_paymentState");
    print("body set !");

    print(">> ADP $_paymentState");

    var url = "https://api.adjeminpay.net/v1/auth/makeFlutterPayment";

    var httpResponse =
        await http.post(url, headers: headers, body: json.encode(body));
    print("=== ADP $_paymentState");
    print("waiting for httpResponse !");
    print('============ Response Initiate Payment ==========');
    print(httpResponse.statusCode);
    print('============ Response Initiate Payment status ==========');
    print(httpResponse.body);

    if (httpResponse.statusCode == 200) {
      final response = json.decode(httpResponse.body) as Map<String, dynamic>;
      // Payment response
      print(response);
      if (response['code'] == 409) {
        setState(() {
          _paymentState = AdpPaymentState.error;
          _paymentResult = response;
        });
        _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
        print("=== ADP $_paymentState");

        return;
      }
      print(">>>>>>>>>>>>>>>>> Response Initiated 200 >>>>>>>>>>>>>>>>>>>>>");
      setState(() {
        _paymentState = AdpPaymentState.pending;
      });
      if (body['method'] == "mobile") {
        switch (body['operator']) {
          case "mtn":
            if (response['status'] == "PENDING") {
              print("Payment Pending...");
              print(response['data']);
              // Launch confirmation wait
              setState(() {
                _paymentState = AdpPaymentState.waiting;
                _paymentResult = response;
              });
              // ********* Checking transaction status
              // ********* And allowing transaction check
              var checkStatusUrl =
                  "https://api.adjeminpay.net/v1/auth/adjeminpay/checkMtnTransactionStatus";
              // var checkStatusUrl =
              //     "https://api.adjeminpay.net/v1/auth/checkPaymentStatus";

              var checkStatusBody = {
                'crypted_transaction_id': response['data']
              };
              // var checkStatusBody = {'transaction_id': widget.transactionId};
              int _checkStatusTriesCount = 0;
              int _maxCheckStatusTries = 3; // TODO make this a config var

              finalResponseLoop:
              do {
                _checkStatusTriesCount++;
                var finalMtnResponse = await http.post(checkStatusUrl,
                    headers: headers, body: json.encode(checkStatusBody));
                // Wait for approx 3 minutes 5secs if user doesn't approve or refuse
                print('============ Mtn Follow Transaction ==========');
                // print(finalMtnResponse.body);
                print("Essais restants");
                print(5 - _checkStatusTriesCount);

                if (finalMtnResponse.statusCode == 200) {
                  final decodedMtnResponse = json.decode(finalMtnResponse.body)
                      as Map<String, dynamic>;
                  final finalResponseData = decodedMtnResponse['flutter'];

                  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                  if (finalResponseData['status'] == "PENDING") {
                    print("<<<<<<<<<AWAITING>>>>>>>>>");
                    // Payment still pending, run check status erry 5 sec for 10 min
                    continue finalResponseLoop;
                  }

                  print("<<<<<<<<<<<<<<<<<<<<<<<< TERMINATED <<<<<<<<<<< ");

                  if (finalResponseData['status'] == "SUCCESSFUL") {
                    _paymentState = AdpPaymentState.successful;
                    _paymentResult = {
                      'code': finalResponseData['code'] ?? 1,
                      'status': finalResponseData['status'] ?? "SUCCESSFUL",
                      'message':
                          finalResponseData['message'] ?? "Paiement réussi !"
                    };
                    print("===> going notify success");
                    setState(() {});
                    _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
                    print("<=== finished notify success");
                  }
                  if (finalResponseData['status'] == "CANCELLED") {
                    // check for payment timeout
                    // ! flutter sdk specific
                    if (_checkStatusTriesCount > 3) {
                      print("<<<< Timeout close");
                      _paymentState = AdpPaymentState.expired;
                      // TODO implement expired on js sdk
                      _paymentResult = {
                        'code': "419",
                        'status': "EXPIRED",
                        'message': "Le paiement a expiré"
                      };
                      print("===> going notify expired");
                      setState(() {});
                      _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
                      print("<=== finished notify expired");
                    } else {
                      print("<<< Payment refused");
                      _paymentState = AdpPaymentState.cancelled;
                      _paymentResult = {
                        'code': finalResponseData['code'],
                        'status': finalResponseData['status'],
                        'message': finalResponseData['message'] ??
                            "Le paiement a été refusé"
                      };
                      print("===> going notify refused");
                      setState(() {});
                      _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
                      print("<=== finished notify refused");
                    }
                  }
                  if (finalResponseData['status' == "FAILED"]) {
                    _paymentState = AdpPaymentState.failed;
                    _paymentResult = {
                      'code': finalResponseData['code'],
                      'status': finalResponseData['status'],
                      'message': finalResponseData['message'] ??
                          "Le paiement a échoué !"
                    };
                    print("===> going notify failed");
                    setState(() {});
                    _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
                    print("<=== finished notify failed");
                  }
                  // **** Sending notification to ?notifyUrl

                  break finalResponseLoop;

                  return;
                } else {
                  // throw payUrlResponse;
                  print('============ Mtn Follow Transaction Error ==========');
                  print(httpResponse.body);
                  setState(() {
                    // _paymentState = AdpPaymentState.errorHttp;
                    _paymentResult = {
                      'code': "00",
                      'status': "ERROR_STATUS",
                      'message':
                          "En attente de paiement du client. Mais Impossible de suivre le status du paiement"
                    };
                  });

                  // **** Sending notification to ?notifyUrl
                  if (_checkStatusTriesCount == 2) {
                    // Stop after 2 successive network errors
                    setState(() {
                      _paymentState = AdpPaymentState.errorHttp;
                    });
                    break finalResponseLoop;
                    _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
                    return;
                  }
                  print("====== Retrying ");
                  await Future.delayed(Duration(seconds: 5));
                }
              } while (_checkStatusTriesCount <= _maxCheckStatusTries ||
                  _paymentState == AdpPaymentState.waiting);
              // ******* Immediate fail if solde insuffisant
            } else if (response['status'] == "FAILED") {
              print("Payment Failed...");
              print(response['message']);
              setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = response;
              });
              // **** Sending notification to ?notifyUrl
              _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
              return;
            }
            break;
          case "om":
            print(">>>>>> Orange Response");
            print(response);

            if (response['code'] == 11) {
              //modal("Paiement réussi !", "Transaction terminée", "Veuillez patienter");
              setState(() {
                _paymentState = AdpPaymentState.successful;
                _paymentResult = response;
              });

              print(response['status']);
            }
            if (response['code'] == 00) {
              setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = response;
              });
              // modal("Transaction Terminée", response.message, "Echec");
              print(response['status']);
            }
            if (response['code'] == -11) {
              setState(() {
                _paymentState = AdpPaymentState.failed;
                _paymentResult = response;
              });
              //modal("Transaction Echouée",response.message,  "Echec");
              print(response['status']);
            }
            // **** Sending notification to ?notifyUrl
            _paymentResult['notification'] = await _notifyMerchant(response);
            return;
            break;
          default:
            return;
            break;
        }
      }
      // setState(() {
      //   _paymentState = AdpPaymentState.terminated;
      // });
    } else {
      // throw payUrlResponse;
      print('============ Response Error ==========');
      print(httpResponse.body);
      _paymentState = AdpPaymentState.errorHttp;

      if (body['method'] == "mobile") {
        var errorMessage = json.decode(httpResponse.body)['message'];
        if (body['operator'] == "mtn") {
          _paymentResult = {
            'code': -200,
            'status': "ERROR_HTTP",
            'message': errorMessage ?? "La requete de paiement a échoué",
          };
        }
        setState(() {});
        _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
        return;
      }
      _paymentResult = {
        'code': -200,
        'status': "ERROR_HTTP",
        'message': "La requete de paiement a échoué",
      };
      setState(() {});
      _paymentResult['notification'] = await _notifyMerchant(_paymentResult);
      return;
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

    _clientNameController.text = widget.payerName ?? "";
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadPage();
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
    if (widget.apiKey == null) {
      exitWithError(
          {'code': 401, 'status': "ERROR_CONFIG", 'message': "Missing apiKey"});
      return;
    }
    if (widget.applicationId == null) {
      exitWithError({
        'code': 401,
        'status': "ERROR_CONFIG",
        'message': "Missing applicationId"
      });
      return;
    }

    await precacheImage(imageLogo.image, context);
    // **** Check auth
    var url = "https://api.adjeminpay.net/v1/auth/getToken";
    _iz();
    var response = await http.post(
      url,
      headers: {
        'Accept': "application/json",
        'Content-Type': "application/json",
      },
      body: json.encode({
        'apikey': widget.apiKey,
        'application_id': widget.applicationId,
        'grant-type': "user_credentials",
      }),
    );
    _iz();

    if (response.statusCode != 200) {
      _paymentResult = {
        'code': 401,
        'status': "ERROR_CONFIG",
        'message': "Erreur de configuration"
      };
      print(">>>>> ADP ERROR_CONFIG");
      print(response.body);

      Navigator.of(context).pop(_paymentResult);
      return;
    }
    var decodedData = json.decode(response.body);

    if (decodedData['access_token'] == null) {
      _paymentResult = {
        'code': 401,
        'status': "ERROR_TOKEN",
        'message': "Token de paiement introuvable"
      };
      Navigator.of(context).pop(_paymentResult);
      return;
    }
    // If All good
    // *** Check for transaction Id uniqueness
    // url = "https://api.adjeminpay.net/v1/auth/checkTransactionStatus";
    // // _iz();
    // var transactionStatusResponse = await http.post(
    //   url,
    //   headers: {
    //     'Accept': "application/json",
    //     'Content-Type': "application/json",
    //   },
    //   body: json.encode({
    //     'apikey': widget.apiKey,
    //     'application_id': widget.applicationId,
    //     'grant-type': "user_credentials",
    //   }),
    // );
    // if (transactionStatusResponse.statusCode != 200) {}

    _iz();

    // imageMerchantlogo = decodedData['application_logo'];
    String _imageMerchantlogo = decodedData['application_logo'];

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
    //

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
        .then((value) => setState(() {
              _isPageLoading = false;
            }));
  }

  void exitWithError(result) {
    print(">>>>> ADP ERROR_CONFIG");
    setState(() {
      _isPageLoading = false;
      _paymentState = AdpPaymentState.error;
      _paymentResult = result;
    });
  }

  // payment function
  @override
  Widget build(BuildContext context) {
    // buildT
    // setState(() {
    //   _paymentState = AdpPaymentState.expired;
    // });
    // _paymentResult = {
    //   'code': 00,
    //   'status': "Expired",
    //   'message': "Le paiement a expiré",
    // };

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
                            "${widget.currency ?? 'FCFA'}",
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
          child: 
          imageMerchantlogo,
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
                widget.payerName == null
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
                                setState(() {
                                  _nameErrorText = '';
                                });
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
                                      _phoneErrorText.isEmpty ? "00000000" : "",
                                  hintStyle: AdpTextStyles.primary_bold,
                                  border: InputBorder.none,
                                  counter: Container(),
                                ),
                                maxLength: 8,
                                // maxLengthEnforced: true,
                                onChanged: (_) {
                                  setState(() {
                                    _phoneErrorText = '';
                                  });
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
                                  setState(() {
                                    _otpErrorText = '';
                                  });
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
                          onPressed: () async {
                            // TODO pay
                            _paymentResult = {
                              'code': 405,
                              'status': "CANCELLED",
                              'message': "Paiement annulé"
                            };
                           _paymentResult['notification'] =  await _notifyMerchant(_paymentResult);

                            Navigator.of(context).pop(_paymentResult);
                          }),
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
    // var names = name.split(" ");
    // name = '';
    // names.forEach((n) => name += n + "\n");
    // name.trimRight();
    bool _isSelected = paymentMethod == _selectedMethod;

    return Expanded(
      child: InkWell(
        onTap: () {
          // ** Select current method
          if (paymentMethod != AdpPaymentMethod.bank) {
            setState(() {
              _selectedMethod = paymentMethod;
            });
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

  Widget buildPendingPaymentView() {
    return Center(
      child: Container(
        height: 400,
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
                  : "Veuillez taper *144# puis 1 puis 1 pour confirmer le paiement",
          textSpacing: 20,
          textStyle: AdpTextStyles.primary_bold,
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
                  onPressed: () {
                    Navigator.of(context).pop(_paymentResult);
                  },
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // ******* HELPERS
  // *** Input Validation
  bool _validateName(String clientName) {
    // bool _isPhoneValid = true;

    clientName = clientName.trimLeft();
    clientName = clientName.trimRight();

    FocusScope.of(context).requestFocus(_clientNameFocusNode);
    if (clientName.isEmpty) {
      setState(() {
        _nameErrorText = "Veuillez entrer votre nom et prénoms";
      });
      return false;
    }

    RegExp illegalCharacters = RegExp(r"\d|\W");

    // if (illegalCharacters.hasMatch(clientName)) {
    if (clientName.contains(illegalCharacters)) {
      setState(() {
        _nameErrorText = "Nom et prénoms invalide";
      });
      return false;
    }

    if (clientName.length < 3) {
      setState(() {
        _nameErrorText = "Nom et prénoms trop court";
      });
      return false;
    }

    _clientNameController.text = clientName;

    FocusScope.of(context).requestFocus(_clientPhoneFocusNode);
    // _validateOrangeOtp(_clientOrangeOtpController.text);
    return true;
  }

  bool _validatePhone(String clientPhone) {
    // bool _isPhoneValid = true;

    clientPhone = clientPhone.trim();

    FocusScope.of(context).requestFocus(_clientPhoneFocusNode);
    if (clientPhone.isEmpty) {
      setState(() {
        _phoneErrorText =
            "Veuillez entrer votre numéro ${_selecteOperatorName(_selectedOperator)} money";
      });
      return false;
    }

    RegExp illegalCharacters = RegExp(r"\D");

    // if (illegalCharacters.hasMatch(clientPhone)) {
    if (clientPhone.contains(illegalCharacters)) {
      _phoneErrorText = "Numéro de téléphone invalide";
      setState(() {});
      return false;
    }

    if (clientPhone.length != 8) {
      _phoneErrorText = "Le téléphone doit être de 8 charactères";
      setState(() {});
      return false;
    }

    String clientPrefix = clientPhone.substring(0, 2);

    switch (_selectedOperator) {
      case AdpPaymentOperator.moov:
        var legalPrefixes = AdpOperator.moovPrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro Moov valide";
          setState(() {});
          return false;
        }
        break;
      case AdpPaymentOperator.mtn:
        var legalPrefixes = AdpOperator.mtnPrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro MTN valide";
          setState(() {});
          return false;
        }
        break;
      case AdpPaymentOperator.orange:
        var legalPrefixes = AdpOperator.orangePrefixes;
        if (!legalPrefixes.contains(clientPrefix)) {
          _phoneErrorText = "Veuillez entrer un numéro Orange valide";
          setState(() {});
          print(">>>> validation");
          return false;
        }
        break;
      default:
        _phoneErrorText = "Téléphone introuvable";
        print(">>>> validation");
        setState(() {});
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
      // _makePayment();
      return true;
    }
  }

  bool _validateOrangeOtp(String orangeOtp) {
    FocusScope.of(context).requestFocus(_clientOrangeOtpFocusNode);
    if (orangeOtp.isEmpty) {
      setState(() {
        _otpErrorText = "Tapez #144*82# pour obtenir le code Otp";
      });
      return false;
    }
    if (orangeOtp.length != 4) {
      setState(() {
        _otpErrorText = "Otp doit être de 4 chiffres";
      });
      return false;
    }
    RegExp illegalCharacters = RegExp(r"\D");

    if (illegalCharacters.hasMatch(orangeOtp)) {
      print(">>>>>>>>>>>");
      setState(() {
        _otpErrorText = "Otp doit être des chiffres";
      });
      return false;
    }

    if (_validatePhone(_clientPhoneController.text)) {
      FocusScope.of(context).unfocus();
      // _makePayment();
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
  // _selectedOperator == AdpPaymentOperator.orange ? 90 : 0,

  // **** Notifying merchant's servers
  Future<dynamic> _notifyMerchant(paymentResult) async {
    print(">>>>>>>>>>>> Validating notification url");
    if (widget.notifyUrl == null) {
      print("<== Notify url is null");
      return {
        'notifyStatus': null,
        'notifyMessage': "notifyUrl is null",
      };
    }
    if (widget.notifyUrl.isEmpty) {
      print("<== Notify url is empty");
      return {
        'notifyStatus': "EMPTY",
        'notifyMessage': "notifyUrl is empty",
      };
    }
    if (!(widget.notifyUrl.contains("http:") ||
        widget.notifyUrl.contains("https:"))) {
      print("<== Notify url isn't a valid url");
      return {
        'notifyStatus': "INVALID_URL",
        'notifyMessage': "notifyUrl is not a valid url",
      };
    }
    print(">>>>>>>>>>>> Notifying Merchant Backend");
    print(widget.notifyUrl);
    var response = await http.post(
      widget.notifyUrl,
      headers: {
        'Content-Type': "application/json",
        'Accept': "application/json"
      },
      body: json.encode({
        'transaction_id': widget.transactionId,
        'code': paymentResult['code'],
        'status': paymentResult['status'],
        'message': paymentResult['message'],
      }),
    );
    if (response.statusCode != 200) {
      print("<<<<<< Merchant notification Error");
      print(response.body);
      print("<<=");
      print(widget.transactionId);
      // print(response);
      if (response.statusCode >= 500) {
        return {
          'notifyStatus': "SERVER_ERROR",
          'notifyMessage': json.decode(response.body)['message'] ??
              "Error in your notifyUrl Server",
        };
      }

      return {
        'notifyStatus': "ERROR",
        'notifyMessage': json.decode(response.body)['message'] ??
            "Error in your notifyUrl Server",
      };
    }

    print("<<< Notified Merchant Backend");
    // print(json.decode(response.body));
    print("<<< ==");
    print(response.body);

    var data = {
      'notifyStatus': "SUCCESS",
      'notifyMessage': "Your backend has been notified",
    };

    if (widget.callback != null) {
      print(">>>>>>>>>>>> Executing callback Backend");
      widget.callback(_paymentResult);
    }
    return data;
  }

  // **** Localisation & language helpers
  String __(String title, [String locale = 'fr_FR']) {
    Map<String, String> fr = {
      'total_to_pay': "Total à payer",
      'select_method': "Sélectionnez un moyen de paiement",
      'mobile_money': "Mobile Money",
      'bank_card': "Carte Banquaire",
      'name': "Nom et prénoms",
      'momo_account': "Compte Mobile Money",
      // error texts
      'input_empty_name': "",
      'input_invalid_name': "",
      //
      'input_required_phone': "",
      'input_length_phone': "",
      'input_invalid_phone': "",
      'input_invalid_mtn_phone': "",
      'input_invalid_orange_phone': "",
      'input_invalid_moov_phone': "",
      //
      'input_required_otp': "",
      'input_length_otp': "",
      'input_invalid_otp': "",
      // 
      'info_text_mtn': "",
      'info_text_orange': "",
      'info_text_moov': "",
      //
      'pay_btn': "Payer",
      'cancel_btn': "Annuler",
      'terminate_btn': "Terminer",
    };
    Map<String, String> en = {'': ''};
    if (locale == 'en_EN') {
      return en[title];
    }
    return fr[title];
  }
}

//********** DOCUMENTATION */

// var paymentResult = await Navigator.push(
//     context,
//     new MaterialPageRoute(
//       builder: (context) => AdjeminPay(
//           apiKey: "eyJpdiI6IkpNQ05tWmtGc0FVbWc1VFhFM",
//           applicationId: "f9d37e",
//           transactionId:
//               "Adjemin${widget.element.customer_id}_${widget.element.id}_${widget.session.user.id}_${DateTime.now().second.toString()}",
//           amount: total,
//           currency: "",
//           designation: widget.element.title,
//           payerName: widget.session.user.name),
//     ));
// print(">>>>>>>>>> PAYMENT RESULTS <<<<<<<<<<<<");
// print(paymentResult);

// **** DOCS ************* /

// payWithAdjeminPay(value.data.transaction);

// void payWithAdjeminPay(OrderTransaction data) async {
//     Map<String, dynamic> paymentResult = await Navigator.push(
//         context,
//         new MaterialPageRoute(
//           builder: (context) => AdjeminPay(
//               apiKey: Constants.ADJEMINPAY_API_KEY,
//               applicationId: Constants.ADJEMINPAY_APPLICATION_ID,
//               transactionId: "${data.transaction_id}",
//               amount: int.parse("${data.amount}"),
//               currency:
//                   Currency.byCode(widget.session.currencies, data.currency_code)
//                       .short_name,
//               designation: data.transaction_designation,
//               // designation: widget.element.title,
//               payerName: widget.session.user.name),
//         ));

//     print(">>>>>>>>>> PAYMENT RESULTS <<<<<<<<<<<<");
//     print(paymentResult);

//     if (paymentResult != null) {
//       if (paymentResult['status'] == "SUCCESSFUL") {
//         onPaymentSuccess();
//       } else {
//         Dialogs.error(context, "Erreur Rencontrée", paymentResult['message'],
//             () {
//           payWithAdjeminPay(data);
//         }, () {});
//       }
//     } else {}
//   }

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

// ** PAYMENT DATA
// switchs enums
enum AdpPaymentMethod { mobile, bank }
enum AdpPaymentOperator { mtn, orange, moov, visa, mastercard }
// payment states
enum AdpPaymentState {
  empty,
  started, // payer button clicked
  initiated, // form has been validated
  pending, // waiting on network
  waiting, // waiting on mtn client to approve payment
  error, // unexpected error occured
  errorHttp, // server-side | network error
  successful, // payment successfully billed
  failed, // payment not billed, wrong otp, insufficient funds, etc
  cancelled, // user clicked on "annuler"
  expired, // payment timeout, user didn't approve or refuse payment in due time
  terminated // payment process over
}

String paymentMethodText(AdpPaymentMethod method) {
  return method == AdpPaymentMethod.mobile ? "mobile" : "bank";
}

String paymentOperatorText(AdpPaymentOperator op) {
  return op == AdpPaymentOperator.mtn
      ? "mtn"
      : op == AdpPaymentOperator.orange ? "om" : "moov";
}

String _selecteOperatorName(op) {
  return op == AdpPaymentOperator.mtn
      ? "MTN"
      : op == AdpPaymentOperator.orange ? "Orange" : "Moov";
}
// enum MobileOperator { Mtn, Orange, Moov }
// enum BankOperator { Visa, Mastercard }

// *** AdpTransaction
class AdpTransaction {
  int amount;
  String currency = "XOF";
  String designation;
  String reference;

  AdpTransaction({
    @required this.amount,
    @required this.currency,
    @required this.designation,
    @required this.reference,
  });
}

// *** Text Content
class AdpInfoText {
  static const mtn =
      '''Veuillez taper *133# choisir l'option 1 puis l'option 1 pour approuver ou refuser le paiement''';
  static const moov =
      '''Pour obtenir votre code d'autorisation Moov Money, merci de taper #155#, choisir l'option
      8 puis l'option 2. Entrez votre code secret et validez.''';
  // TODO make this rich text
  static const orange =
      '''Pour obtenir votre code d'autorisation Orange Money, merci de taper #144#, choisir l'option 8 puis l'option 2. Entrez votre code secret et validez.''';
}

// ****** OPERATORS INFOS

class AdpOperator {
  static const orangePrefixes = [
    '07',
    '08',
    '09',
    '47',
    '48',
    '49',
    '57',
    '58',
    '59',
    '67',
    '68',
    '69',
    '77',
    '78',
    '79',
    '87',
    '88',
    '89'
  ];
  static const mtnPrefixes = [
    '04',
    '05',
    '06',
    '44',
    '45',
    '46',
    '55',
    '56',
    '56',
    '64',
    '65',
    '66',
    '74',
    '75',
    '76',
    '84',
    '85',
    '86'
  ];
  static const moovPrefixes = [
    '01',
    '02',
    '03',
    '40',
    '41',
    '42',
    '43',
    '70',
    '71',
    '72',
    '73'
  ];
}

// *** CSS

// *** Assets And Styles
class AdpAsset {
  static const _cdnUri = "https://api.adjeminpay.net/img/";
  // static const _cdnUri = "img/";

  static const logo = _cdnUri + "logo.png";
  // static const logo = "https://adjemin.com/img/logo.png";
  static const background = _cdnUri + "bg.png";
  static const mobile_money = _cdnUri + "mobile-money.png";
  static const mtn = _cdnUri + "op/mtn.webp";
  static const orange = _cdnUri + "op/orange.webp";
  static const moov = _cdnUri + "op/flooz.webp";
  static const bank = _cdnUri + "card.png";
  static const visa = _cdnUri + "op/visa.webp";
  static const mastercard = _cdnUri + "op/mastercard.webp";
  static const check = _cdnUri + "/check.png";
  static const successful = _cdnUri + "/successful.png";
  static const failed = _cdnUri + "/failed.png";
}

class AdpColors {
  static const Color primary = Color(0xff16518D);
  static const Color accent = Color(0xff2dc068);
  static const Color grey = Color(0xffeeeeee);
  static const Color primary100 = Color(0x33115093);
  static const Color border = Color(0xffb4c3d9);
  static const Color red = Color(0xffdc3545);
}

class AdpTextStyles {
  static const white_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: Colors.white,
  );
  static const white_medium_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23,
    color: Colors.white,
  );
  static const white = TextStyle(
    color: Colors.white,
  );
  static const white_semi_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: Colors.white,
  );

  static const primary_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: AdpColors.primary,
  );
  static const primary_bolder = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: AdpColors.primary,
  );
  static const accent_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: AdpColors.accent,
  );
  static const error = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: AdpColors.red,
  );
  static const error_semi_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AdpColors.red,
  );
  static const error_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    fontSize: 26,
    color: AdpColors.red,
  );
}
