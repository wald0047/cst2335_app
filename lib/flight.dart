// entity/flight.dart
import 'package:floor/floor.dart';

/// Represents a flight entity in the database.
@entity
class Flight {
  /// The primary key of the flight.
  @primaryKey
  final int? id;

  /// The departure city of the flight.
  final String departureCity;

  /// The destination city of the flight.
  final String destinationCity;

  /// The departure time of the flight.
  final DateTime departureTime;

  /// The arrival time of the flight.
  final DateTime arrivalTime;

  /// Constructs a [Flight] object.
  ///
  /// The [departureCity], [destinationCity], [departureTime], and [arrivalTime]
  /// parameters are required. The [id] parameter is optional and is used
  /// as the primary key in the database.
  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });
}
