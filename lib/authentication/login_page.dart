import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/credentials.dart';
import 'package:resurgence/authentication/forgot_password_page.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/sign_up_page.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/error_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // todo remove text data from controllers
  final emailController = TextEditingController(text: 'admin@localhost');
  final passwordController = TextEditingController(text: '123456789');

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  margin(48),
                  Text(
                    S.applicationTitle,
                    style: Theme.of(context).primaryTextTheme.headline2,
                  ),
                  Text(
                    S.applicationDescription,
                    style: Theme.of(context).primaryTextTheme.headline6,
                  ),
                  margin(48),
                  emailFormField(),
                  margin(8),
                  passwordFormField(),
                  margin(16),
                  GridView.count(
                    primary: false,
                    padding: EdgeInsets.all(16),
                    childAspectRatio: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: <Widget>[
                      loginButton(),
                      loginGoogleButton(),
                      signUpButton(),
                      forgotPasswordButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget margin(double vertical) {
    return Container(margin: EdgeInsets.symmetric(vertical: vertical));
  }

  Widget emailFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.email),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      controller: emailController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }

  Widget passwordFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.password),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }

  Widget loginButton() {
    return abstractButton(
      S.login,
      () => context
          .read<AuthenticationService>()
          .login(emailController.text, passwordController.text)
          .then((value) => context.read<AuthenticationState>().login(value))
          .catchError((e) => ErrorHandler.showError(context, e))
          .whenComplete(() => setState(() => _loading = false)),
    );
  }

  Widget loginGoogleButton() {
    return abstractButton(
      S.loginGoogle,
      () => Future.delayed(Duration(seconds: 1))
          .whenComplete(() => setState(() => _loading = false)),
    );
  }

  Widget signUpButton() {
    return abstractButton(S.signUp, () {
      Navigator.push(context, MaterialPageRoute<Credential>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.signUp),
            ),
            body: SignUpPage(),
          );
        },
      )).then((credential) {
        if (credential == null) return;
        emailController.text = credential.email;
        passwordController.text = credential.password;
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(S.signUpInfo),
          ),
        );
      });
    }, loading: false);
  }

  Widget forgotPasswordButton() {
    return abstractButton(
      S.passwordForgot,
      () {
        Navigator.push(context, MaterialPageRoute<Credential>(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(S.passwordForgot),
              ),
              body: ForgotPasswordPage(),
            );
          },
        )).then((credential) {
          if (credential == null) return;
          emailController.text = credential.email;
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(S.passwordForgotInfo),
            ),
          );
        });
      },
      loading: false,
    );
  }

  Widget abstractButton(String text, Function onPressed, {loading: true}) {
    return Button(
      enabled: !_loading,
      onPressed: () {
        if (!_formKey.currentState.validate()) return; // form is not valid

        FocusScope.of(context).unfocus();
        if (loading) setState(() => _loading = true);
        return onPressed();
      },
      child: Text(text),
    );
  }
}
