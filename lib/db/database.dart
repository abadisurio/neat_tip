// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:neat_tip/dao/neattip_notification.dart';
import 'package:neat_tip/dao/reservations.dart';
import 'package:neat_tip/dao/transactions.dart';
import 'package:neat_tip/dao/vehicle.dart';
import 'package:neat_tip/models/neattip_notification.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/models/transactions.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// import 'dao/person_dao.dart';
// import 'entity/person.dart';

part 'database.g.dart'; // the generated code will be there

@Database(
    version: 2,
    entities: [Vehicle, Transactions, Reservation, NeatTipNotification])
abstract class NeatTipDatabase extends FloorDatabase {
  VehicleDao get vehicleDao;
  NeatTipNotificationsDao get neatTipNotificationsDao;
  TransactionsDao get transactionsDao;
  ReservationsDao get reservationsDao;
}
