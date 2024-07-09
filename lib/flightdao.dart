import 'package:floor/floor.dart';
import 'package:cst2335_app/flight.dart';

@dao
abstract class FlightDAO {
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  @Query('SELECT * FROM Flight WHERE id = :id')
  Stream<Flight?> findFlightById(int id);

  @insert
  Future<int> insertFlight(Flight item);

  @update
  Future<void> updateFlight(Flight item);

  @delete
  Future<void> deleteFlight(Flight item);
}