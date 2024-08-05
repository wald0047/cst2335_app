import 'package:cst2335_app/AppLocalizations.dart';
import 'package:cst2335_app/CustomerPage.dart';
import 'package:cst2335_app/airplanepage.dart';
import 'package:cst2335_app/FlightPage.dart';
import 'package:cst2335_app/ReservationPage.dart';
import 'package:cst2335_app/reservationdao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'flightRepository.dart';

/// The entry point of the application.
///
/// This function initializes the application by setting up the database,
/// creating instances of [FlightRepository] and [ReservationDAO], and running
/// the [MyApp] widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final flightRepository = FlightRepository(database);
  final reservationDAO = database.reservationDAO; // Initialize ReservationDAO if needed

  runApp(MyApp(flightRepository: flightRepository, reservationDAO: reservationDAO));
}

/// The root widget of the application.
///
/// [MyApp] sets up the theme, localization, and routing for the application.
/// It also provides [FlightRepository] and [ReservationDAO] instances to the widget
/// tree using the [Provider] package.
class MyApp extends StatefulWidget {
  /// Constructs a [MyApp] widget.
  ///
  /// [flightRepository] is the repository used to manage flight data.
  /// [reservationDAO] is the DAO used to manage reservation data.
  const MyApp({super.key, required this.flightRepository, required this.reservationDAO});
  final FlightRepository flightRepository;
  final ReservationDAO reservationDAO;

  @override
  State<MyApp> createState() {
    return MyAppState();
  }

  /// Sets the locale for the application.
  ///
  /// [context] is the build context in which to set the locale.
  /// [newLocale] is the new locale to be applied.
  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.changeLanguage(newLocale);
  }

  /// Gets the current locale of the application.
  ///
  /// [context] is the build context from which to retrieve the locale.
  /// Returns the current [Locale] of the application.
  static Locale? getLocale(BuildContext context) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    return state?._locale;
  }
}

class MyAppState extends State<MyApp> {
  var _locale = const Locale("en", "CA");

  /// Changes the language of the application.
  ///
  /// [newLocale] is the new locale to be set for the application.
  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.flightRepository,
      child: MaterialApp(
        title: 'Final Project',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        supportedLocales: const <Locale>[
          Locale("en", "CA"),
          Locale("fr", "CA"),
          Locale("zh", "CN"),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        locale: _locale,
        initialRoute: "/",
        routes: {
          '/customer': (context) => const CustomerPage(),
          '/airplane': (context) => const AirplanePage(),
          '/flight': (context) => const FlightPage(),
          '/reservation': (context) => const ReservationPage(),
          '/': (context) => const MyHomePage(title: 'Home'),
        },
      ),
    );
  }
}

/// The home page of the application.
///
/// This widget displays a welcome screen with buttons to navigate to
/// different sections of the application, including Customer, Airplane,
/// Flight, and Reservation pages.
class MyHomePage extends StatefulWidget {
  /// Constructs a [MyHomePage] widget.
  ///
  /// [title] is the title displayed in the app bar.
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var widthIndex = 0.8; // 80% of the screen width
  var spaceBetween = 12.0; // 12 pixels between buttons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: widthIndex,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/customer");
                },
                child: const Text('Customer'),
              ),
            ),
            SizedBox(height: spaceBetween),
            FractionallySizedBox(
              widthFactor: widthIndex,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/airplane");
                },
                child: const Text('Airplane'),
              ),
            ),
            SizedBox(height: spaceBetween),
            FractionallySizedBox(
              widthFactor: widthIndex,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/flight");
                },
                child: const Text('Flights'),
              ),
            ),
            SizedBox(height: spaceBetween),
            FractionallySizedBox(
              widthFactor: widthIndex,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/reservation");
                },
                child: const Text('Reservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
