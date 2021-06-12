class AccessTokenResult{

  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const AccessTokenResult({this.accessToken, this.tokenType, this.expiresIn});

  static AccessTokenResult fromJson(Map map){
    if(map == null){
      return null;
    }

    return new AccessTokenResult(
      accessToken: map['access_token'] as String,
      tokenType: map['token_type'] as String,
      expiresIn: map['expires_in'] as int
    );
  }

  static Map<String, dynamic> toJson(AccessTokenResult element){
    if(element == null){
      return null;
    }
    return {
      'access_token': element.accessToken,
      'token_type': element.tokenType,
      'expires_in':element.expiresIn
    };
  }
}