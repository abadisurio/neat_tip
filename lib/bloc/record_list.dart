import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/record.dart';

class RecordListCubit extends Cubit<List<Record>> {
  List<Record> _dbList = [];
  late NeatTipDatabase _db;
  RecordListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    _db = db;
  }

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var record in newData) {
      await _db.recordDao.insertRecord(record);
    }
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.recordDao.findAllRecord();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Record> list) {
    emit(list);
  }

  Record findByIndex(int index) {
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

  void updateByIndex(int index, Record newRecord) {
    state[index] = newRecord;
    emit([...state]);
  }

  void updateById(String id, Record newRecord) {
    final listIndex = state.indexWhere((Record record) => record.id == id);
    state[listIndex] = newRecord;
    emit([...state]);
  }

  void addRecord(Record record) {
    emit([...state, record]);
  }
}
