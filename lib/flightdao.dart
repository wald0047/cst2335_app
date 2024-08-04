// dao/flight_dao.dart
import 'package:floor/floor.dart';
import 'flight.dart';

/// Data Access Object (DAO) for the [Flight] entity.
///
/// Provides methods to interact with the [Flight] table in the database.
@dao
abstract class FlightDAO {
  /// Watches all flights in the database.
  ///
  /// Returns a [Stream] that emits a list of [Flight] objects whenever the data changes.
  @Query('SELECT * FROM Flight')
  Stream<List<Flight>> watchAllFlights();

  /// Retrieves all flights from the database.
  ///
  /// Returns a [Future] that completes with a list of [Flight] objects.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  /// Inserts a new flight into the database.
  ///
  /// [flight] is the [Flight] object to be inserted.
  @insert
  Future<void> insertFlight(Flight flight);

  /// Updates an existing flight in the database.
  ///
  /// [flight] is the [Flight] object to be updated.
  @update
  Future<void> updateFlight(Flight flight);

  /// Deletes a flight from the database.
  ///
  /// [flight] is the [Flight] object to be deleted.
  @delete
  Future<void> deleteFlight(Flight flight);

  /// Retrieves a flight by its ID from the database.
  ///
  /// [id] is the ID of the flight to be retrieved.
  /// Returns a [Future] that completes with the [Flight] object if found, or `null` if not found.
  @Query('SELECT * FROM Flight WHERE id = :id')
  Future<Flight?> findFlightById(int id);
}
