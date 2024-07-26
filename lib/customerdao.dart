import 'package:floor/floor.dart';
import 'package:cst2335_app/customer.dart';

/// Data Access Object (DAO) for managing `Customer` entities in the database.
@dao
abstract class CustomerDAO {

  /// Retrieves all customers from the database.
  ///
  /// Returns a [Future] that completes with a [List] of [Customer] objects.
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  /// Finds a customer by their ID.
  ///
  /// Returns a [Stream] that emits the [Customer] object with the given [id].
  /// The stream will be updated automatically if the customer data changes.
  @Query('SELECT * FROM Customer WHERE id = :id')
  Stream<Customer?> findCustomerById(int id);

  /// Inserts a new customer into the database.
  ///
  /// Returns a [Future] that completes with the ID of the newly inserted customer.
  @insert
  Future<int> insertCustomer(Customer item);

  /// Updates an existing customer in the database.
  ///
  /// Takes a [Customer] object and applies changes to the corresponding record.
  @update
  Future<void> updateCustomer(Customer item);

  /// Deletes a customer from the database.
  ///
  /// Takes a [Customer] object and removes the corresponding record from the database.
  @delete
  Future<void> deleteCustomer(Customer item);
}
