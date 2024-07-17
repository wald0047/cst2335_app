import 'package:floor/floor.dart';

@entity
class Customer {
  static int ID = 1;

  @PrimaryKey(autoGenerate: true)
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime birthdate;

  Customer(
      this.id, this.firstName, this.lastName, this.address, this.birthdate) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}
