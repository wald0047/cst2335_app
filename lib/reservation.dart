import 'package:floor/floor.dart';

@Entity(tableName: 'reservations')
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int customerId;
  final int flightId;
  final String reservationDate;

  Reservation(this.id, this.customerId, this.flightId, this.reservationDate);
}