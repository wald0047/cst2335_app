import 'package:floor/floor.dart';
import 'package:cst2335_app/reservation.dart';

@dao
abstract class ReservationDAO {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllReservations();

  @Query('SELECT * FROM Reservation WHERE id = :id')
  Stream<Reservation?> findReservationById(int id);

  @insert
  Future<int> insertReservation(Reservation item);

  @update
  Future<void> updateReservation(Reservation item);

  @delete
  Future<void> deleteReservation(Reservation item);
}