import 'package:cst2335_app/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/main.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/flight.dart';
import 'package:cst2335_app/flightRepository.dart';
import 'package:cst2335_app/customerdao.dart';
import 'package:cst2335_app/reservationdao.dart';
import 'package:cst2335_app/reservation.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late FlightRepository flightRepository;
  late CustomerDAO customerDAO;
  late ReservationDAO reservationDAO;
  List<Reservation> reservations = [];
  Locale _locale = const Locale("en", "CA");

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  void _initializeDependencies() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    flightRepository = Provider.of<FlightRepository>(context, listen: false);
    customerDAO = database.customerDAO;
    reservationDAO = database.reservationDAO;
    _loadReservations();
  }

  void _loadReservations() async {
    // Load reservations from the database
    final loadedReservations = await reservationDAO.getAllReservations();
    setState(() {
      reservations = loadedReservations;
    });
  }


  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    MyApp.setLocale(context, locale);
  }


  void _showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddReservationDialog(
          customerDAO: customerDAO, // Pass the customerDAO directly
          onReservationAdded: (int customerId) async {
            final newReservation = Reservation.noid(customerId);
            final insertedId = await reservationDAO.insertReservation(newReservation);
            if (insertedId != null) {
              _loadReservations(); // Reload the reservations list
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('r_page_title')!),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.g_translate),
            onPressed: () {
              _changeLanguage(
                _locale.languageCode == 'en' ? const Locale('zh', 'CN') : const Locale('en', 'CA'),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return StreamBuilder<Customer?>(
            stream: customerDAO.findCustomerById(reservation.customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text('Loading...'));
              }
              if (snapshot.hasError) {
                return ListTile(title: Text('Error loading customer'));
              }
              final customer = snapshot.data;
              return ListTile(
                title: Text(customer != null ? '${customer.firstName} ${customer.lastName}' : 'Unknown Customer'),
                subtitle: Text('Reservation ID: ${reservation.id}'),
                onTap: () {
                  // Show reservation details
                  _showReservationDetails(reservation, customer);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReservationDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showReservationDetails(Reservation reservation, Customer? customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reservation ID: ${reservation.id}'),
              Text('Customer: ${customer != null ? '${customer.firstName} ${customer.lastName}' : 'Unknown'}'),
              Text('Customer ID: ${reservation.customerId}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


class AddReservationDialog extends StatefulWidget {
  final Function(int) onReservationAdded;
  final CustomerDAO customerDAO; // Add this line

  const AddReservationDialog({
    Key? key,
    required this.onReservationAdded,
    required this.customerDAO, // Add this line
  }) : super(key: key);

  @override
  _AddReservationDialogState createState() => _AddReservationDialogState();
}

class _AddReservationDialogState extends State<AddReservationDialog> {
  int? selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Reservation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<List<Customer>>(
            future: widget.customerDAO.getAllCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error loading customers');
              }
              final customers = snapshot.data ?? [];
              return DropdownButton<int>(
                hint: Text('Select Customer'),
                value: selectedCustomerId,
                onChanged: (int? value) {
                  setState(() {
                    selectedCustomerId = value;
                  });
                },
                items: customers.map((Customer customer) {
                  return DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text('${customer.firstName} ${customer.lastName}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            if (selectedCustomerId != null) {
              widget.onReservationAdded(selectedCustomerId!);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
