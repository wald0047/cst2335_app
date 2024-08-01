import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flight.dart';
import 'flightRepository.dart';
import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/main.dart';

/// A page that allows the user to add a new flight.
///
/// The user can input the departure city, destination city, departure time, and arrival time.
/// The user can also change the language of the app and view instructions for using the app.
class AddFlightPage extends StatefulWidget {
  const AddFlightPage({Key? key}) : super(key: key);

  @override
  _AddFlightPageState createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  final _formKey = GlobalKey<FormState>();
  late String departureCity;
  late String destinationCity;
  DateTime? departureTime;
  DateTime? arrivalTime;
  Locale _locale = const Locale("en", "CA");

  /// Allows the user to select a date from a date picker.
  ///
  /// [context] is the BuildContext of the widget.
  /// [isDeparture] indicates whether the selected date is for the departure time (true) or arrival time (false).
  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isDeparture ? departureTime : arrivalTime)) {
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

  @override
  Widget build(BuildContext context) {
    final flightRepository = Provider.of<FlightRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Flight'),
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
                    Text(
                      departureTime == null
                          ? 'Select Departure Time'
                          : 'Departure Time: ${departureTime.toString()}',
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      arrivalTime == null
                          ? 'Select Arrival Time'
                          : 'Arrival Time: ${arrivalTime.toString()}',
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && departureTime != null && arrivalTime != null) {
                      _formKey.currentState!.save();
                      final newFlight = Flight(
                        departureCity: departureCity,
                        destinationCity: destinationCity,
                        departureTime: departureTime!,
                        arrivalTime: arrivalTime!,
                      );
                      flightRepository.insertFlight(newFlight);
                      Navigator.pop(context, true);
                      _showSnackbar(context, 'Flight added successfully!');
                    }
                  },
                  child: Text('Add Flight'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
