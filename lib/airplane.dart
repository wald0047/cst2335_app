import 'package:floor/floor.dart';

@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String type;
  final int numPassengers;
  final int maxSpeed;
  final int range;

  Airplane(this.id,
          this.type,
          this.numPassengers,
          this.maxSpeed,
          this.range);

  Airplane.fromNoid(this.id,
      Airplane noid) :
      this.type = noid.type,
      this.numPassengers = noid.numPassengers,
      this.maxSpeed = noid.maxSpeed,
      this.range = noid.maxSpeed {

  }


  Airplane.noid(
      this.type,
      this.numPassengers,
      this.maxSpeed,
      this.range,
      { this.id }) ;

}