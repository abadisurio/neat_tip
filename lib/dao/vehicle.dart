// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:neat_tip/models/vehicle.dart';

@dao
abstract class VehicleDao {
  @Query('SELECT * FROM Vehicle')
  Future<List<Vehicle>> findAllVehicle();

  @Query('SELECT * FROM Vehicle WHERE id = :id')
  Stream<Vehicle?> findVehicleById(int id);

  @insert
  Future<void> insertVehicle(Vehicle vehicle);

  // @Query('DELETE FROM Vehicle')
  // @insert
  // Future<void> dropAndPushVehicleList(List<Vehicle> vehicle);
}
