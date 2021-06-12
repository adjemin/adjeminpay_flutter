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