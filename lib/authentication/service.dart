import 'package:resurgence/authentication/account.dart';
import 'package:resurgence/authentication/token.dart';
import 'package:resurgence/network/client.dart';

class AuthenticationService {
  final _AuthenticationClient _client;

  AuthenticationService(Client client)
      : _client = _AuthenticationClient(client) {
    print('AuthenticationService created');
  }

  Future<Token> login(String username, String password) {
    return _client.login(username, password);
  }

  Future<Account> createAccount(String email, String password) {
    return _client.createAccount(email, password);
  }

  Future<Token> oauth2Login(String provider, String token) {
    return _client.oauth2Login(provider, token);
  }
}

class _AuthenticationClient {
  final Client _client;

  _AuthenticationClient(this._client) {
    print('AuthenticationClient created');
  }

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
}
