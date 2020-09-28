import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:resurgence/authentication/account.dart';
import 'package:resurgence/authentication/token.dart';
import 'package:resurgence/network/client.dart';

class AuthenticationService {
  final _AuthenticationClient _client;
  final FirebaseAnalytics analytics;

  AuthenticationService(Client client, {this.analytics})
      : _client = _AuthenticationClient(client);

  Future<Token> login(String username, String password) {
    return _client.login(username, password).then((value) {
      analytics?.logLogin(loginMethod: 'email');
      return value;
    });
  }

  Future<Account> createAccount(String email, String password) {
    return _client.createAccount(email, password).then((value) {
      analytics?.logSignUp(signUpMethod: 'email');
      return value;
    });
  }

  Future<Token> oauth2Login(String provider, String token, String email) {
    return _client.oauth2Login(provider, token).then((value) {
      analytics?.logLogin(loginMethod: provider);
      return value;
    });
  }

  Future<void> pushToken(String token) => _client.pushToken(token);
}

class _AuthenticationClient {
  final Client _client;

  _AuthenticationClient(this._client);

  Future<Token> login(String username, String password) {
    return _client.post('login', data: {
      'username': username,
      'password': password,
    }).then((response) => Token.fromJson(response.data));
  }

  Future<Token> oauth2Login(String provider, String token) {
    return _client.post('security/oauth2/$provider', data: {
      'token': token
    }).then((response) => Token.fromJson(response.data));
  }

  Future<Account> createAccount(String email, String password) {
    return _client.post('account', data: {
      'email': email,
      'password': password,
    }).then((response) => Account.fromJson(response.data));
  }

  Future<void> pushToken(String token) =>
      _client.patch('account/push-token', data: {'token': token});
}
