// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorNeatTipDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  // ignore: library_private_types_in_public_api
  static _$NeatTipDatabaseBuilder databaseBuilder(String name) =>
      _$NeatTipDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  // ignore: library_private_types_in_public_api
  static _$NeatTipDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$NeatTipDatabaseBuilder(null);
}

class _$NeatTipDatabaseBuilder {
  _$NeatTipDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$NeatTipDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$NeatTipDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<NeatTipDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$NeatTipDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$NeatTipDatabase extends NeatTipDatabase {
  _$NeatTipDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  VehicleDao? _vehicleDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Vehicle` (`id` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `plate` TEXT NOT NULL, `brand` TEXT NOT NULL, `model` TEXT NOT NULL, `ownerName` TEXT NOT NULL, `imgSrcPhotos` TEXT NOT NULL, `wheel` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VehicleDao get vehicleDao {
    return _vehicleDaoInstance ??= _$VehicleDao(database, changeListener);
  }
}

class _$VehicleDao extends VehicleDao {
  _$VehicleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _vehicleInsertionAdapter = InsertionAdapter(
            database,
            'Vehicle',
            (Vehicle item) => <String, Object?>{
                  'id': item.id,
                  'createdAt': item.createdAt,
                  'ownerId': item.ownerId,
                  'plate': item.plate,
                  'brand': item.brand,
                  'model': item.model,
                  'ownerName': item.ownerName,
                  'imgSrcPhotos': item.imgSrcPhotos,
                  'wheel': item.wheel
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Vehicle> _vehicleInsertionAdapter;

  @override
  Future<List<Vehicle>> findAllVehicle() async {
    return _queryAdapter.queryList('SELECT * FROM Vehicle',
        mapper: (Map<String, Object?> row) => Vehicle(
            createdAt: row['createdAt'] as String,
            id: row['id'] as String,
            ownerId: row['ownerId'] as String,
            plate: row['plate'] as String,
            brand: row['brand'] as String,
            model: row['model'] as String,
            ownerName: row['ownerName'] as String,
            imgSrcPhotos: row['imgSrcPhotos'] as String,
            wheel: row['wheel'] as int));
  }

  @override
  Stream<Vehicle?> findVehicleById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Vehicle WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Vehicle(
            createdAt: row['createdAt'] as String,
            id: row['id'] as String,
            ownerId: row['ownerId'] as String,
            plate: row['plate'] as String,
            brand: row['brand'] as String,
            model: row['model'] as String,
            ownerName: row['ownerName'] as String,
            imgSrcPhotos: row['imgSrcPhotos'] as String,
            wheel: row['wheel'] as int),
        arguments: [id],
        queryableName: 'Vehicle',
        isView: false);
  }

  @override
  Future<void> insertVehicle(Vehicle vehicle) async {
    await _vehicleInsertionAdapter.insert(vehicle, OnConflictStrategy.ignore);
  }
}
