import 'package:flutter/material.dart';
import 'package:cst2335_app/airplane.dart';
import 'package:cst2335_app/airplanedao.dart';
import 'package:cst2335_app/DataRepository.dart';
import 'package:flutter/services.dart';
import 'database.dart';

class AirplanePage extends StatefulWidget {
  const AirplanePage({super.key});
  @override
  State<AirplanePage> createState() => AirplanePageState();
}

class AirplanePageState extends State<AirplanePage> {
  List<Airplane> planes = [];
  late TextEditingController typeTextCtl;
  late TextEditingController passengerTextCtl;
  late TextEditingController rangeTextCtl;
  late TextEditingController speedTextCtl;
  Airplane? selectedPlane;
  late AppDatabase database;
  late AirplaneDAO airplaneDAO;

  @override
  void initState() {
    // initialize object, onloaded in HTML
    super.initState();
    typeTextCtl = TextEditingController();
    passengerTextCtl = TextEditingController();
    rangeTextCtl = TextEditingController();
    speedTextCtl = TextEditingController();
    DataRepository.loadData().then((done) {
      setState(() {
        typeTextCtl.text = DataRepository.planeType;
        passengerTextCtl.text = DataRepository.planePassengers;
        rangeTextCtl.text = DataRepository.planeRange;
        speedTextCtl.text = DataRepository.planeSpeed;
      });
    });
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) {
      database = db;
      airplaneDAO = database.airplaneDAO;
      airplaneDAO.getAllAirplanes().then((planes) {
        setState(() {
          this.planes.addAll(planes);
        });
      });
    });
  }

  @override
  Future<void> dispose() async {
    //unloading the page
    super.dispose();
    DataRepository.planeType = typeTextCtl.value.text;
    DataRepository.planePassengers = passengerTextCtl.value.text;
    DataRepository.planeRange = rangeTextCtl.value.text;
    DataRepository.planeSpeed = speedTextCtl.value.text;
    DataRepository.saveData();
    typeTextCtl.dispose();
    passengerTextCtl.dispose();
    rangeTextCtl.dispose();
    speedTextCtl.dispose();
    await database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Airplane'),
        ),
        body: responsiveLayout());
  }

  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      // landscape mode
      return Row(
        children: [
          Expanded(flex: 2, child: Center(child: AirplaneList())),
          Expanded(flex: 3, child: Column(children: [DetailsPage(false)])),
        ],
      );
    } else {
      // Portrait mode
      if (selectedPlane == null) {
        return AirplaneList();
      } else {
        return DetailsPage(true);
      }
    }
  }

  Widget AirplaneList() {
    return Center(
      child: Column(
        children: [
          EditWidgets(),
          ElevatedButton(
              onPressed: addPlane,
              child: Text("Add")),
          Expanded(
            child: ListView.builder(
              itemCount: planes.length,
              itemBuilder: (context, rowNum) {
                // return the widget to go on row : rowNum
                return GestureDetector(
                    onTap: () {
                       setState(() {
                         selectedPlane = planes[rowNum];
                         typeTextCtl.text = selectedPlane!.type;
                         passengerTextCtl.text = selectedPlane!.numPassengers.toString();
                         speedTextCtl.text = selectedPlane!.maxSpeed.toString();
                         rangeTextCtl.text = selectedPlane!.range.toString();
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("id: ${planes[rowNum].id ?? ""}"),
                          Text(planes[rowNum].type),
                          Text(planes[rowNum].range.toString()),
                          Text(planes[rowNum].maxSpeed.toString()),
                          Text(planes[rowNum].numPassengers.toString())
                        ]));
              },
            ),
          ),
        ],
      ),
    );
  }

  void deleteAirplane(Airplane plane) {
    int index = planes.indexOf(plane);
    if (index < 0 || index > planes.length) {
      return;
    }
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Confirm Airplane Removal'),
          content: Text('Are you sure you would like to remove:\n' +
          'id:${planes[index].id}\t${planes[index].type}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Airplane tmp = planes[index];
                setState(() {
                  if (selectedPlane == tmp) {
                    selectedPlane = null;
                  }
                  planes.removeAt(index);
                });
                airplaneDAO.deleteAirplane(tmp);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget DetailsPage(bool editWidgets) {
    if (selectedPlane == null) {
      return Text("Nothing is selected");
    } else {
      Airplane plane = selectedPlane!;
      var widgets = [
        Text("id: ${plane.id ?? ""}"),
        Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            children:[
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedPlane = null;
                    });
                  },
                  child: Text("Unselect")),
              ElevatedButton(
                  onPressed: () {
                    int index = planes.indexOf(selectedPlane!);
                    Airplane newPlane = Airplane(selectedPlane?.id,
                        typeTextCtl.value.text,
                        int.parse(passengerTextCtl.value.text),
                        int.parse(speedTextCtl.value.text),
                        int.parse(rangeTextCtl.value.text)
                    );
                    airplaneDAO.updateAirplane(newPlane);
                    setState(() {
                      planes[index] = newPlane;
                      selectedPlane = newPlane;
                    });
                  },
                  child: Text("Update")),
              ElevatedButton(
                  onPressed: () {
                    deleteAirplane(plane);
                  },
                  child: Text("Delete"))])
      ];
      if (editWidgets) {
        widgets.insert(1, EditWidgets());
      }
      return Column(children: widgets);
    }
  }

  Widget EditWidgets() {
    return Column(
      children: [
        Row(
          children: [
            Text("Type"),
            Expanded(
              child:
              TextField(
                controller:typeTextCtl,
                decoration: const InputDecoration(
                  hintText: 'Type',
                ),
              ),
            )
          ]
      ),
        Row(
            children: [
              Text("Passengers"),
              Expanded(
                child:
                TextField(
                  controller:passengerTextCtl,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Passengers',
                  ),
                ),
              )
            ]
        ),
        Row(
            children: [
              Text("Range"),
              Expanded(
                child:
                TextField(
                  controller:rangeTextCtl,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Range in km',
                  ),
                ),
              )
            ]
        ),
        Row(
            children: [
              Text("Speed"),
              Expanded(
                child:
                TextField(
                  controller:speedTextCtl,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Speed in km/h',
                  ),
                ),
              )
            ]
        ),
    ],);
  }
  //This function gets run when you click the button
  void addPlane() {
    int idx = planes.length;
    Airplane noid = Airplane.noid(
        typeTextCtl.value.text,
        int.parse(passengerTextCtl.value.text),
        int.parse(speedTextCtl.value.text),
        int.parse(rangeTextCtl.value.text)
    );
    setState(() {
      idx = planes.length;
      planes.add(noid);
      typeTextCtl.text = "";
      passengerTextCtl.text = "";
      speedTextCtl.text = "";
      rangeTextCtl.text = "";
    });
    airplaneDAO.insertAirplane(noid).then((id) {
      setState(() {
        planes[idx] = Airplane.fromNoid(id, noid);
      });
    });
  }
}
