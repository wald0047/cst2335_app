import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flight.dart';
import 'flightRepository.dart';
import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/main.dart';
import 'package:intl/intl.dart';

/// A page that displays the details of a specific flight and allows the user to update or delete the flight.
class FlightDetailPage extends StatefulWidget {
  final Flight flight;
  final bool isTablet;

  const FlightDetailPage({required this.flight, this.isTablet = false, Key? key}) : super(key: key);

  @override
  _FlightDetailPageState createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  late String departureCity;
  late String destinationCity;
  late DateTime departureTime;
  late DateTime arrivalTime;

  final _formKey = GlobalKey<FormState>();
  Locale _locale = const Locale("en", "CA");

  @override
  void initState() {
    super.initState();
    _loadFlightDetails();
  }

  /// Loads the flight details into the form fields.
  void _loadFlightDetails() {
    departureCity = widget.flight.departureCity;
    destinationCity = widget.flight.destinationCity;
    departureTime = widget.flight.departureTime;
    arrivalTime = widget.flight.arrivalTime;
  }

  /// Allows the user to select a date from a date picker.
  ///
  /// [context] is the BuildContext of the widget.
  /// [isDeparture] indicates whether the selected date is for the departure time (true) or arrival time (false).
  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? departureTime : arrivalTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureTime = picked;
        } else {
          arrivalTime = picked;
        }
      });
    }
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
          title: Text(AppLocalizations.of(context)!.translate('f_instruction')),
          content: Text(
            AppLocalizations.of(context)!.translate('f_instructions'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('c_confirm_button')),
            ),
          ],
        );
      },
    );
  }

  /// Shows a snackbar with a message.
  ///
  /// [context] is the BuildContext of the widget.
  /// [message] is the message to display in the snackbar.
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a dialog to confirm the update of the flight.
  ///
  /// If the user confirms, the flight is updated in the repository.
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Flight'),
          content: Text('Do you want to update this flight?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.translate('c_confirm_button')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)!.translate('c_cancel_button')),
            ),
          ],
        );
      },
    ).then((result) {
      if (result == true) {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          final updatedFlight = Flight(
            id: widget.flight.id,
            departureCity: departureCity,
            destinationCity: destinationCity,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
          );
          Provider.of<FlightRepository>(context, listen: false).updateFlight(updatedFlight);
          if (widget.isTablet) {
            _showSnackbar(context, 'Flight updated successfully!');
          } else {
            Navigator.pop(context, 'updated'); // 修改此行
          }
        }
      }
    });
  }

  /// Shows a dialog to confirm the deletion of the flight.
  ///
  /// If the user confirms, the flight is deleted from the repository.
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Flight'),
          content: Text('Do you want to delete this flight?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.translate('c_confirm_button')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)!.translate('c_cancel_button')),
            ),
          ],
        );
      },
    ).then((result) {
      if (result == true) {
        Provider.of<FlightRepository>(context, listen: false).deleteFlight(widget.flight);
        if (widget.isTablet) {
          _showSnackbar(context, 'Flight deleted successfully!');
        } else {
          Navigator.pop(context, 'deleted'); // 修改此行
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isTablet
          ? null
          : AppBar(
        title: Text('Flight Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.g_translate,
              color: _locale.languageCode == 'en' ? null : Colors.grey[600],
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
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 4.0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: departureCity,
                  decoration: InputDecoration(labelText: 'Departure City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a departure city';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    departureCity = value!;
                  },
                ),
                TextFormField(
                  initialValue: destinationCity,
                  decoration: InputDecoration(labelText: 'Destination City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a destination city';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    destinationCity = value!;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Departure Time: ${DateFormat('yyyy-MM-dd').format(departureTime)}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Arrival Time: ${DateFormat('yyyy-MM-dd').format(arrivalTime)}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _showUpdateDialog,
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      onPressed: _showDeleteDialog,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
