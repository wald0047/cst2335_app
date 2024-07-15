import 'package:flutter/material.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({super.key});
  @override
  State<FlightPage> createState() => FlightPageState();
}

class FlightPageState extends State<FlightPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flight'),
      ),
      body: Center(
        child: Text('Hello world!'),
      ),
    );
  }
}
