import 'package:flutter/material.dart';
import 'package:cst2335_app/CustomerPage.dart';
import 'package:cst2335_app/airplanepage.dart';
import 'package:cst2335_app/FlightPage.dart';
import 'package:cst2335_app/ReservationPage.dart';


void main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Home'),
      initialRoute: "/",
      routes: {
        '/customer': (context) => const CustomerPage(),
        '/airplane': (context) => const AirplanePage(),
        '/flight': (context) => const FlightPage(),
        '/reservation': (context) => const ReservationPage(),
        '/': (context) => const MyHomePage(title: 'Home'),

      }
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
