class StatusCode
{

  static final String OK = "OK";
  static final String SUCCESS = "SUCCESS";
  static final String OPERATION_ERROR = "OPERATION_ERROR";
  static final String NOT_FOUND = "NOT_FOUND";
  static final String INVALID_CREDENTIALS  = "INVALID_CREDENTIALS";
  static final String INVALID_PARAMS = "INVALID_PARAMS";
  static final String EXPIRED_TOKEN = "EXPIRED_TOKEN";
  static final String INVALID_TOKEN = "INVALID_TOKEN";
  static final String TRANSACTION_EXIST = "TRANSACTION_EXIST";
  static final String INITIATED = "INITIATED";
  static final String PENDING = "PENDING";
  static final String EXPIRED = "EXPIRED";
  static final String OTP_ERROR = "OTP_ERROR";
  static final String OTP_EXPIRED = "OTP_EXPIRED";
  static final String INSUFFICIENT_BALANCE = "INSUFFICIENT_BALANCE";
  static final String USER_NOT_FOUND = "USER_NOT_FOUND";
  static final String USER_IS_BLOCKED = "USER_IS_BLOCKED";
  static final String FAILED = "FAILED";
  static final String NOT_ALLOWED= "NOT_ALLOWED";
  static final String CANCELLED = "CANCELLED";
  static final String BAD_REQUEST  = "BAD_REQUEST";
  static final String UNIMPLEMENTED  = "UNIMPLEMENTED";


  static final Map<String, String> messages  = {
  'OK':"Successful operation",
  'SUCCESS':"Transaction is successfully processed",
  "OPERATION_ERROR":"An error has occurred",
  "NOT_FOUND":"Not found",
  'BAD_REQUEST' : 'Your request is missing some headers or parameters',
  'INVALID_CREDENTIALS':'The requested service needs credentials, but the ones provided were invalid.',
  'INVALID_PARAMS':"Params you provides are invalid",
  'EXPIRED_TOKEN':"Token has expired",
  'INVALID_TOKEN':"Token is invalid",
  'TRANSACTION_EXIST':'The transaction already exists',
  'INITIATED':"Waiting for user entry",
  'PENDING':'User have started payment',
  'EXPIRED':'User has not confirmed the payment',
  'OTP_ERROR':'Otp user provided is incorrect',
  'OTP_EXPIRED':'Otp user provided has expired',
  'INSUFFICIENT_BALANCE':'User has not enough balance to validate operation',
  'USER_NOT_FOUND':'User does not exist',
  'USER_IS_BLOCKED':'User has been blocked',
  'FAILED':'Payment has failed',
  'NOT_ALLOWED':'This Ip is not whitelisted',
  'CANCELLED' : 'User have cancelled payment',
  'UNIMPLEMENTED' : 'Unimplemented'
  };

  static final Map<String, int> codes  = {
  'OK':200,
  'SUCCESS':100,
  "OPERATION_ERROR":-1,
  "NOT_FOUND":404,
  'BAD_REQUEST':400,
  'INVALID_CREDENTIALS':1005,
  'INVALID_PARAMS':1002,
  'EXPIRED_TOKEN':1003,
  'INVALID_TOKEN':1004,
  'TRANSACTION_EXIST':1200,
  'INITIATED':2001,
  'PENDING':2002,
  'EXPIRED':2003,
  'OTP_ERROR':2004,
  'OTP_EXPIRED':2008,
  'INSUFFICIENT_BALANCE':2005,
  'USER_NOT_FOUND':2006,
  'USER_IS_BLOCKED':2007,
  'FAILED':2010,
  'NOT_ALLOWED':2011,
  'CANCELLED' : 2012,
  'UNIMPLEMENTED' : 2013
  };

  static final Map<int, String> statuses  = {
  200 : 'OK',
  100 : 'SUCCESS',
  1 : "OPERATION_ERROR",
  404 : "NOT_FOUND",
  400 : 'BAD_REQUEST',
  1005 : 'INVALID_CREDENTIALS',
  1002 : 'INVALID_PARAMS',
  1003 : 'EXPIRED_TOKEN',
  1004 : 'INVALID_TOKEN',
  1200 : 'TRANSACTION_EXIST',
  2001 : 'INITIATED',
  2002 : 'PENDING',
  2003 : 'EXPIRED',
  2004 : 'OTP_ERROR',
  2008 : 'OTP_EXPIRED',
  2005 : 'INSUFFICIENT_BALANCE',
  2006 : 'USER_NOT_FOUND',
  2007 : 'USER_IS_BLOCKED' ,
  2010 : 'FAILED',
  2011 : 'NOT_ALLOWED',
  2012 : 'CANCELLED',
  2013 : 'UNIMPLEMENTED'
  };

}