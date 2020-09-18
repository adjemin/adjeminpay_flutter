# AdjeminPay Flutter

With AdjeminPay, integrating mobile money payments in your flutter app becomes super easy, barely an inconvenience.

## Using

The package generates a payment gate, and when the pay user is finished paying, the payment gate return the payment result.

Follow the steps below :

### Step 1. Get and store your credentials in a constants files

Sign up and create a merchant application for free at [AdjeminPay_signup][] to get an apiKey and an applicationId.

[AdjeminPay_signup]: https://merchant.adjeminpay.net

Then store them in a config/constants/env file where you keep all your other constant data.

````dart
const Map adpConfig = {
      // Your apiKey
      'apiKey': "eyJpdiI6IkpNQ05tWmtGc0FVbWc1VFhFM",
      // Your applicationId
      'applicationId': "99f99e",
      // The notifyUrl is a url for your web backend if you use any
      // A post request with the {transactionId, status, message}
      // will be sent to this url when the payment is terminated (successful, failed, cancelled, or if an error occured)
      // This not required as the package allows you to excute a callback
      // on paymentTerminated
      'notifyUrl': "",
    };
````

### Step 2. Import the package

Add the adjeminpay_flutter package as a dependancy in your `pubspec.yaml` file.

```yaml
    dependencies:
    flutter:
        sdk: flutter
    adjeminpay_flutter:
```

Then import it to your cart screen

```dart
import 'package:adjeminpay_flutter/adjeminpay_flutter.dart';

```

Your `cart_screen` is where you will show your users the items they will pay for.

### Step 3. Build your cart screen

Build a cart screen to finalize the payment.

You can find a beautiful cart screen example from [Academind][] by Maximilian Schwarzmüller in the [Example][] file.

