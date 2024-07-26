
import 'package:flutter/material.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/AppLocalizations.dart';

/// A widget that displays a list of customers with search and add functionalities.
class CustomerList extends StatefulWidget {
  final List<Customer> customers; // List of customers to display
  final VoidCallback onAddCustomer; // Callback function when adding a customer
  final void Function(Customer) onSelectCustomer; // Callback function when selecting a customer
  final void Function(String) onSearchCustomer; // Callback function when searching for customers

  const CustomerList({
    super.key,
    required this.customers,
    required this.onAddCustomer,
    required this.onSelectCustomer,
    required this.onSearchCustomer,
  });

  @override
  CustomerListState createState() => CustomerListState();
}

class CustomerListState extends State<CustomerList> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar for filtering customers
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Enter first name, last name, ...", // Placeholder text
                    border: OutlineInputBorder(), // Border style
                    labelText: "Customer", // Label text
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                iconSize: 32,
                onPressed: () {
                  widget.onSearchCustomer(_searchController.value.text); // Trigger search callback
                },
                icon: const Icon(Icons.search), // Search icon
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Button to add a new customer
          ElevatedButton(
            onPressed: widget.onAddCustomer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add), // Add icon
                Text(AppLocalizations.of(context)!.translate('string')!), // Button text
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Display customers or message if no customers are present
          Expanded(
            child: widget.customers.isEmpty
                ? const Center(
              child: Text(
                "There are no customers yet.", // Message when no customers
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : ListView.builder(
              itemCount: widget.customers.length, // Number of customers
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onSelectCustomer(widget.customers[index]); // Trigger select callback
                  },
                  child: Card(
                    elevation: 4, // Card elevation for shadow effect
                    margin: const EdgeInsets.symmetric(vertical: 8), // Vertical margin for spacing
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Display customer index as a circle avatar
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                            foregroundColor: Colors.white,
                            child: Text(
                              "${index + 1}", // Customer index (1-based)
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Display customer name
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.customers[index].firstName,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.customers[index].lastName,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.chevron_right, // Chevron icon indicating navigation
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
