import 'package:flutter/material.dart';
import 'package:cst2335_app/database.dart';
import 'package:cst2335_app/customerdao.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/customer_form.dart';
import 'package:cst2335_app/customer_list.dart';

/// The main page of customer module that displays a list of customers and allows for adding, editing, and searching customers.
class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  late CustomerDAO dao; // The Data Access Object for customer data.
  var customers = <Customer>[]; // List of all customers.
  var list = <Customer>[]; // Filtered list of customers based on the search keyword.
  String keyword = ""; // Keyword for searching customers.

  Customer? selectedItem; // The currently selected customer.
  bool isAdding = false; // Whether the form is in "add" mode.

  /// Initializes the database and loads customer data.
  void _loadDatabase() async {
    var database =
    await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    dao = database.customerDAO;
    _loadCustomers();
  }

  /// Loads all customers from the database and updates the state.
  void _loadCustomers() async {
    var items = await dao.getAllCustomers();
    customers.clear();
    setState(() {
      customers.addAll(items);
      _filterList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDatabase(); // Load the database when the state is initialized.
  }

  /// Filters the list of customers based on the current keyword.
  void _filterList() {
    setState(() {
      list = keyword.isEmpty
          ? customers
          : customers.where((item) {
        return item.firstName
            .toLowerCase()
            .contains(keyword.toLowerCase()) ||
            item.lastName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  /// Displays a dialog with instructions for using the page.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '1. Search for Customers:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '   - Enter a keyword in the search box.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   - Click the "Search" button to find customers by name.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '2. Add a New Customer:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '   - Click the "+Add" button to open the form for adding a new customer.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   - Use the switch at the top to load existing customer data or enter new information.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   - Click "Create" to save the new customer or "Cancel" to return to the customer list.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '3. View and Edit Customer Details:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '   - Click on a customer in the list to view their details.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   - Change any information you need to update.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   - Click "Update" to save changes, "Delete" to remove the customer, or "Cancel" to return to the customer list.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog.
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the widget for displaying the list of customers.
  Widget listPage() {
    return CustomerList(
        customers: list,
        onSearchCustomer: (String keyword) {
          setState(() {
            this.keyword = keyword;
            _filterList(); // Update the list based on the search keyword.
          });
        },
        onAddCustomer: () {
          setState(() {
            isAdding = true; // Switch to the "add" mode.
          });
        },
        onSelectCustomer: (Customer item) {
          setState(() {
            selectedItem = item; // Set the selected customer.
          });
        });
  }

  /// Builds the widget for the customer form.
  Widget formPage() {
    return CustomerForm(
        dao: dao,
        isAdding: isAdding,
        selectedItem: selectedItem,
        onSuccess: _loadCustomers, // Reload the customers on success.
        onClose: () {
          setState(() {
            if (isAdding) {
              isAdding = false; // Exit "add" mode.
            } else if (selectedItem != null) {
              selectedItem = null; // Deselect the customer.
            }
          });
        });
  }

  /// Builds a responsive layout based on screen size and orientation.
  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    if ((width > height) && (width > 720)) {
      // Landscape mode or large screen
      return Row(children: [
        Expanded(flex: 1, child: listPage()), // Left side: customer list
        Expanded(flex: 2, child: formPage()) // Right side: customer form
      ]);
    } else {
      // Portrait mode or small screen
      return isAdding || selectedItem != null ? formPage() : listPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Customer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog, // Show the help dialog when the icon is pressed.
          ),
        ],
      ),
      body: responsiveLayout(), // Display the responsive layout.
    );
  }
}
