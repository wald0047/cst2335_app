import 'package:floor/floor.dart';
import 'package:cst2335_app/airplane.dart';

/// Data Access Object (DAO) for managing `Airplane` entities in the database.
@dao
abstract class AirplaneDAO {
  /// Retrieves all airplanes from the database.
  ///
  /// Returns a [Future] that completes with a [List] of [Airplane] objects.
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();

  /// Finds an airplane by its ID.
  ///
  /// Returns a [Stream] that emits [Airplane] objects with the given [id].
  /// The stream is automatically updated if the airplane data changes.
  @Query('SELECT * FROM Airplane WHERE id = :id')
  Stream<Airplane?> findAirplaneById(int id);

  /// Inserts a new airplane into the database.
  ///
  /// Returns a [Future] that completes with the ID of the newly inserted airplane.
  @insert
  Future<int> insertAirplane(Airplane plane);

  /// Updates an existing airplane in the database.
  ///
  /// Takes an [Airplane] object and updates the corresponding record.
  @update
  Future<void> updateAirplane(Airplane plane);

  /// Deletes an airplane from the database.
  ///
  /// Takes a [Airplane] object and deletes the corresponding record from the database.
  @delete
  Future<void> deleteAirplane(Airplane plane);
}