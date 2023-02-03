import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/reservation.dart';

class ReservationsListCubit extends Cubit<List<Reservation>> {
  List<Reservation> _dbList = [];
  late NeatTipDatabase _db;
  ReservationsListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    _db = db;
  }

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var transactions in newData) {
      await _db.reservationsDao.insertReservation(transactions);
    }
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.reservationsDao.findAllReservation();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Reservation> list) {
    emit(list);
  }

  Reservation findByIndex(int index) {
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

  void updateByIndex(int index, Reservation newReservation) {
    state[index] = newReservation;
    emit([...state]);
  }

  void updateById(String id, Reservation newReservation) {
    final listIndex =
        state.indexWhere((Reservation reservation) => reservation.id == id);
    state[listIndex] = newReservation;
    emit([...state]);
  }

  void addReservation(Reservation reservation) {
    emit([...state, reservation]);
  }
}
