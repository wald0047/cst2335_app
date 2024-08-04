import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/database.dart';
import 'package:cst2335_app/flight.dart';
import 'package:cst2335_app/flightRepository.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/customerdao.dart';
import 'package:cst2335_app/reservationdao.dart';
import 'package:cst2335_app/reservation.dart';
import 'package:cst2335_app/main.dart';

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

  final List<Locale> _supportedLocales = [
    const Locale('en', 'CA'),
    const Locale('zh', 'CN'),
    const Locale('fr', 'FR'),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('r_page_title')!),
        actions: <Widget>[
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: _locale,
              icon: Icon(Icons.language),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  _changeLanguage(newLocale);
                }
              },
              items: _supportedLocales.map((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(_getLocaleDisplayName(locale)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return FutureBuilder<Customer?>(
            future: customerDAO.findCustomerById(reservation.customerId).first,
            builder: (context, customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text(AppLocalizations.of(context)!.translate('r_loading')!));
              }
              if (customerSnapshot.hasError) {
                return ListTile(title: Text(AppLocalizations.of(context)!.translate('r_error_loading_customer')!));
              }
              final customer = customerSnapshot.data;

              return FutureBuilder<Flight?>(
                future: flightRepository.getFlightById(reservation.flightId),
                builder: (context, flightSnapshot) {
                  if (flightSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text(AppLocalizations.of(context)!.translate('r_loading')!));
                  }
                  if (flightSnapshot.hasError) {
                    return ListTile(title: Text(AppLocalizations.of(context)!.translate('r_error_loading_flight')!));
                  }
                  final flight = flightSnapshot.data;

                  return ListTile(
                    title: Text(customer != null ? '${customer.firstName} ${customer.lastName}' : AppLocalizations.of(context)!.translate('r_unknown_customer')!),
                    subtitle: Text(AppLocalizations.of(context)!.translate('r_flight_details')!
                        .replaceFirst('{departureCity}', flight?.departureCity ?? AppLocalizations.of(context)!.translate('r_unknown_flight')!)
                        .replaceFirst('{destinationCity}', flight?.destinationCity ?? AppLocalizations.of(context)!.translate('r_unknown_flight')!)),
                    trailing: Text('${AppLocalizations.of(context)!.translate('r_reservation_id')!} ${reservation.id}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReservationDetailsPage(
                            reservation: reservation,
                            customer: customer,
                            flight: flight,
                          ),
                        ),
                      );
                    },
                  );
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

  String _getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return 'Chinese';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  void _showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddReservationDialog(
          customerDAO: customerDAO,
          flightRepository: flightRepository,
          onReservationAdded: (int customerId, int flightId) async {
            final newReservation = Reservation.noid(customerId, flightId);
            final insertedId = await reservationDAO.insertReservation(newReservation);
            if (insertedId != null) {
              _loadReservations(); // Reload the reservations list
            }
          },
        );
      },
    );
  }
}

class AddReservationDialog extends StatefulWidget {
  final Function(int, int) onReservationAdded;
  final CustomerDAO customerDAO;
  final FlightRepository flightRepository;

  const AddReservationDialog({
    Key? key,
    required this.onReservationAdded,
    required this.customerDAO,
    required this.flightRepository,
  }) : super(key: key);

  @override
  _AddReservationDialogState createState() => _AddReservationDialogState();
}

class _AddReservationDialogState extends State<AddReservationDialog> {
  int? selectedCustomerId;
  int? selectedFlightId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.translate('r_add_reservation')!),
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
                return Text(AppLocalizations.of(context)!.translate('r_error_loading_customers')!);
              }
              final customers = snapshot.data ?? [];
              return DropdownButton<int>(
                hint: Text(AppLocalizations.of(context)!.translate('r_select_customer')!),
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
          SizedBox(height: 16.0),
          FutureBuilder<List<Flight>>(
            future: widget.flightRepository.getAllFlights(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(AppLocalizations.of(context)!.translate('r_error_loading_flights')!);
              }
              final flights = snapshot.data ?? [];
              return DropdownButton<int>(
                hint: Text(AppLocalizations.of(context)!.translate('r_select_flight')!),
                value: selectedFlightId,
                onChanged: (int? value) {
                  setState(() {
                    selectedFlightId = value;
                  });
                },
                items: flights.map((Flight flight) {
                  return DropdownMenuItem<int>(
                    value: flight.id,
                    child: Text('${flight.departureCity} to ${flight.destinationCity}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.translate('r_add')!),
          onPressed: () {
            if (selectedCustomerId != null && selectedFlightId != null) {
              widget.onReservationAdded(selectedCustomerId!, selectedFlightId!);
              Navigator.of(context).pop();
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.translate('r_cancel')!),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ReservationDetailsPage extends StatelessWidget {
  final Reservation reservation;
  final Customer? customer;
  final Flight? flight;

  const ReservationDetailsPage({
    Key? key,
    required this.reservation,
    this.customer,
    this.flight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('r_reservation_details')!),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_reservation_id')!,
              value: reservation.id.toString(),
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_customer')!,
              value: customer != null
                  ? '${customer!.firstName} ${customer!.lastName}'
                  : AppLocalizations.of(context)!.translate('r_unknown_customer')!,
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_customer_id')!,
              value: reservation.customerId.toString(),
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_flight_departure_city')!,
              value: flight?.departureCity ?? AppLocalizations.of(context)!.translate('r_unknown_flight')!,
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_flight_destination_city')!,
              value: flight?.destinationCity ?? AppLocalizations.of(context)!.translate('r_unknown_flight')!,
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_flight_departure_time')!,
              value: flight?.departureTime.toLocal().toString() ?? AppLocalizations.of(context)!.translate('r_unknown_time')!,
            ),
            SizedBox(height: 16.0),
            _buildDetailItem(
              title: AppLocalizations.of(context)!.translate('r_flight_arrival_time')!,
              value: flight?.arrivalTime.toLocal().toString() ?? AppLocalizations.of(context)!.translate('r_unknown_time')!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}