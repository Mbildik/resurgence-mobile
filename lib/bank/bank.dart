import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/error_handler.dart';

class BankAccount {
  int amount;

  BankAccount({this.amount});

  BankAccount.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
  }
}

class BankTransactions {
  String time;
  int change;
  bool increased;

  BankTransactions({this.time, this.change, this.increased});

  BankTransactions.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    change = json['change'];
    increased = json['increased'];
  }
}

enum Transactions { account, interest, transfer }

class BankPage extends StatefulWidget {
  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  Transactions _transactions = Transactions.account;

  void _updateTransactions(Transactions transactions) {
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.bank),
        actions: Transactions.values.map((e) {
          switch (e) {
            case Transactions.interest:
              return _transactionsButton(
                  e, Icon(Icons.attach_money), S.interest);
            case Transactions.transfer:
              return _transactionsButton(e, Icon(Icons.send), S.transfer);
            case Transactions.account:
            default:
              return _transactionsButton(
                  e, Icon(Icons.account_balance), S.bankAccount);
          }
        }).toList(growable: false),
      ),
      body: Builder(
        builder: (context) {
          switch (_transactions) {
            case Transactions.interest:
              return InterestPage();
            case Transactions.transfer:
              return Container();
            case Transactions.account:
            default:
              return BankAccountWidget();
          }
        },
      ),
    );
  }

  Widget _transactionsButton(Transactions e, Icon icon, String tooltip) {
    bool isSelected = _transactions == e;
    return IconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed:
          isSelected ? null : () => setState(() => this._updateTransactions(e)),
    );
  }
}

class BankAccountWidget extends StatefulWidget {
  @override
  _BankAccountWidgetState createState() => _BankAccountWidgetState();
}

class _BankAccountWidgetState extends State<BankAccountWidget> {
  final _formKey = GlobalKey<FormState>();
  final moneyController = TextEditingController();

  Future<BankAccount> bankAccountFuture;
  Future<List<BankTransactions>> bankTransactionsFuture;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    var bankService = context.read<BankService>();
    bankAccountFuture = bankService.account();
    bankTransactionsFuture = bankService.transactions();
    context
        .read<PlayerService>()
        .info()
        .then((player) => context.read<PlayerState>().updatePlayer(player));
  }

  _refreshAccount() {
    var bankService = context.read<BankService>();
    setState(() {
      bankAccountFuture = bankService.account();
      bankTransactionsFuture = bankService.transactions();
    });
    context
        .read<PlayerService>()
        .info()
        .then((player) => context.read<PlayerState>().updatePlayer(player));
  }

  @override
  Widget build(BuildContext context) {
    moneyController.text = ''; // reset text field

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder<BankAccount>(
              future: bankAccountFuture,
              builder: (context, snapshot) {
                if (loading ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget();
                } else if (snapshot.hasError) {
                  var error = snapshot.error;
                  if (error is DioError && error.response.statusCode == 404) {
                    return accountBalance(BankAccount(amount: 0));
                  }
                  return errorWidget();
                }

                var bankAccount = snapshot.data;
                return accountBalance(bankAccount);
              },
            ),
            moneyTextField(),
            footer(context),
            Divider(),
            Expanded(
              child: FutureBuilder<List<BankTransactions>>(
                future: bankTransactionsFuture,
                builder: (context, snapshot) {
                  if (loading ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  } else if (snapshot.hasError) {
                    return errorWidget();
                  }

                  var bankTransactions = snapshot.data;

                  return ListView.builder(
                    primary: false,
                    itemCount: bankTransactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      var bankTransaction = bankTransactions[index];
                      return bankTransactionListTile(bankTransaction);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bankTransactionListTile(BankTransactions bankTransaction) {
    return ListTile(
      leading: Icon(
        bankTransaction.increased ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        color: bankTransaction.increased ? Colors.green : Colors.red,
      ),
      title: Text(Money.format(bankTransaction.change)),
      subtitle: Text(
        // todo format locale
        DateFormat('y-MM-dd HH:mm:ss').format(
          DateTime.parse(bankTransaction.time).toLocal(),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidget() {
    return Center(
      child: Column(
        children: <Widget>[
          Button(
            child: Text(S.reload),
            onPressed: () => this._refreshAccount(),
          ),
          Text(S.errorOccurred),
        ],
      ),
    );
  }

  Widget title(BuildContext context) {
    return Text(
      S.bankTitle,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  Widget accountBalance(BankAccount bankAccount) {
    return Table(
      children: [
        TableRow(
          children: [
            Text(
              S.bankBalance,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(Money.format(bankAccount.amount)),
          ],
        ),
        TableRow(
          children: [
            SizedBox(height: 8.0),
            SizedBox(height: 8.0),
          ],
        ),
        TableRow(
          children: [
            Text(
              S.currentBalance,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Consumer<PlayerState>(
              builder: (BuildContext context, PlayerState state, Widget child) {
                return Text(Money.format(state.player.balance));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget footer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            color: Colors.red[700],
            child: Text(S.withdraw),
            onPressed: () {
              if (!_formKey.currentState.validate())
                return null; // form is not valid

              FocusScope.of(context).nextFocus();
              setState(() => loading = true);

              return context
                  .read<BankService>()
                  .withdraw(int.parse(moneyController.text))
                  .then((_) => _refreshAccount())
                  .catchError((e) => ErrorHandler.showError(context, e))
                  .whenComplete(() => setState(() => loading = false));
            },
          ),
          RaisedButton(
            color: Colors.green,
            child: Text(S.deposit),
            onPressed: () {
              if (!_formKey.currentState.validate())
                return null; // form is not valid

              FocusScope.of(context).nextFocus();
              setState(() => loading = true);

              return context
                  .read<BankService>()
                  .deposit(int.parse(moneyController.text))
                  .then((_) => _refreshAccount())
                  .catchError((e) => ErrorHandler.showError(context, e))
                  .whenComplete(() => setState(() => loading = false));
            },
          ),
        ],
      ),
    );
  }

  Widget moneyTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.money),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      controller: moneyController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        if (int.tryParse(value) == null) return S.integerRequired;
        return null;
      },
    );
  }
}

class InterestPage extends StatefulWidget {
  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  @override
  Widget build(BuildContext context) {
    return Text('Sa interest here!');
  }
}

class BankPageRoute<T> extends MaterialPageRoute<T> {
  BankPageRoute() : super(builder: (BuildContext context) => new BankPage());
}
