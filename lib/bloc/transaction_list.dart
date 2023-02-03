import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/transactions.dart';

class TransactionsListCubit extends Cubit<List<Transactions>> {
  List<Transactions> _dbList = [];
  late NeatTipDatabase _db;
  TransactionsListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    _db = db;
  }

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var transactions in newData) {
      await _db.transactionsDao.insertTransactions(transactions);
    }
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.transactionsDao.findAllTransactions();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Transactions> list) {
    emit(list);
  }

  Transactions findByIndex(int index) {
    return state.elementAt(index);
  }

  void removeByIndex(int index) {
    state.removeAt(index);
    emit([...state]);
  }

  void removeById(String id) {
    final newList = state.where((element) => element.id != id).toList();
    emit([...newList]);
  }

  void updateByIndex(int index, Transactions newTransactions) {
    state[index] = newTransactions;
    emit([...state]);
  }

  void updateById(String id, Transactions newTransactions) {
    final listIndex =
        state.indexWhere((Transactions transactions) => transactions.id == id);
    state[listIndex] = newTransactions;
    emit([...state]);
  }

  void addTransactions(Transactions transactions) {
    emit([...state, transactions]);
  }
}
