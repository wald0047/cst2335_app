// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AirplaneDAO? _airplaneDAOInstance;

  CustomerDAO? _customerDAOInstance;

  FlightDAO? _flightDAOInstance;

  ReservationDao? _reservationDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER PRIMARY KEY AUTOINCREMENT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER PRIMARY KEY AUTOINCREMENT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`id` INTEGER PRIMARY KEY AUTOINCREMENT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `reservations` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `reservationDate` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AirplaneDAO get airplaneDAO {
    return _airplaneDAOInstance ??= _$AirplaneDAO(database, changeListener);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  FlightDAO get flightDAO {
    return _flightDAOInstance ??= _$FlightDAO(database, changeListener);
  }

  @override
  ReservationDao get reservationDao {
    return _reservationDaoInstance ??=
        _$ReservationDao(database, changeListener);
  }
}

class _$AirplaneDAO extends AirplaneDAO {
  _$AirplaneDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{'id': item.id},
            changeListener),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{'id': item.id},
            changeListener),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{'id': item.id},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> getAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM Airplane',
        mapper: (Map<String, Object?> row) => Airplane(row['id'] as int?));
  }

  @override
  Stream<Airplane?> findAirplaneById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Airplane WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Airplane(row['id'] as int?),
        arguments: [id],
        queryableName: 'Airplane',
        isView: false);
  }

  @override
  Future<int> insertAirplane(Airplane item) {
    return _airplaneInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane item) async {
    await _airplaneUpdateAdapter.update(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAirplane(Airplane item) async {
    await _airplaneDeletionAdapter.delete(item);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{'id': item.id},
            changeListener),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{'id': item.id},
            changeListener),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{'id': item.id},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(row['id'] as int?));
  }

  @override
  Stream<Customer?> findCustomerById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Customer WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Customer(row['id'] as int?),
        arguments: [id],
        queryableName: 'Customer',
        isView: false);
  }

  @override
  Future<int> insertCustomer(Customer item) {
    return _customerInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer item) async {
    await _customerUpdateAdapter.update(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer item) async {
    await _customerDeletionAdapter.delete(item);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _flightInsertionAdapter = InsertionAdapter(database, 'Flight',
            (Flight item) => <String, Object?>{'id': item.id}, changeListener),
        _flightUpdateAdapter = UpdateAdapter(database, 'Flight', ['id'],
            (Flight item) => <String, Object?>{'id': item.id}, changeListener),
        _flightDeletionAdapter = DeletionAdapter(database, 'Flight', ['id'],
            (Flight item) => <String, Object?>{'id': item.id}, changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  final DeletionAdapter<Flight> _flightDeletionAdapter;

  @override
  Future<List<Flight>> getAllFlights() async {
    return _queryAdapter.queryList('SELECT * FROM Flight',
        mapper: (Map<String, Object?> row) => Flight(row['id'] as int?));
  }

  @override
  Stream<Flight?> findFlightById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Flight WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Flight(row['id'] as int?),
        arguments: [id],
        queryableName: 'Flight',
        isView: false);
  }

  @override
  Future<int> insertFlight(Flight item) {
    return _flightInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight item) async {
    await _flightUpdateAdapter.update(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFlight(Flight item) async {
    await _flightDeletionAdapter.delete(item);
  }
}

class _$ReservationDao extends ReservationDao {
  _$ReservationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'reservations',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate
                },
            changeListener),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'reservations',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate
                },
            changeListener),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'reservations',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'reservationDate': item.reservationDate
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> findAllReservations() async {
    return _queryAdapter.queryList('SELECT * FROM reservations',
        mapper: (Map<String, Object?> row) => Reservation(
            row['id'] as int?,
            row['customerId'] as int,
            row['flightId'] as int,
            row['reservationDate'] as String));
  }

  @override
  Stream<Reservation?> findReservationById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM reservations WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            row['id'] as int?,
            row['customerId'] as int,
            row['flightId'] as int,
            row['reservationDate'] as String),
        arguments: [id],
        queryableName: 'reservations',
        isView: false);
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReservation(Reservation reservation) async {
    await _reservationDeletionAdapter.delete(reservation);
  }
}
