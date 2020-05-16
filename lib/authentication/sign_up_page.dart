import 'package:flutter/material.dart';
import 'package:resurgence/authentication/credentials.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/button.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                signUpButton(),
              ],
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

  Widget signUpButton() {
    return abstractButton(
      S.signUp,
      () => Future.delayed(Duration(seconds: 1)).whenComplete(() {
        Navigator.pop<Credential>(
          context,
          Credential(
            emailController.text,
            passwordController.text,
          ),
        );
        setState(() => _loading = false);
      }),
    );
  }

  Widget abstractButton(String text, Function onPressed) {
    return Button(
      enabled: !_loading,
      onPressed: () {
        if (!_formKey.currentState.validate()) return; // form is not valid

        FocusScope.of(context).unfocus();
        setState(() => _loading = true);
        return onPressed();
      },
      child: Text(text),
    );
  }
}
