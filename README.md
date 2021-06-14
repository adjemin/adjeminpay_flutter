# AdjeminPay Flutter

With AdjeminPay, integrating mobile money payments in your flutter app becomes super easy, barely an inconvenience.

## Using

The package generates a payment gate, and when the pay user is finished paying, the payment gate return the payment result.

Follow the steps below :

### Step 1. Get and store your credentials in a constants files

Sign up and create a merchant application for free at [AdjeminPay][] to get an apiKey and an applicationId.

[AdjeminPay]: https://merchant.adjeminpay.net

Then store them in a config/constants/env file where you keep all your other constant data.

````dart
class Constants{

  static final String ADJEMINPAY_CLIENT_ID = "CLIENT_ID";
  static final String ADJEMINPAY_CLIENT_SECRET = "CLIENT_SECRET";
  static final String ADJEMINPAY_NOTIFICATION_URL = "https://your.backend.api/notifyUrl";
}
````

### Step 2. Import the package

Add the adjeminpay_flutter package as a dependancy in your `pubspec.yaml` file.

```yaml
    dependencies:
    flutter:
        sdk: flutter
    adjeminpay_flutter: ^1.1.102
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
[Example]: https://https://github.com/adjemin/adjeminpay_flutter/tree/master/example

### Step 4. Have your order/transaction data ready

Store the data about the payment your user is about to make.

NB: _It is recommended you store the payment data in your database before executing the payment function._

This example uses a basic Map for storing data about an order but it could be anything, from transactions, to payment, anything that needs online payment.

```dart
    Map<String, dynamic> myOrder = {
      // ! required transactionId or orderId
      'transaction_id': "UniqueTransactionId",
      // ! required total amount
      'total_amount': 1000,
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
      'currency_code': "XOF",
      'designation': "Order Title",
      'client_name': "ClientName",
    };
```

### Step 5. Add a function to launch the payment gate and handle the payment result

Copy-paste this function that takes in the order data and extracts the fields needed by the payment api.

`required fields`:
The following fiels are required:

* `clientId`      : You can get it in `Step 1.`
* `clientSecret`    : You can get it in `Step 1.`
* `merchantTransactionId` : Unique id for everyone of your payments
* `designation` : What your user will see as what they're paying for
* `amount`  : Obviously, right ?
* `currencyCode`: XOF
* `notifyUrl` : A url you set in your web backend.
  A post request with the payment result (a json containing {transactionId, status, message}) will be sent to that url when the payment is completed (successful, failed, cancelled, expired) to allow you to update the order/transaction status in your database directly from your backend.
  This field is optional, since you could do such an update as a callback from your flutter app.
  NB: _If you do want to use the notifyUrl, please check out our [php sdk](https://github.com/adjemin/adjeminpay-php-sdk) for how to catch the notification._
  
* `currency` : Currency for the payment
  NB: _As of version ^0.1 only `XOF` is supported, so check back soon for more_
`optional fields`:
These fields are optional:
* `buyerName` : The name of your user
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
                   // ! required clientId
                  clientId: Constants.ADJEMINPAY_CLIENT_ID,
                  // ! required clientScret
                  clientSecret: Constants.ADJEMINPAY_CLIENT_SECRET,
                  // ! required transactionId required
                  // for you to follow the transaction
                  //    or retrieve it later
                  //    should be a string < 191 and unique for your application
                  merchantTransactionId: "${orderData['transaction_id']}",
                      // ! required designation
                      //   the name the user will see as what they're paying for
                  designation: orderData['designation'],
                  // notifyUrl for your web backend
                  notificationUrl:Constants.ADJEMINPAY_NOTIFICATION_URL,
                  // amount: int.parse("${orderData['totalAmount']}"),
                  // ! required amount
                  //    amount the user is going to pay
                  //    should be an int
                  amount: int.parse("${orderData['total_amount']}"),
                  // currency code
                  // currently supported currency is XOF
                  currencyCode: orderData['currency_code'],
                  // designation: widget.element.title,
                  // the name of your user
                  buyerName: orderData['client_name'], //optional  
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
       if (paymentResult['status'] == "SUCCESS") {
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
      if (paymentResult['status'] == "INVALID_PARAMS") {
        print("<<< AdjeminPay Init error");
        // You didn't specify a required field
        print(paymentResult);
        return;
      }

      if (paymentResult['status'] == "INVALID_CREDENTIALS") {
        print("<<< AdjeminPay Init error");
        // You didn't specify a required field
        // or your clientId or clientSecret are not valid
        print(paymentResult);
        return;
      }
      // Callback when AdjeminPay requests aren't completed
      if (paymentResult['status'] == "ERROR_HTTP") {
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
