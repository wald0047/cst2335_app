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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final flightRepository = FlightRepository(database);
  final reservationDAO = database.reservationDAO; // Initialize ReservationDAO if needed

  runApp(MyApp(flightRepository: flightRepository, reservationDAO: reservationDAO));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.flightRepository, required this.reservationDAO});
  final FlightRepository flightRepository;
  final ReservationDAO reservationDAO;

  @override
  State<MyApp> createState() {
    return MyAppState();
  }

  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.changeLanguage(newLocale);
  }
  static Locale? getLocale(BuildContext context) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    return state?._locale;
  }
}

class MyAppState extends State<MyApp> {
  var _locale = const Locale("en", "CA");

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var widthIndex = 0.8; // 80% of the screen width
  var spaceBetween = 12.0; // 12 between buttons

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
