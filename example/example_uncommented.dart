import 'package:flutter/material.dart';
import '../lib/adjeminpay_flutter.dart';

class ExampleScreen extends StatefulWidget {
  static const routeName = '/adjeminpay-example';

  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const Map adpConfig = {
      'apiKey': "eyJpdiI6IkpNQ05tWmtGc0FVbWc1VFhFM",
      'applicationId': "99f99e",
      'notifyUrl': "",
    };

    //

    void payWithAdjeminPay(dynamic orderData) async {
      Map<String, dynamic> paymentResult = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => AdjeminPay(
              apiKey: adpConfig['apiKey'],
              applicationId: adpConfig['applicationId'],
              transactionId: "${orderData['transactionId']}",
              notifyUrl: "https://adjeminpay.net/v1/notifyUrl",
              amount: int.parse("${orderData['totalAmount']}"),
              currency: "XOF",
              designation: orderData['designation'],
              payerName: orderData['clientName'],
            ),
          ));

      print(">>> ADJEMINPAY PAYMENT RESULTS <<<");
      print(paymentResult);

      if (paymentResult == null) {
        print("<<< Payment Gate Unexpectedly closed");
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Payment Status is ${paymentResult['status']}")));

      if (paymentResult['status'] == "SUCCESSFUL") {
        print("<<< AdjeminPay success");
        print(paymentResult);

        return;
      }

      if (paymentResult['status'] == "FAILED") {
        print("<<< AdjeminPay failed");
        print(paymentResult);

        print("Reason is : " + paymentResult['message']);

        return;
      }

      if (paymentResult['status'] == "CANCELLED") {
        print("<<< AdjeminPay cancelled");
        print(paymentResult);

        print("Reason is : " + paymentResult['message']);

        return;
      }

      if (paymentResult['status'] == "EXPIRED") {
        print("<<< AdjeminPay expired");
        print(paymentResult);

        print("Reason is : " + paymentResult['message']);

        return;
      }

      if (paymentResult['status'] == "ERROR_CONFIG") {
        print("<<< AdjeminPay Init error");

        print(paymentResult);
        return;
      }

      if (paymentResult['status'] == "ERROR") {
        print("<<< AdjeminPay Error");

        print(paymentResult);
        return;
      }

      if (paymentResult['status'] == "ERROR_HTTP") {
        return;
      }
    }

    Map<String, dynamic> myOrder = {
      'transactionId': "UniqueTransactionId" + DateTime.now().toString(),
      'totalAmount': 1000,
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${myOrder['totalAmount']?.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('ORDER NOW'),
                    onPressed: (myOrder['totalAmount'] == null ||
                            myOrder['totalAmount'] <= 0 ||
                            _isLoading)
                        ? null
                        : () {
                            payWithAdjeminPay(myOrder);
                          },
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: myOrder['items'].length,
              itemBuilder: (ctx, i) => CartItem(
                myOrder['items'][i]['id'],
                myOrder['items'][i]['productId'],
                myOrder['items'][i]['price'],
                myOrder['items'][i]['quantity'],
                myOrder['items'][i]['title'],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final int price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text(
              'Do you want to remove the item from the cart?',
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        //
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
