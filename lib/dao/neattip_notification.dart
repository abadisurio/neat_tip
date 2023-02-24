// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:neat_tip/models/neattip_notification.dart';

@dao
abstract class NeatTipNotificationsDao {
  @Query('SELECT * FROM NeatTipNotification')
  Future<List<NeatTipNotification>> findAllNotifications();

  @Query('SELECT * FROM NeatTipNotification WHERE id = :id')
  Stream<NeatTipNotification?> findNeatTipNotificationById(int id);

  @insert
  Future<void> insertNotification(NeatTipNotification reservation);

  @delete
  Future<void> removeNotification(NeatTipNotification vehicle);

  @Query('DELETE FROM NeatTipNotification')
  Future<void> flushAllNotification();
}
