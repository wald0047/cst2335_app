import 'package:floor/floor.dart';

@entity
class Airplane {

  @PrimaryKey(autoGenerate: true)
  final int? id; // Autoincremented primary key
  final String type; // Type of plane
  final int numPassengers; // number of passengers
  final int maxSpeed; // maximum speed in km/h
  final int range; // range in km

  /// Default Constructor
  Airplane(this.id,
          this.type,
          this.numPassengers,
          this.maxSpeed,
          this.range);

  /// Constructor to convert null id Airplane to nonnull id airplane
  Airplane.fromNoid(this.id,
      Airplane noid) :
      this.type = noid.type,
      this.numPassengers = noid.numPassengers,
      this.maxSpeed = noid.maxSpeed,
      this.range = noid.maxSpeed {

  }

  /// Constructor for null id airplanes
  Airplane.noid(
      this.type,
      this.numPassengers,
      this.maxSpeed,
      this.range,
      { this.id }) ;

}