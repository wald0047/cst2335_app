import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/main.dart';
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

  Locale _locale = const Locale("en", "CA");

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
          title: Text(AppLocalizations.of(context)!.translate('c_instruction')),
          content: Text(
            AppLocalizations.of(context)!.translate('c_instructions'),
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

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    MyApp.setLocale(context, locale); // Assuming MyApp is the root widget.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('c_page_title')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.g_translate,
              color: _locale.languageCode == 'en'
                  ? null // Example color for Chinese
                  : Colors.grey[600],

                ),
            onPressed: () {
              _changeLanguage(
                _locale.languageCode == 'en' ? const Locale('zh', 'CN') : const Locale('en', 'CA'),
              );
            }, // Switch the language when pressed
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,  // Show the help dialog when the icon is pressed.
          ),
        ],
      ),
      body: responsiveLayout(), // Display the responsive layout.
    );
  }
}
