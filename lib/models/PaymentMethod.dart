class PaymentMethod{

  static final String TYPE_MOBILE  = "MOBILE";
  static final String TYPE_BANK_CARD  = "BANK_CARD";

  static final String Moov_CI  = "Moov_CI";
  static final String MTN_CI  = "MTN_CI";
  static final String ORANGE_CI  = "ORANGE_CI";

  final int id;
  final String title;
  final String logo;
  final String reference;
  final int countryId;
  final String countryCode;
  final String currencyCode;
  final bool isActive;
  final String fees;
  final String type;

  const PaymentMethod({
    this.id, this.title, this.logo, this.reference,
    this.countryId,
    this.countryCode,
    this.currencyCode,
    this.isActive,
    this.fees,
    this.type
  });

  static bool isMobilePayment(String paymentMethodReference){
    return [Moov_CI,MTN_CI, ORANGE_CI].contains(paymentMethodReference);
  }

  static bool isORANGE(String paymentMethodReference){
    return [ORANGE_CI].contains(paymentMethodReference);
  }
  static bool isMTN(String paymentMethodReference){
    return [MTN_CI].contains(paymentMethodReference);
  }

  static all(){
    return [
      new PaymentMethod(
          id: 2,
          title: "MTN",
          logo: "mtn_money.jpg",
          reference: "MTN_CI",
          countryCode: "CI",
          countryId: 384,
          currencyCode: "XOF",
          isActive: true,
          fees: "0",
          type: TYPE_MOBILE
      ),
      new PaymentMethod(
          id: 3,
          title: "Orange",
          logo: "orange_money.jpg",
          reference: "ORANGE_CI",
          countryCode: "CI",
          countryId: 384,
          currencyCode: "XOF",
          isActive: true,
          fees: "0",
          type: TYPE_MOBILE
      )
    ];
  }


}