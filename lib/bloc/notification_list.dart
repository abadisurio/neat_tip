import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/neattip_notification.dart';

class NotificationListCubit extends Cubit<List<NeatTipNotification>?> {
  NotificationListCubit() : super(null);
  // List<Reservation> _dbList = [];
  late NeatTipDatabase _db;

  void initialize({required NeatTipDatabase localDB}) async {
    _db = localDB;
    await _pullDataFromDB();
    // _load();
  }

  Future<List<NeatTipNotification>> _pullDataFromDB() async {
    final dataDB = await _db.neatTipNotificationsDao.findAllNotifications();
    emit(dataDB);
    return dataDB;
  }

  Future<void> add(NeatTipNotification notif) async {
    await _db.neatTipNotificationsDao.insertNotification(notif);
    emit([...?state, notif]);
  }

  Future<void> remove(NeatTipNotification notif) async {
    final newList = state?.where((element) => element != notif).toList();
    await _db.neatTipNotificationsDao.removeNotification(notif);
    emit([...?newList]);
  }
}
