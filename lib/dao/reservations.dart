// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:neat_tip/models/reservation.dart';

@dao
abstract class ReservationsDao {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> findAllReservation();

  @Query('SELECT * FROM Reservation WHERE id = :id')
  Stream<Reservation?> findReservationById(int id);

  @insert
  Future<void> insertReservation(Reservation reservation);
}
