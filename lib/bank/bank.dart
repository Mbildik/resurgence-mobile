import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/duration.dart';
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

class InterestRate {
  int min;
  int max;
  double ratio;

  InterestRate({this.min, this.max, this.ratio});

  InterestRate.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
    ratio = json['ratio'];
  }
}

class CurrentInterest {
  int amount;
  ISO8601Duration duration;

  CurrentInterest({this.amount, this.duration});

  CurrentInterest.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    duration = ISO8601Duration(json['duration']);
  }
}

class InterestResult {
  int amount;

  InterestResult({this.amount});

  InterestResult.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
  }
}

class BankTransfer {
  String from;
  String to;
  int amount;
  String description;
  String time;
  String direction;

  BankTransfer(
      {this.from,
      this.to,
      this.amount,
      this.description,
      this.time,
      this.direction});

  BankTransfer.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    amount = json['amount'];
    description = json['description'];
    time = json['time'];
    direction = json['direction'];
  }
}

enum Transactions { account, interest, transfer }

class BankPage extends StatefulWidget {
  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  Transactions _transactions = Transactions.account;

  @override
  Widget build(BuildContext context) {
    var title;

    switch (_transactions) {
      case Transactions.interest:
        title = S.interest;
        break;
      case Transactions.transfer:
        title = S.transfer;
        break;
      case Transactions.account:
      default:
        title = S.bankAccount;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int selected) {
          setState(() => _transactions = Transactions.values[selected]);
        },
        currentIndex: _transactions.index,
        items: [
          BottomNavigationBarItem(
            title: Text(S.bankAccount),
            icon: Icon(Icons.account_balance),
          ),
          BottomNavigationBarItem(
            title: Text(S.interest),
            icon: Icon(Icons.attach_money),
          ),
          BottomNavigationBarItem(
            title: Text(S.transfer),
            icon: Icon(Icons.send),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          switch (_transactions) {
            case Transactions.interest:
              return InterestPage();
            case Transactions.transfer:
              return TransferWidget();
            case Transactions.account:
            default:
              return BankAccountWidget();
          }
        },
      ),
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
                  if (error is DioError &&
                      error.type == DioErrorType.RESPONSE &&
                      error.response.statusCode == 404) {
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
  final _formKey = GlobalKey<FormState>();
  final moneyController = TextEditingController();

  Future<List<InterestRate>> interestRateFuture;
  Future<CurrentInterest> currentInterestFuture;

  @override
  void initState() {
    super.initState();
    interestRateFuture = context.read<BankService>().interestRates();
    currentInterestFuture = context.read<BankService>().currentInterest();
  }

  void _refresh() {
    setState(() {
      interestRateFuture = context.read<BankService>().interestRates();
      currentInterestFuture = context.read<BankService>().currentInterest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            interestRateTable(),
            Divider(),
            interestCard(context),
          ],
        ),
      ),
    );
  }

