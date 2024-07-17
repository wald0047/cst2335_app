import 'package:flutter/material.dart';
import 'package:cst2335_app/customer.dart';

class CustomerList extends StatefulWidget {
  final List<Customer> customers;
  final VoidCallback onAddCustomer;
  final void Function(Customer) onSelectCustomer;
  final void Function(String) onSearchCustomer;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Enter first name, last name, ...",
                    border: OutlineInputBorder(),
                    labelText: "Customer",
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                iconSize: 32,
                onPressed: () {
                  widget.onSearchCustomer(_searchController.value.text);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onAddCustomer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                Text("Add"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.customers.isEmpty
                ? const Center(
                    child: Text(
                      "There are no customers yet.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.customers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          widget.onSelectCustomer(widget.customers[index]);
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  Icons.chevron_right,
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
