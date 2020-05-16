import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:resurgence/authentication/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationState with ChangeNotifier {
  static const _ACCESS_TOKEN_KEY = 'access_token';
  static const _REFRESH_TOKEN_KEY = 'refresh_token';

  Token _token;

  AuthenticationState() {
    _getToken()
        .then((token) => this.login(token))
        .catchError((e) => log('token fetch error $e. Do nothing!'));
  }

  void login(Token token) {
    if (token == null) return;
    _token = token;
    _saveToken(token);
    notifyListeners();
  }

  void logout() {
    _token = null;
    _removeToken();
    notifyListeners();
  }

  Future<Token> _getToken() {
    return SharedPreferences.getInstance().then((value) {
      var accessToken = value.getString(_ACCESS_TOKEN_KEY);
      var refreshToken = value.getString(_REFRESH_TOKEN_KEY);
      if (accessToken == null || refreshToken == null)
        throw TokenNotFoundError();

      return Token(accessToken: accessToken, refreshToken: refreshToken);
    });
  }

  Future<void> _saveToken(Token token) {
    return SharedPreferences.getInstance().then((value) {
      value.setString(_ACCESS_TOKEN_KEY, token.accessToken);
      value.setString(_REFRESH_TOKEN_KEY, token.refreshToken);
    });
  }

  Future<void> _removeToken() {
    return SharedPreferences.getInstance().then((value) {
      value.remove(_ACCESS_TOKEN_KEY);
      value.remove(_REFRESH_TOKEN_KEY);
    });
  }

  bool get isLoggedIn {
    return _token != null;
  }

  Token get token => _token;
}

class TokenNotFoundError extends Error {}