  Widget interestRateTable() {
    return FutureBuilder<List<InterestRate>>(
      future: interestRateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        } else if (snapshot.hasError) {
          return errorWidget();
        }

        var interestRates = snapshot.data;

        List<TableRow> tableChildren = [];

        tableChildren.add(
          TableRow(
            children: [
              Text(
                S.min,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                S.max,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                S.interest,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

        tableChildren.add(
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            children: [
              SizedBox(height: 8.0),
              SizedBox(height: 8.0),
              SizedBox(height: 8.0),
            ],
          ),
        );

        tableChildren.add(
          TableRow(
            children: [
              SizedBox(height: 8.0),
              SizedBox(height: 8.0),
              SizedBox(height: 8.0),
            ],
          ),
        );

        tableChildren.addAll(interestRates.map((e) {
          return TableRow(
            children: [
              Text(
                Money.format(e.min),
                textAlign: TextAlign.end,
              ),
              Text(
                Money.format(e.max),
                textAlign: TextAlign.end,
              ),
              Text(
                '${e.ratio * 100}%',
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(growable: false));

        return Table(
          children: tableChildren,
        );
      },
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
            onPressed: _refresh,
          ),
          Text(S.errorOccurred),
        ],
      ),
    );
  }

  Widget moneyTextField(BuildContext context) {
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

  Widget footer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: RaisedButton(
        color: Colors.green,
        child: Text(S.interest),
        onPressed: () {
          if (!_formKey.currentState.validate())
            return null; // form is not valid

          FocusScope.of(context).nextFocus();

          return context
              .read<BankService>()
              .interest(int.parse(moneyController.text))
              .catchError((e) => ErrorHandler.showError(context, e))
              .then((_) => this._refresh());
        },
      ),
    );
  }

  Widget interestCard(BuildContext context) {
    return FutureBuilder<CurrentInterest>(
      future: currentInterestFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        } else if (snapshot.hasError) {
          var error = snapshot.error;
          if (error is DioError &&
              error.type == DioErrorType.RESPONSE &&
              error.response.statusCode == 404)
            return Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(S.noActiveInterest),
                      moneyTextField(context),
                      footer(context),
                    ],
                  ),
                ),
              ),
            );

          return errorWidget();
        }

        var currentInterest = snapshot.data;

        return Container(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(S.currentInterest),
                  SizedBox(height: 16.0),
                  Text(Money.format(currentInterest.amount)),
                  SizedBox(height: 8.0),
                  Text(currentInterest.duration.pretty()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TransferWidget extends StatefulWidget {
  @override
  _TransferWidgetState createState() => _TransferWidgetState();
}

class _TransferWidgetState extends State<TransferWidget> {
  final _formKey = GlobalKey<FormState>();
  final toController = TextEditingController();
  final moneyController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<List<BankTransfer>> bankTransferFuture;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    var bankService = context.read<BankService>();
    bankTransferFuture = bankService.transfers();
    context
        .read<PlayerService>()
        .info()
        .then((player) => context.read<PlayerState>().updatePlayer(player));
  }

  _refreshAccount() {
    var bankService = context.read<BankService>();
    setState(() {
      bankTransferFuture = bankService.transfers();
    });
    context
        .read<PlayerService>()
        .info()
        .then((player) => context.read<PlayerState>().updatePlayer(player));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            balanceWidget(),
            playerTextField(),
            moneyTextField(),
            descriptionTextField(),
            footer(context),
            Divider(),
            Expanded(
              child: FutureBuilder<List<BankTransfer>>(
                future: bankTransferFuture,
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
                      return bankTransferListTile(bankTransaction);
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

  Widget bankTransferListTile(BankTransfer bankTransaction) {
    var player = bankTransaction.direction == 'IN'
        ? bankTransaction.from
        : bankTransaction.to;
    return Tooltip(
      message: DateFormat('y-MM-dd HH:mm:ss').format(
        DateTime.parse(bankTransaction.time).toLocal(),
      ),
      child: ListTile(
        leading: Icon(
          bankTransaction.direction == 'IN'
              ? Icons.arrow_drop_up
              : Icons.arrow_drop_down,
          color: bankTransaction.direction == 'IN' ? Colors.green : Colors.red,
        ),
        title: Text(Money.format(bankTransaction.amount)),
        subtitle: Text(bankTransaction.description),
        trailing: Text(player),
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

  Widget balanceWidget() {
    return Table(
      children: [
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
      child: RaisedButton(
        color: Colors.green,
        child: Text(S.transfer),
        onPressed: () {
          if (!_formKey.currentState.validate())
            return null; // form is not valid

          FocusScope.of(context).unfocus();
          setState(() => loading = true);

          return context
              .read<BankService>()
              .transfer(
                toController.text,
                int.parse(moneyController.text),
                description: descriptionController.text,
              )
              .then((_) {
                toController.text = '';
                moneyController.text = '';
                descriptionController.text = '';
                return _refreshAccount();
              })
              .catchError((e) => ErrorHandler.showError(context, e))
              .whenComplete(() => setState(() => loading = false));
        },
      ),
    );
  }

  Widget playerTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.to + ' *'),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      controller: toController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }

  Widget moneyTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.money + ' *'),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      controller: moneyController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        if (int.tryParse(value) == null) return S.integerRequired;
        return null;
      },
    );
  }

  Widget descriptionTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.description),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      controller: descriptionController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
    );
  }
}

class BankPageRoute<T> extends MaterialPageRoute<T> {
  BankPageRoute() : super(builder: (BuildContext context) => new BankPage());
}
