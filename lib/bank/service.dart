import 'package:resurgence/bank/bank.dart';
import 'package:resurgence/network/client.dart';

class BankService {
  final _BankClient _client;

  BankService(Client client) : _client = _BankClient(client);

  Future<BankAccount> account() {
    return _client.account();
  }

  Future<void> deposit(int amount) {
    return _client.deposit(amount);
  }

  Future<void> withdraw(int amount) {
    return _client.withdraw(amount);
  }

  Future<List<BankTransactions>> transactions() {
    return _client.transactions();
  }
}

class _BankClient {
  final Client _client;

  _BankClient(this._client);

  Future<BankAccount> account() {
    return _client
        .get('bank/account')
        .then((response) => BankAccount.fromJson(response.data));
  }

  Future<void> deposit(int amount) {
    return _client.post('bank/account/$amount');
  }

  Future<void> withdraw(int amount) {
    return _client.delete('bank/account/$amount');
  }

  Future<List<BankTransactions>> transactions() {
    return _client.get('bank/transactions').then((response) {
      return (response.data as List)
          .map((e) => BankTransactions.fromJson(e))
          .toList(growable: false);
    });
  }
}
