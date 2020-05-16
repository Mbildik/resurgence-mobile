import 'package:flutter/material.dart';
import 'package:resurgence/authentication/credentials.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/button.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

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
                margin(16),
                forgotPasswordButton(),
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

  Widget forgotPasswordButton() {
    return abstractButton(
      S.sendEmail,
      () => Future.delayed(Duration(seconds: 1)).whenComplete(() {
        Navigator.pop<Credential>(
          context,
          Credential(
            emailController.text,
            null,
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
