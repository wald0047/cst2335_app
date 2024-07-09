import 'package:floor/floor.dart';

@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  Airplane(this.id);

  Airplane.noid({ this.id }) ;

}