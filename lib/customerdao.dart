import 'package:floor/floor.dart';
import 'package:cst2335_app/customer.dart';

@dao
abstract class CustomerDAO {
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  @Query('SELECT * FROM Customer WHERE id = :id')
  Stream<Customer?> findCustomerById(int id);

  @insert
  Future<int> insertCustomer(Customer item);

  @update
  Future<void> updateCustomer(Customer item);

  @delete
  Future<void> deleteCustomer(Customer item);
}
