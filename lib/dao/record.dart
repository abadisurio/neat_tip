// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:neat_tip/models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM Record')
  Future<List<Record>> findAllRecord();

  @Query('SELECT * FROM Record WHERE id = :id')
  Stream<Record?> findRecordById(int id);

  @insert
  Future<void> insertRecord(Record record);
}
