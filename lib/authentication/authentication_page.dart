import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/error_handler.dart';

class AuthenticationPage extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    A.applicationLogo,
                    width: 100.0,
                    height: 100.0,
                  ),
                  Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
                  Text(
                    S.applicationTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline2
                        .copyWith(color: Colors.white),
                  ),
                  Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
                  Text(
                    S.applicationDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CustomButton(
                  child: Text(S.signUpEmail),
                  onPressed: () => Navigator.push(
                    context,
                    _SingUpPageRoute(),
                  ),
                ),
                Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
                _CustomButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        A.googleLogo,
                        width: 18.0,
                        height: 18.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        S.signUpGoogle,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                  splashColor: Colors.grey[400],
                  color: Colors.white,
                  onPressed: () => signInWithGoogle(context),
                ),
                Container(margin: EdgeInsets.symmetric(vertical: 16.0)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FlatButton(
                    onPressed: () => Navigator.push(
                      context,
                      _LoginPageRoute(),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: S.alreadyHaveAnAccount,
                        children: [
                          TextSpan(text: ' '),
                          TextSpan(
                            text: S.signIn,
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(decoration: TextDecoration.underline),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void signInWithGoogle(BuildContext context) async {
    final account = await googleSignIn.signIn();
    if (account == null) return;

    final authentication = await account.authentication;
    if (authentication == null) return;

    return context
        .read<AuthenticationService>()
        .oauth2Login('google', authentication.accessToken)
        .then((token) => context.read<AuthenticationState>().login(token))
        .catchError((e) => ErrorHandler.showError(context, e));
  }
}

typedef ActionCallback = Future Function(
  BuildContext context,
  String email,
  String password,
);

class _LoginPage extends StatefulWidget {
  const _LoginPage({
    Key key,
    this.header,
    this.description,
    this.actionText,
    this.secondActionText,
    this.secondActionTextDescription,
    this.onAction,
    this.onSecondAction,
    this.forgotPassword = true,
  }) : super(key: key);

  final String header;
  final String description;
  final String actionText;
  final String secondActionText;
  final String secondActionTextDescription;
  final ActionCallback onAction;
  final VoidCallback onSecondAction;
  final bool forgotPassword;

  @override
  __LoginPageState createState() => __LoginPageState();
}

class __LoginPageState extends State<_LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(
          header: widget.header,
          description: widget.description,
        ),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CustomTextFormField(
                context: context,
                label: S.email,
                inputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                controller: emailController,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
              _CustomTextFormField(
                context: context,
                label: S.password,
                inputType: TextInputType.visiblePassword,
                inputAction: TextInputAction.done,
                controller: passwordController,
                obscureText: true,
                onFieldSubmitted: (_) => onSubmit(context),
              ),
              if (widget.forgotPassword)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FlatButton(
                      onPressed: () {},
                      child: Text(S.passwordForgot),
                    ),
                  ),
                ),
              Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
              _CustomButton(
                child: Text(widget.actionText),
                onPressed: loading ? null : () => onSubmit(context),
              ),
              Container(margin: EdgeInsets.symmetric(vertical: 8.0)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FlatButton(
                  onPressed: () => widget.onSecondAction(),
                  child: RichText(
                    text: TextSpan(
                      text: widget.secondActionTextDescription,
                      children: [
                        TextSpan(text: ' '),
                        TextSpan(
                          text: widget.secondActionText,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(decoration: TextDecoration.underline),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void onSubmit(BuildContext context) {
    if (loading) return;
    if (!formKey.currentState.validate()) return;

    setState(() => loading = true);

    widget
        .onAction(
          context,
          emailController.text,
          passwordController.text,
        )
        .whenComplete(() => setState(() => loading = false));
  }
}

class _CustomButton extends StatelessWidget {
  const _CustomButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.color,
    this.highlightColor,
    this.splashColor,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final Color highlightColor;
  final Color splashColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RaisedButton(
        highlightColor: highlightColor ?? highlightColor,
        splashColor: splashColor ?? splashColor,
        color: color ?? color,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: child,
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatelessWidget {
  const _CustomTextFormField({
    Key key,
    @required this.context,
    @required this.label,
    @required this.inputType,
    @required this.inputAction,
    @required this.controller,
    this.obscureText = false,
    this.onFieldSubmitted,
  }) : super(key: key);

  final BuildContext context;
  final String label;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final TextEditingController controller;
  final bool obscureText;
  final ValueChanged<String> onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.all(4.0),
          ),
          keyboardType: inputType,
          textInputAction: inputAction,
          controller: controller,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          validator: (value) {
            if (value.isEmpty) return S.validationRequired;
            return null;
          },
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String header;
  final String description;

  const _Title({Key key, this.header, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}

class AuthenticationPageRoute<T> extends MaterialPageRoute<T> {
  AuthenticationPageRoute() : super(builder: (context) => AuthenticationPage());
}

class _LoginPageRoute<T> extends MaterialPageRoute<T> {
  _LoginPageRoute()
      : super(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: CloseButton(),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: _LoginPage(
                  header: S.signInPageTitle,
                  description: S.signInPageDescription,
                  actionText: S.signIn,
                  secondActionText: S.signUp,
                  secondActionTextDescription: S.doNotHaveAnAccount,
                  forgotPassword: true,
                  onAction: (context, email, password) {
                    return context
                        .read<AuthenticationService>()
                        .login(email, password)
                        .then((token) =>
                            context.read<AuthenticationState>().login(token))
                        .then((_) => Navigator.pop(context))
                        .catchError((e) => ErrorHandler.showError(context, e));
                  },
                  onSecondAction: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      _SingUpPageRoute(),
                    );
                  },
                ),
              ),
            ),
          ),
        );
}

class _SingUpPageRoute<T> extends MaterialPageRoute<T> {
  _SingUpPageRoute()
      : super(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: CloseButton(),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: _LoginPage(
                  header: S.signUpPageTitle,
                  description: S.signUpPageDescription,
                  actionText: S.signUp,
                  secondActionText: S.signIn,
                  secondActionTextDescription: S.alreadyHaveAnAccount,
                  forgotPassword: false,
                  onAction: (context, email, password) {
                    var authenticationService =
                        context.read<AuthenticationService>();
                    return authenticationService
                        .createAccount(email, password)
                        .then((account) =>
                            authenticationService.login(email, password))
                        .then((token) =>
                            context.read<AuthenticationState>().login(token))
                        .then((_) => Navigator.pop(context))
                        .catchError((e) => ErrorHandler.showError(context, e));
                  },
                  onSecondAction: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      _LoginPageRoute(),
                    );
                  },
                ),
              ),
            ),
          ),
        );
}
