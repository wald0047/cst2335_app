import 'package:floor/floor.dart';
import 'package:cst2335_app/airplane.dart';

@dao
abstract class AirplaneDAO {
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();

  @Query('SELECT * FROM Airplane WHERE id = :id')
  Stream<Airplane?> findAirplaneById(int id);

  @insert
  Future<int> insertAirplane(Airplane item);

  @update
  Future<void> updateAirplane(Airplane item);

  @delete
  Future<void> deleteAirplane(Airplane item);
}