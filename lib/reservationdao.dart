import 'package:floor/floor.dart';
import 'package:cst2335_app/reservation.dart';

/// Data Access Object (DAO) for interacting with [Reservation] entities in the database.
///
/// The [ReservationDAO] interface provides methods to perform CRUD operations on [Reservation] entities.
/// It uses Floor's annotation-based approach to define database queries and operations.
@dao
abstract class ReservationDAO {
  /// Retrieves all reservations from the database.
  ///
  /// Returns a [Future] that completes with a list of [Reservation] objects.
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllReservations();

  /// Finds a reservation by its ID.
  ///
  /// [id] is the ID of the reservation to be retrieved.
  /// Returns a [Stream] that emits a [Reservation] object if found, or `null` if not found.
  @Query('SELECT * FROM Reservation WHERE id = :id')
  Stream<Reservation?> findReservationById(int id);

  /// Inserts a new reservation into the database.
  ///
  /// [item] is the [Reservation] object to be inserted.
  /// Returns a [Future] that completes with the ID of the inserted reservation.
  @insert
  Future<int> insertReservation(Reservation item);

  /// Updates an existing reservation in the database.
  ///
  /// [item] is the [Reservation] object to be updated.
  /// Returns a [Future] that completes when the update operation is done.
  @update
  Future<void> updateReservation(Reservation item);

  /// Deletes a reservation from the database.
  ///
  /// [item] is the [Reservation] object to be deleted.
  /// Returns a [Future] that completes when the delete operation is done.
  @delete
  Future<void> deleteReservation(Reservation item);
}
