import 'package:floor/floor.dart';
import 'reservation.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM reservations')
  Future<List<Reservation>> findAllReservations();

  @Query('SELECT * FROM reservations WHERE id = :id')
  Stream<Reservation?> findReservationById(int id);

  @insert
  Future<void> insertReservation(Reservation reservation);

  @update
  Future<void> updateReservation(Reservation reservation);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}
