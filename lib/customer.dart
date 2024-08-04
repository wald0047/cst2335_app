import 'package:floor/floor.dart';

@entity
class Customer {
  // Static ID counter for new entries
  static int ID = 1;

  @PrimaryKey(autoGenerate: true)
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime birthdate;

  // Constructor to initialize the customer entity
  Customer(
      this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.birthdate,
      ) {
    // Update the static ID counter if necessary
    if (id >= ID) {
      ID = id + 1;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Customer &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
