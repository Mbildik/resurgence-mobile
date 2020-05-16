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
}
