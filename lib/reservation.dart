import 'package:floor/floor.dart';

@entity
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int customerId;
  final int flightId; // Add this line

  Reservation(this.customerId, this.flightId, {this.id}); // Update constructor

  Reservation.noid(this.customerId, this.flightId, {this.id}); // Update noid constructor
}
