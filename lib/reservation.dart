import 'package:floor/floor.dart';

@entity
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int customerId;

  Reservation(this.customerId, this.id);

  Reservation.noid(this.customerId, { this.id }) ;

}