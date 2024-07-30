import 'package:cst2335_app/AppLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:cst2335_app/main.dart';
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
  late TextEditingController idTextCtl;
  late TextEditingController typeTextCtl;
  late TextEditingController passengerTextCtl;
  late TextEditingController rangeTextCtl;
  late TextEditingController speedTextCtl;
  Airplane? selectedPlane;
  late AppDatabase database;
  late AirplaneDAO airplaneDAO;

  Locale _locale = const Locale("en", "CA");

  @override
  void initState() {
    // initialize object, onloaded in HTML
    super.initState();
    idTextCtl = TextEditingController();
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
    idTextCtl.dispose();
    typeTextCtl.dispose();
    passengerTextCtl.dispose();
    rangeTextCtl.dispose();
    speedTextCtl.dispose();
    await database.close();
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    MyApp.setLocale(context, locale); // Assuming MyApp is the root widget.
  }
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(trans.translate('a_title')),
          actions: <Widget>[
        IconButton(
        icon: Icon(Icons.g_translate,
          color: _locale.languageCode == 'en'
              ? null
              : Colors.grey[600],
        ),
      onPressed: () {
        changeLocale(
          _locale.languageCode == 'en' ? const Locale('fr', 'CA') : const Locale('en', 'CA'),
        );
      }, // Switch the language when pressed
    ),
    ]
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
          Expanded(flex: 3, child: Column(children: [DetailsPage()])),
        ],
      );
    } else {
      // Portrait mode
      if (selectedPlane == null) {
        return AirplaneList();
      } else {
        return DetailsPage();
      }
    }
  }

  Widget AirplaneList() {
    var trans = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(children: [
          Text(textAlign: TextAlign.left,
              trans.translate("a_planes_c"))]),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: planes.length,
          itemBuilder: (context, rowNum) {
            // return the widget to go on row : rowNum
            return Card(
                child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedPlane = planes[rowNum];
                        idTextCtl.text = selectedPlane!.id.toString();
                        typeTextCtl.text = selectedPlane!.type;
                        passengerTextCtl.text =
                            selectedPlane!.numPassengers.toString();
                        speedTextCtl.text = selectedPlane!.maxSpeed.toString();
                        rangeTextCtl.text = selectedPlane!.range.toString();
                      });
                    },
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(children: [
                          Icon(CupertinoIcons.airplane, color: Colors.black),
                          Text(planes[rowNum].type)
                        ]))));
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedPlane = Airplane.noid('', -1, -1, -1);
            });
          },
          child: Icon(Icons.add, color: Colors.white),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: Colors.blue, // <-- Button color
            foregroundColor: Colors.red, // <-- Splash color
          ),
        )
      ],
    );
  }

  void deleteAirplane(Airplane plane) {
    var trans = AppLocalizations.of(context)!;
    int index = planes.indexOf(plane);
    if (index < 0 || index > planes.length) {
      return;
    }
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(trans.translate("a_confirmdel_t")),
          content: Text('${trans.translate("a_confirmdel_c")}${planes[index].type}'),
          actions: <Widget>[
            TextButton(
              child: Text(trans.translate("a_yes")),
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
              child: Text(trans.translate("a_no")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget DetailsPage() {
    var trans = AppLocalizations.of(context)!;
    if (selectedPlane == null) {
      return Text(trans.translate("a_nosel"));
    } else {
      Airplane plane = selectedPlane!;
      var edit = [
        PlaneForm(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Padding(
              padding: EdgeInsets.all(4),
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedPlane = null;
                    });
                  },
                  child: Text(trans.translate("a_unsel")))),
          Padding(
              padding: EdgeInsets.all(4),
              child: ElevatedButton(
                  onPressed: () {
                    int index = planes.indexOf(selectedPlane!);
                    Airplane newPlane = Airplane(
                        selectedPlane?.id,
                        typeTextCtl.value.text,
                        int.parse(passengerTextCtl.value.text),
                        int.parse(speedTextCtl.value.text),
                        int.parse(rangeTextCtl.value.text));
                    airplaneDAO.updateAirplane(newPlane);
                    setState(() {
                      planes[index] = newPlane;
                      selectedPlane = newPlane;
                    });
                  },
                  child: Text(trans.translate("a_update")))),
          Padding(
              padding: EdgeInsets.all(4),
              child: ElevatedButton(
                  onPressed: () {
                    deleteAirplane(plane);
                  },
                  child: Text(trans.translate("a_delete")))),
        ]),
      ];
      var add = [
        PlaneForm(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
              onPressed: () {
                addPlane();
              },
              child: Text(trans.translate("a_add"))),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPlane = null;
                });
              },
              child: Text(trans.translate("a_clear"))),
        ])
      ];
      if (selectedPlane!.id == null) {
        return Column(children: add);
      } else {
        return Column(children: edit);
      }
    }
  }

  Widget PlaneForm() {
    var trans = AppLocalizations.of(context)!;
    return Form(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          selectedPlane?.id != null
              ? TextFormField(
                  controller: idTextCtl,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                )
              : Text(trans.translate("a_new_p")),
          TextFormField(
              decoration: InputDecoration(
                icon: Icon(CupertinoIcons.airplane),
                hintText: trans.translate("a_typehint"),
                labelText: trans.translate("a_typelabel"),
              ),
              controller: typeTextCtl),
          TextFormField(
            controller: passengerTextCtl,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: const TextInputType.numberWithOptions(
                decimal: false, signed: false),
            decoration: InputDecoration(
              icon: Icon(CupertinoIcons.person),
              hintText: trans.translate("a_pass_hint"),
              labelText: trans.translate("a_pass_label"),
            ),
          ),
          TextFormField(
            controller: rangeTextCtl,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: const TextInputType.numberWithOptions(
                decimal: false, signed: false),
            decoration: InputDecoration(
                icon: Icon(Icons.route),
                hintText: trans.translate("a_range_hint"),
                labelText: trans.translate("a_range_label")),
          ),
          TextFormField(
            controller: speedTextCtl,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: const TextInputType.numberWithOptions(
                decimal: false, signed: false),
            decoration: InputDecoration(
                icon: Icon(Icons.speed),
                labelText: trans.translate("a_spd_label"),
                hintText: trans.translate("a_spd_hint")),
          ),
        ]));
  }

  //This function gets run when you click the button
  void addPlane() {
    int idx = planes.length;
    Airplane noid = Airplane.noid(
        typeTextCtl.value.text,
        int.parse(passengerTextCtl.value.text),
        int.parse(speedTextCtl.value.text),
        int.parse(rangeTextCtl.value.text));
    setState(() {
      idx = planes.length;
      selectedPlane = noid;
      planes.add(noid);
      typeTextCtl.text = "";
      passengerTextCtl.text = "";
      speedTextCtl.text = "";
      rangeTextCtl.text = "";
    });
    airplaneDAO.insertAirplane(noid).then((id) {
      setState(() {
        planes[idx] = Airplane.fromNoid(id, noid);
        selectedPlane = planes[idx];
      });
    });
  }
}
