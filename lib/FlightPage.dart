import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flight.dart';
import 'flightRepository.dart';
import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/main.dart';
import 'package:intl/intl.dart';
import 'AddFlightPage.dart';
import 'FlightDetailPage.dart';

/// A page that displays a list of flights and allows the user to add, update, or delete flights.
/// On tablets or desktop devices, the flight details are displayed beside the list.
class FlightPage extends StatefulWidget {
  const FlightPage({Key? key}) : super(key: key);

  @override
  _FlightPageState createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  late FlightRepository flightRepository;
  Locale _locale = const Locale("en", "CA");
  Flight? selectedFlight;

  @override
  void initState() {
    super.initState();
    flightRepository = Provider.of<FlightRepository>(context, listen: false);
  }

  /// Changes the language of the application.
  ///
  /// [locale] is the new locale to set.
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    MyApp.setLocale(context, locale);
  }

  /// Shows a help dialog with instructions.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('f_instruction')!),
          content: Text(
            AppLocalizations.of(context)!.translate('f_instructions')!,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('c_confirm_button')!),
            ),
          ],
        );
      },
    );
  }

  /// Navigates to the page for adding a new flight.
  /// If a new flight is added, the list is refreshed and a snackbar is shown.
  void _navigateToAddFlight() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFlightPage()),
    );
    if (result == true) {
      // Refresh the list if a new flight was added
      setState(() {});
      _showSnackbar(context, 'Flight added successfully!');
    }
  }

  /// Navigates to the detail page for the selected flight.
  /// If the flight is updated or deleted, the list is refreshed and a snackbar is shown.
  ///
  /// [flight] is the selected flight to view details.
  void _navigateToFlightDetail(Flight flight) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlightDetailPage(flight: flight)),
    );
    if (result == 'updated' || result == 'deleted') {
      // Refresh the list if the flight was updated or deleted
      setState(() {});
      _showSnackbar(context, result == 'updated' ? 'Flight updated successfully!' : 'Flight deleted successfully!');
    }
  }

  /// Shows a snackbar with a message.
  ///
  /// [context] is the BuildContext of the widget.
  /// [message] is the message to display in the snackbar.
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('f_page_title')!),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.g_translate,
              color: _locale.languageCode == 'en'
                  ? null
                  : Colors.grey[600],
            ),
            onPressed: () {
              _changeLanguage(
                _locale.languageCode == 'en' ? const Locale('zh', 'CN') : const Locale('en', 'CA'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Tablet or desktop layout
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildFlightList(context),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: selectedFlight != null
                      ? FlightDetailPage(flight: selectedFlight!, isTablet: true)
                      : Center(
                    child: Text(AppLocalizations.of(context)!.translate('f_select_flight') ?? 'Select a flight'),
                  ),
                ),
              ],
            );
          } else {
            // Phone layout
            return _buildFlightList(context);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFlight,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the flight list view.
  ///
  /// [context] is the BuildContext of the widget.
  ///
  /// Returns a Container with the flight list.
  Widget _buildFlightList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 4.0,
          ),
        ),
      ),
      child: StreamBuilder<List<Flight>>(
        stream: flightRepository.watchAllFlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.translate('f_no_flights')!));
          }

          final flights = snapshot.data!;

          return ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              return Card(
                child: ListTile(
                  title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppLocalizations.of(context)!.translate('f_departure')!}: ${DateFormat('yyyy-MM-dd').format(flight.departureTime)}'),
                      Text('${AppLocalizations.of(context)!.translate('f_arrival')!}: ${DateFormat('yyyy-MM-dd').format(flight.arrivalTime)}'),
                    ],
                  ),
                  onTap: () {
                    if (MediaQuery.of(context).size.width > 600) {
                      // Tablet or desktop: show details beside the list
                      setState(() {
                        selectedFlight = flight;
                      });
                    } else {
                      // Phone: navigate to the detail page
                      _navigateToFlightDetail(flight);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
