// GENERATED CODE - DO NOT MODIFY BY HAND

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

  RecordDao? _recordDaoInstance;

  NeatTipNotificationsDao? _neatTipNotificationsDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `Vehicle` (`plate` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `ownerId` TEXT NOT NULL, `brand` TEXT NOT NULL, `model` TEXT NOT NULL, `ownerName` TEXT NOT NULL, `imgSrcPhotos` TEXT NOT NULL, `wheel` INTEGER NOT NULL, PRIMARY KEY (`plate`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Record` (`id` TEXT NOT NULL, `plateNumber` TEXT NOT NULL, `imgSrc` TEXT NOT NULL, `timeCheckedIn` TEXT, `timeCheckedOut` TEXT, `note` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Transactions` (`id` TEXT NOT NULL, `customerUserId` TEXT NOT NULL, `timeRequested` TEXT NOT NULL, `timeFinished` TEXT, `value` INTEGER, `service` TEXT, `status` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` TEXT NOT NULL, `spotId` TEXT NOT NULL, `hostUserId` TEXT NOT NULL, `plateNumber` TEXT NOT NULL, `spotName` TEXT, `customerId` TEXT, `timeCheckedIn` TEXT, `timeCheckedOut` TEXT, `note` TEXT, `charge` INTEGER, `status` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `NeatTipNotification` (`createdAt` TEXT NOT NULL, `title` TEXT NOT NULL, `body` TEXT NOT NULL, PRIMARY KEY (`createdAt`))');

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
  RecordDao get recordDao {
    return _recordDaoInstance ??= _$RecordDao(database, changeListener);
  }

  @override
  NeatTipNotificationsDao get neatTipNotificationsDao {
    return _neatTipNotificationsDaoInstance ??=
        _$NeatTipNotificationsDao(database, changeListener);
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
  )   : _queryAdapter = QueryAdapter(database),
        _vehicleInsertionAdapter = InsertionAdapter(
            database,
            'Vehicle',
            (Vehicle item) => <String, Object?>{
                  'plate': item.plate,
                  'createdAt': item.createdAt,
                  'ownerId': item.ownerId,
                  'brand': item.brand,
                  'model': item.model,
                  'ownerName': item.ownerName,
                  'imgSrcPhotos': item.imgSrcPhotos,
                  'wheel': item.wheel
                }),
        _vehicleDeletionAdapter = DeletionAdapter(
            database,
            'Vehicle',
            ['plate'],
            (Vehicle item) => <String, Object?>{
                  'plate': item.plate,
                  'createdAt': item.createdAt,
                  'ownerId': item.ownerId,
                  'brand': item.brand,
                  'model': item.model,
                  'ownerName': item.ownerName,
                  'imgSrcPhotos': item.imgSrcPhotos,
                  'wheel': item.wheel
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Vehicle> _vehicleInsertionAdapter;

  final DeletionAdapter<Vehicle> _vehicleDeletionAdapter;

  @override
  Future<List<Vehicle>> findAllVehicle() async {
    return _queryAdapter.queryList('SELECT * FROM Vehicle',
        mapper: (Map<String, Object?> row) => Vehicle(
            createdAt: row['createdAt'] as String,
            ownerId: row['ownerId'] as String,
            plate: row['plate'] as String,
            brand: row['brand'] as String,
            model: row['model'] as String,
            ownerName: row['ownerName'] as String,
            imgSrcPhotos: row['imgSrcPhotos'] as String,
            wheel: row['wheel'] as int));
  }

  @override
  Future<void> flushAllVehicle() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Vehicle');
  }

  @override
  Future<void> insertVehicle(Vehicle vehicle) async {
    await _vehicleInsertionAdapter.insert(vehicle, OnConflictStrategy.abort);
  }

  @override
  Future<void> removeVehicle(Vehicle vehicle) async {
    await _vehicleDeletionAdapter.delete(vehicle);
  }
}

class _$RecordDao extends RecordDao {
  _$RecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _recordInsertionAdapter = InsertionAdapter(
            database,
            'Record',
            (Record item) => <String, Object?>{
                  'id': item.id,
                  'plateNumber': item.plateNumber,
                  'imgSrc': item.imgSrc,
                  'timeCheckedIn': item.timeCheckedIn,
                  'timeCheckedOut': item.timeCheckedOut,
                  'note': item.note
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Record> _recordInsertionAdapter;

  @override
  Future<List<Record>> findAllRecord() async {
    return _queryAdapter.queryList('SELECT * FROM Record',
        mapper: (Map<String, Object?> row) => Record(
            id: row['id'] as String,
            plateNumber: row['plateNumber'] as String,
            imgSrc: row['imgSrc'] as String,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?));
  }

  @override
  Stream<Record?> findRecordById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Record WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Record(
            id: row['id'] as String,
            plateNumber: row['plateNumber'] as String,
            imgSrc: row['imgSrc'] as String,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?),
        arguments: [id],
        queryableName: 'Record',
        isView: false);
  }

  @override
  Future<void> insertRecord(Record record) async {
    await _recordInsertionAdapter.insert(record, OnConflictStrategy.abort);
  }
}

class _$NeatTipNotificationsDao extends NeatTipNotificationsDao {
  _$NeatTipNotificationsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _neatTipNotificationInsertionAdapter = InsertionAdapter(
            database,
            'NeatTipNotification',
            (NeatTipNotification item) => <String, Object?>{
                  'createdAt': item.createdAt,
                  'title': item.title,
                  'body': item.body
                },
            changeListener),
        _neatTipNotificationDeletionAdapter = DeletionAdapter(
            database,
            'NeatTipNotification',
            ['createdAt'],
            (NeatTipNotification item) => <String, Object?>{
                  'createdAt': item.createdAt,
                  'title': item.title,
                  'body': item.body
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NeatTipNotification>
      _neatTipNotificationInsertionAdapter;

  final DeletionAdapter<NeatTipNotification>
      _neatTipNotificationDeletionAdapter;

  @override
  Future<List<NeatTipNotification>> findAllNotifications() async {
    return _queryAdapter.queryList('SELECT * FROM NeatTipNotification',
        mapper: (Map<String, Object?> row) => NeatTipNotification(
            createdAt: row['createdAt'] as String,
            body: row['body'] as String,
            title: row['title'] as String));
  }

  @override
  Stream<NeatTipNotification?> findNeatTipNotificationById(int id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM NeatTipNotification WHERE id = ?1',
        mapper: (Map<String, Object?> row) => NeatTipNotification(
            createdAt: row['createdAt'] as String,
            body: row['body'] as String,
            title: row['title'] as String),
        arguments: [id],
        queryableName: 'NeatTipNotification',
        isView: false);
  }

  @override
  Future<void> flushAllNotification() async {
    await _queryAdapter.queryNoReturn('DELETE FROM NeatTipNotification');
  }

  @override
  Future<void> insertNotification(NeatTipNotification reservation) async {
    await _neatTipNotificationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> removeNotification(NeatTipNotification vehicle) async {
    await _neatTipNotificationDeletionAdapter.delete(vehicle);
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
                  'plateNumber': item.plateNumber,
                  'spotName': item.spotName,
                  'customerId': item.customerId,
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
            plateNumber: row['plateNumber'] as String,
            spotName: row['spotName'] as String?,
            customerId: row['customerId'] as String?,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?,
            charge: row['charge'] as int?,
            status: row['status'] as String?));
  }

  @override
  Stream<Reservation?> findReservationById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM Reservation WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as String,
            spotId: row['spotId'] as String,
            hostUserId: row['hostUserId'] as String,
            plateNumber: row['plateNumber'] as String,
            spotName: row['spotName'] as String?,
            customerId: row['customerId'] as String?,
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
  Stream<Reservation?> finishReservationById(String id) {
    return _queryAdapter.queryStream(
        'UPDATE Reservation SET status = `finished` WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as String,
            spotId: row['spotId'] as String,
            hostUserId: row['hostUserId'] as String,
            plateNumber: row['plateNumber'] as String,
            spotName: row['spotName'] as String?,
            customerId: row['customerId'] as String?,
            timeCheckedIn: row['timeCheckedIn'] as String?,
            timeCheckedOut: row['timeCheckedOut'] as String?,
            note: row['note'] as String?,
            charge: row['charge'] as int?,
            status: row['status'] as String?),
        arguments: [id],
        queryableName: 'no_table_name',
        isView: false);
  }

  @override
  Future<void> flushAllReservation() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Reservation');
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }
}
