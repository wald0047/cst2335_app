import 'package:floor/floor.dart';

@entity
class Flight {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  Flight(this.id);

  Flight.noid({ this.id }) ;

}