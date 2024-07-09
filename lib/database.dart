// database.dart

// required package imports
import 'dart:async';
import 'package:cst2335_app/airplane.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/flight.dart';
import 'package:cst2335_app/reservation.dart';
import 'package:cst2335_app/airplanedao.dart';
import 'package:cst2335_app/customerdao.dart';
import 'package:cst2335_app/flightdao.dart';
import 'package:cst2335_app/reservationdao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Airplane,Customer,Flight,Reservation])
abstract class AppDatabase extends FloorDatabase {
  AirplaneDAO get airplaneDAO;
  CustomerDAO get customerDAO;
  FlightDAO get flightDAO;
  ReservationDAO get reservationDAO;
}