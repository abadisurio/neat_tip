// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:neat_tip/models/transactions.dart';

@dao
abstract class TransactionsDao {
  @Query('SELECT * FROM Transactions')
  Future<List<Transactions>> findAllTransactions();

  @Query('SELECT * FROM Transactions WHERE id = :id')
  Stream<Transactions?> findTransactionsById(int id);

  @insert
  Future<void> insertTransactions(Transactions transactions);
}
