import 'dart:async';
import 'dart:math';

import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/bank/bank.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/network/util.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class InterestRateState extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  set value(int value) {
    _value = value;
    notifyListeners();
  }
}

class InterestRatesWidget extends StatefulWidget {
  @override
  _InterestRatesWidgetState createState() => _InterestRatesWidgetState();
}

class _InterestRatesWidgetState extends State<InterestRatesWidget> {
  Future<List<InterestRate>> _future;
  BankService _service;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _service = context.read<BankService>();
    _future = _service.interestRates();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _future = _service.interestRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingFutureBuilder<List<InterestRate>>(
      future: _future,
      onError: this._refresh,
      builder: (context, snapshot) {
        var interestRates = snapshot.data;
        return Consumer<InterestRateState>(
          builder: (context, state, child) {
            int value = state.value;

            var selectedInterestRate = interestRates.firstWhere((e) {
              return e.min <= value && e.max >= value;
            }, orElse: () => null);
            if (selectedInterestRate != null) {
              var index = interestRates.indexOf(selectedInterestRate);
              _scrollController.animateTo(
                _findOffset(interestRates.length, index),
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: interestRates
                    .map((e) => _InterestRateCard(
                          e,
                          active: e == selectedInterestRate,
                        ))
                    .toList(growable: false),
              ),
            );
          },
        );
      },
    );
  }

  double _findOffset(int total, int index) {
    var viewport = _scrollController.position.viewportDimension;
    var maxExtent = _scrollController.position.maxScrollExtent;
    var fullWidth = maxExtent + viewport;
    var singleWith = fullWidth / total;
    var offset = (viewport - singleWith) / 2;

    return max(
        min(
          (index * singleWith) - offset,
          _scrollController.position.maxScrollExtent,
        ),
        0);
  }
}

class _InterestRateCard extends StatelessWidget {
  final InterestRate _interestRate;
  final bool active;

  const _InterestRateCard(
    this._interestRate, {
    Key key,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      child: Card(
        color: active ? Colors.green[800] : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '${_interestRate.ratio * 100}%',
                style: Theme.of(context).textTheme.headline5,
              ),
              Column(
                children: [
                  Text(Money.format(_interestRate.min)),
                  const SizedBox(width: 4.0),
                  Text(Money.format(_interestRate.max)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InterestWidget extends StatefulWidget {
  @override
  _InterestWidgetState createState() => _InterestWidgetState();
}

class _InterestWidgetState extends State<InterestWidget> {
  Future<CurrentInterest> _future;
  BankService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<BankService>();
    _future = _service.currentInterest();
  }

  void _refresh() {
    setState(() {
      _future = _service.currentInterest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentInterest>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          if (checkHttpResponseCode(snapshot.error, 404)) {
            return _InterestFormWidget(
              onComplete: this._refresh,
            );
          }
          return RefreshOnErrorWidget(
            onPressed: this._refresh,
          );
        }
        return _CurrentInterestWidget(snapshot.data);
      },
    );
  }
}

class _InterestFormWidget extends StatefulWidget {
  final Function onComplete;

  const _InterestFormWidget({
    Key key,
    this.onComplete,
  }) : super(key: key);

  @override
  __InterestFormWidgetState createState() => __InterestFormWidgetState();
}

class __InterestFormWidgetState extends State<_InterestFormWidget> {
  final _interestMoneyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _interestMoneyController.addListener(() {
      var textValue = _interestMoneyController.text.trim();
      if (textValue.isNotEmpty && int.tryParse(textValue) != null) {
        var state = context.read<InterestRateState>();
        state.value = int.parse(textValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Row(
          children: [
            SizedBox(width: 8.0),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration.collapsed(hintText: S.money),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                controller: _interestMoneyController,
                validator: (value) {
                  if (value.isEmpty) return S.validationRequired;
                  if (int.tryParse(value) == null) return S.integerRequired;
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.0),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.zero,
              color: Colors.green[700],
              child: Text(S.interest),
              onPressed: () {
                if (!_formKey.currentState.validate())
                  return null; // form is not valid

                FocusScope.of(context).nextFocus();

                return context
                    .read<BankService>()
                    .interest(int.parse(_interestMoneyController.text))
                    .then((_) => widget.onComplete())
                    .catchError((e) => ErrorHandler.showError(context, e));
              },
            ),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}

class _CurrentInterestWidget extends StatefulWidget {
  final CurrentInterest _interest;

  const _CurrentInterestWidget(
    this._interest, {
    Key key,
  }) : super(key: key);

  @override
  __CurrentInterestWidgetState createState() => __CurrentInterestWidgetState();
}

class __CurrentInterestWidgetState extends State<_CurrentInterestWidget> {
  Duration _duration;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _duration = Duration(milliseconds: widget._interest.left);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds < 1) {
        setState(() => _duration = Duration.zero);
        timer.cancel();
      }
      setState(() {
        return _duration = Duration(
          milliseconds: _duration.inMilliseconds - 1000,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // todo can add deposit info
              Text(
                Money.format(widget._interest.amount),
                style: Theme.of(context).textTheme.headline5,
              ),
              Divider(thickness: 2.0),
              Text(S.timeToLeftToInterestComplete),
              Text(
                prettyDuration(
                  _duration,
                  locale: const TurkishDurationLocale(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
