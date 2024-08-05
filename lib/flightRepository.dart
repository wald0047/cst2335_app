// repository/flight_repository.dart
import 'package:cst2335_app/database.dart';
import 'package:cst2335_app/flight.dart';

/// A repository that manages [Flight] data.
///
/// Provides methods to interact with the [Flight] data in the database
/// using the [FlightDAO].
class FlightRepository {
  final AppDatabase database;

  /// Constructs a [FlightRepository] with the given [database].
  FlightRepository(this.database);

  /// Watches all flights in the database.
  ///
  /// Returns a [Stream] that emits a list of [Flight] objects whenever the data changes.
  Stream<List<Flight>> watchAllFlights() {
    return database.flightDAO.watchAllFlights();
  }

  /// Retrieves all flights from the database.
  ///
  /// Returns a [Future] that completes with a list of [Flight] objects.
  Future<List<Flight>> getAllFlights() {
    return database.flightDAO.getAllFlights();
  }

  /// Inserts a new flight into the database.
  ///
  /// [flight] is the [Flight] object to be inserted.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> insertFlight(Flight flight) {
    return database.flightDAO.insertFlight(flight);
  }

  /// Updates an existing flight in the database.
  ///
  /// [flight] is the [Flight] object to be updated.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> updateFlight(Flight flight) {
    return database.flightDAO.updateFlight(flight);
  }

  /// Deletes a flight from the database.
  ///
  /// [flight] is the [Flight] object to be deleted.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> deleteFlight(Flight flight) {
    return database.flightDAO.deleteFlight(flight);
  }

  /// Retrieves a flight by its ID from the database.
  ///
  /// [id] is the ID of the flight to be retrieved.
  /// Returns a [Future] that completes with the [Flight] object if found, or `null` if not found.
  Future<Flight?> getFlightById(int id) {
    return database.flightDAO.findFlightById(id);
  }

}