import 'package:flutter/material.dart';

class AirplanePage extends StatefulWidget {
  const AirplanePage({super.key});
  @override
  State<AirplanePage> createState() => AirplanePageState();
}

class AirplanePageState extends State<AirplanePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Airplane'),
      ),
      body: Center(
        child: Text('Hello world!'),
      ),
    );
  }
}
