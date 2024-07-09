import 'package:floor/floor.dart';

@entity
class Customer {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  Customer(this.id);

  Customer.noid({ this.id }) ;

}