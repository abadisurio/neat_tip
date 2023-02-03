// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: library_private_types_in_public_api

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorNeatTipDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$NeatTipDatabaseBuilder databaseBuilder(String name) =>
      _$NeatTipDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
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

  TransactionsDao? _transactionsDaoInstance;

  ReservationsDao? _reservationsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Transactions` (`id` TEXT NOT NULL, `customerUserId` TEXT NOT NULL, `timeRequested` TEXT NOT NULL, `timeFinished` TEXT, `value` INTEGER, `service` TEXT, `status` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` TEXT NOT NULL, `spotId` TEXT NOT NULL, `hostUserId` TEXT NOT NULL, `customerUserId` TEXT NOT NULL, `timeCheckedIn` TEXT, `timeCheckedOut` TEXT, `note` TEXT, `charge` INTEGER, `status` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VehicleDao get vehicleDao {
    return _vehicleDaoInstance ??= _$VehicleDao(database, changeListener);
  }

  @override
  TransactionsDao get transactionsDao {
    return _transactionsDaoInstance ??=
        _$TransactionsDao(database, changeListener);
  }

  @override
  ReservationsDao get reservationsDao {
    return _reservationsDaoInstance ??=
        _$ReservationsDao(database, changeListener);
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
    await _vehicleInsertionAdapter.insert(vehicle, OnConflictStrategy.abort);
  }
}

class _$TransactionsDao extends TransactionsDao {
  _$TransactionsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _transactionsInsertionAdapter = InsertionAdapter(
            database,
            'Transactions',
            (Transactions item) => <String, Object?>{
                  'id': item.id,
                  'customerUserId': item.customerUserId,
                  'timeRequested': item.timeRequested,
                  'timeFinished': item.timeFinished,
                  'value': item.value,
                  'service': item.service,
                  'status': item.status
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Transactions> _transactionsInsertionAdapter;

  @override
  Future<List<Transactions>> findAllTransactions() async {
    return _queryAdapter.queryList('SELECT * FROM Transactions',
        mapper: (Map<String, Object?> row) => Transactions(
            id: row['id'] as String,
            customerUserId: row['customerUserId'] as String,
            service: row['service'] as String?,
            timeRequested: row['timeRequested'] as String,
            timeFinished: row['timeFinished'] as String?,
            value: row['value'] as int?,
            status: row['status'] as String?));
  }

  @override
  Stream<Transactions?> findTransactionsById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Transactions WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Transactions(
            id: row['id'] as String,
            customerUserId: row['customerUserId'] as String,
            service: row['service'] as String?,
            timeRequested: row['timeRequested'] as String,
            timeFinished: row['timeFinished'] as String?,
            value: row['value'] as int?,
            status: row['status'] as String?),
        arguments: [id],
        queryableName: 'Transactions',
        isView: false);
  }

  @override
  Future<void> insertTransactions(Transactions transactions) async {
    await _transactionsInsertionAdapter.insert(
        transactions, OnConflictStrategy.abort);
  }
}

class _$ReservationsDao extends ReservationsDao {
  _$ReservationsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'spotId': item.spotId,
                  'hostUserId': item.hostUserId,
                  'customerUserId': item.customerUserId,
                  'timeCheckedIn': item.timeCheckedIn,
                  'timeCheckedOut': item.timeCheckedOut,
                  'note': item.note,
                  'charge': item.charge,
                  'status': item.status
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  @override
  Future<List<Reservation>> findAllReservation() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as String,
            spotId: row['spotId'] as String,
            hostUserId: row['hostUserId'] as String,
            customerUserId: row['customerUserId'] as String,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?,
            charge: row['charge'] as int?,
            status: row['status'] as String?));
  }

  @override
  Stream<Reservation?> findReservationById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Reservation WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as String,
            spotId: row['spotId'] as String,
            hostUserId: row['hostUserId'] as String,
            customerUserId: row['customerUserId'] as String,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?,
            charge: row['charge'] as int?,
            status: row['status'] as String?),
        arguments: [id],
        queryableName: 'Reservation',
        isView: false);
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }
}