[Academind]: https://academind.com/
[Example]: [https://](https://github.com/adjemin/adjeminpay_flutter/tree/master/example)

### Step 4. Have your order/transaction data ready

Store the data about the payment your user is about to make.

NB: _It is recommended you store the payment data in your database before executing the payment function._

This example uses a basic Map for storing data about an order but it could be anything, from transactions, to payment, anything that needs online payment.

```dart
    Map<String, dynamic> myOrder = {
      // ! required transactionId or orderId
      'transactionId': "UniqueTransactionId" + DateTime.now().toString(),
      // ! required total amount
      'totalAmount': 1000,
      // optional your orderItems data
      'items': [
        {
          'id': '1',
          'productId': 'prod1',
          'price': 100,
          'quantity': 1,
          'title': 'Product 1 title',
        },
        {
          'id': '2',
          'productId': 'prod9',
          'price': 300,
          'quantity': 3,
          'title': 'Product 9 title',
        },
      ],
      'currency': "XOF",
      'designation': "Order Title",
      'payerName': "ClientName",
    };
```

### Step 5. Add a function to launch the payment gate and handle the payment result

Copy-paste this function that takes in the order data and extracts the fields needed by the payment api.

`required fields`:
The following fiels are required:

* `apiKey`      : You can get it in `Step 1.`
* `applicationId`    : You can get it in `Step 1.`
* `transactionId` : Unique id for everyone of your payments, max 191 characters
* `designation` : What your user will see as what they're paying for
* `amount`  : Obviously, right ?

`optional fields`:
These fields are optional:

* `notifyUrl` : A url you set in your web backend.
  A post request with the payment result (a json containing {transactionId, status, message}) will be sent to that url when the payment is completed (successful, failed, cancelled, expired) to allow you to update the order/transaction status in your database directly from your backend.
  This field is optional, since you could do such an update as a callback from your flutter app.
  NB: _If you do want to use the notifyUrl, please check out our [php sdk](https://github.com/adjemin/adjeminpay-php-sdk) for how to catch the notification._
  
* `currency` : Currency for the payment
  NB: _As of version ^0.1 only `XOF` is supported, so check back soon for more_
* `payerName` : The name of your user
  NB: _It is recommended that you provide it in your payment data as it saves your user the hassle of having to type it in the payment gate._

Now let's implement the payment handler function

NB: _This function and the callbacks will be included directly in the library in future versions._

```dart
void payWithAdjeminPay(dynamic orderData) async {
      // paymentResult will yield {transactionId, status, message }
      // once the payment gate is closed by the user
      // ! IMPORTANT : make sure to save the orderData in your database first
      // ! before calling this function
      Map<String, dynamic> paymentResult = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                // The AdjeminPay class
                AdjeminPay(
              // ! required apiKey
              apiKey: adpConfig['apiKey'],
              // ! required applicationId required
              applicationId: adpConfig['applicationId'],
              // ! required transactionId required
              // for you to follow the transaction
              //    or retrieve it later
              //    should be a string < 191 and unique for your application
              transactionId: "${orderData['transactionId']}",
              // notifyUrl for your web backend
              notifyUrl: "https://your.backend.api/notifyUrl",
              // amount: int.parse("${orderData['totalAmount']}"),
              // ! required amount
              //    amount the user is going to pay
              //    should be an int
              amount: int.parse("${orderData['totalAmount']}"),
              // currency code
              // currently supported currency is XOF
              currency: "XOF",
              // ! required designation
              //   the name the user will see as what they're paying for

              designation: orderData['designation'],
              // designation: widget.element.title,
              // the name of your user
              payerName: orderData['clientName'],
            ),
          ));

      print(">>> ADJEMINPAY PAYMENT RESULTS <<<");
      print(paymentResult);
      // * Here you define your callbacks
      // Callback if the paymentResult is null
      //    the payment gate got closed without sending back any data
      if (paymentResult == null) {
        print("<<< Payment Gate Unexpectedly closed");
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Payment Status is ${paymentResult['status']}")));
      // Callback on payment successfully
      if (paymentResult['status'] == "SUCCESSFUL") {
        print("<<< AdjeminPay success");
        print(paymentResult);
        // redirect to or show another screen
        return;
      }
      // Callback on payment failed
      if (paymentResult['status'] == "FAILED") {
        print("<<< AdjeminPay failed");
        print(paymentResult);
        // the reason with be mentionned in the paymentResult['message']
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "CANCELLED") {
        print("<<< AdjeminPay cancelled");
        print(paymentResult);
        // the reason with be mentionned in the paymentResult['message']
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "EXPIRED") {
        print("<<< AdjeminPay expired");
        print(paymentResult);
        // The user took too long to approve or refuse payment
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on initialisation error
      if (paymentResult['status'] == "ERROR_CONFIG") {
        print("<<< AdjeminPay Init error");
        // You didn't specify a required field
        // or your apiKey or applicationId are not valid
        print(paymentResult);
        return;
      }
      // Callback in case
      if (paymentResult['status'] == "ERROR") {
        print("<<< AdjeminPay Error");
        // You specified :
        // - a transactionId that has already been used
        // -
        print(paymentResult);
        return;
      }
      // Callback when AdjeminPay requests aren't completed
      if (paymentResult['status'] == "ERROR_HTTP") {
          print("<<< AdjeminPay oups");
          print("Could not reach AdjeminPay Servers");
        return;
      }
    }
```

Here's the same function without the comments :

```dart
void payWithAdjeminPay(dynamic orderData) async {
      Map<String, dynamic> paymentResult = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                AdjeminPay(
              apiKey: adpConfig['apiKey'],
              applicationId: adpConfig['applicationId'],
              transactionId: "${orderData['transactionId']}",
              notifyUrl: "https://your.backend.api/notifyUrl",
              amount: int.parse("${orderData['totalAmount']}"),
              // currency: "XOF",
              design    ation: orderData['designation'],
              payerName: orderData['clientName'],
            ),
          ));

      print(">>> ADJEMINPAY PAYMENT RESULTS <<<");
      print(paymentResult);
      if (paymentResult == null) {
        print("<<< Payment Gate Unexpectedly closed");
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Payment Status is ${paymentResult['status']}")));
      // Callback on payment successfully
      if (paymentResult['status'] == "SUCCESSFUL") {
        print("<<< AdjeminPay success");
        print(paymentResult);
        // redirect to or show another screen
        return;
      }
      // Callback on payment failed
      if (paymentResult['status'] == "FAILED") {
        print("<<< AdjeminPay failed");
        print(paymentResult);
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "CANCELLED") {
        print("<<< AdjeminPay cancelled");
        print(paymentResult);
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "EXPIRED") {
        print("<<< AdjeminPay expired");
        print(paymentResult);
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on initialisation error
      if (paymentResult['status'] == "ERROR_CONFIG") {
        print("<<< AdjeminPay Init error");
        print(paymentResult);
        return;
      }
      // Callback in case
      if (paymentResult['status'] == "ERROR") {
        print("<<< AdjeminPay Error");
        print(paymentResult);
        return;
      }
      // Callback when AdjeminPay requests aren't completed
      if (paymentResult['status'] == "ERROR_HTTP") {
          print("<<< AdjeminPay oups");
          print("Could not reach AdjeminPay Servers");
        return;
      }
    }
```

### Step 6. Pass the function above to your "Order Now" button

```dart
FlatButton(
child: _isLoading
    ? CircularProgressIndicator()
    : Text('ORDER NOW'),
onPressed: (myOrder['totalAmount'] == null ||
        myOrder['totalAmount'] <= 0 ||
        _isLoading)
    ? null
    : () {
        // **** Payment Management Here
        // you first store the Order's data in
        // your database where you create a unique transaction Id
        // for example :  await storeOrderData(myOrder);
        // then you call the payment function
        payWithAdjeminPay(myOrder);
        },
textColor: Theme.of(context).primaryColor,
);
```

### Step 7. You're all done

Congratulations ! You just integrated mobile money payment to your flutter app. Happy coding \(><)/ !

### Complete Example

You can find a basic example at [Example][]

Please help us improve and file an [issue](https://github.com/adjemin/adjeminpay_flutter/issues)
