import 'package:cst2335_app/AppLocalizations.dart';
import 'package:country_flags/country_flags.dart';
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
  List<Airplane> _planes = [];
  late TextEditingController _idTextCtl;
  late TextEditingController _typeTextCtl;
  late TextEditingController _passengerTextCtl;
  late TextEditingController _rangeTextCtl;
  late TextEditingController _speedTextCtl;
  Airplane? _selectedPlane;
  late AppDatabase _database;
  late AirplaneDAO _airplaneDAO;
  final _formKey = GlobalKey<FormState>();

  Locale _locale = const Locale("en", "CA");

  @override
  void initState() {
    // initialize object, onloaded in HTML
    super.initState();
    _idTextCtl = TextEditingController();
    _typeTextCtl = TextEditingController();
    _passengerTextCtl = TextEditingController();
    _rangeTextCtl = TextEditingController();
    _speedTextCtl = TextEditingController();
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) {
      _database = db;
      _airplaneDAO = _database.airplaneDAO;
      _airplaneDAO.getAllAirplanes().then((planes) {
        setState(() {
          this._planes.addAll(planes);
        });
      });
    });
  }

  @override
  Future<void> dispose() async {
    //unloading the page
    super.dispose();
    _idTextCtl.dispose();
    _typeTextCtl.dispose();
    _passengerTextCtl.dispose();
    _rangeTextCtl.dispose();
    _speedTextCtl.dispose();
    await _database.close();
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    MyApp.setLocale(context, locale); // Assuming MyApp is the root widget.
  }

  void _showInstructions() {
    var trans = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(trans.translate('a_instructions_t')),
          content: Text(
            trans.translate('a_instructions_c'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog.
              },
              child: Text(trans.translate("a_ok")),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    _locale = MyApp.getLocale(context) ?? const Locale('en', 'CA');
    switch (_locale.languageCode) {
      case 'en' || 'fr':
        break;
      default:
        _locale = const Locale('en', 'CA');
    }
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(trans.translate('a_title')),
            actions: <Widget>[
              Row(children: [
                Text(trans.translate("a_trans")),
                InkWell(
                    onTap: () {
                      _changeLocale(
                        _locale.languageCode == 'en'
                            ? const Locale('fr', 'CA')
                            : const Locale('en', 'CA'),
                      );
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.5),
                        child: CountryFlag.fromLanguageCode(
                            width: 48,
                            height: 32,
                            _locale.languageCode == 'en' ? 'fr' : 'en'))),
              ]),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed:
                    _showInstructions, // Show the help dialog when the icon is pressed.
              ),
            ]),
        body: _responsiveLayout());
  }

  Widget _responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      // landscape mode
      return Row(
        children: [
          Expanded(flex: 2, child: Center(child: _airplaneList())),
          Expanded(flex: 3, child: Column(children: [_detailsPage()])),
        ],
      );
    } else {
      // Portrait mode
      if (_selectedPlane == null) {
        return _airplaneList();
      } else {
        return _detailsPage();
      }
    }
  }

  Widget _airplaneList() {
    var trans = AppLocalizations.of(context)!;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [
            Text(textAlign: TextAlign.left, trans.translate("a_planes_c"))
          ]),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _planes.length,
            itemBuilder: (context, rowNum) {
              // return the widget to go on row : rowNum
              return Card(
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPlane = _planes[rowNum];
                          _idTextCtl.text = _selectedPlane!.id.toString();
                          _typeTextCtl.text = _selectedPlane!.type;
                          _passengerTextCtl.text =
                              _selectedPlane!.numPassengers.toString();
                          _speedTextCtl.text =
                              _selectedPlane!.maxSpeed.toString();
                          _rangeTextCtl.text = _selectedPlane!.range.toString();
                        });
                      },
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(children: [
                            Icon(CupertinoIcons.airplane, color: Colors.black),
                            Text(_planes[rowNum].type)
                          ]))));
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _resetSelectedPlane();
                _selectedPlane = Airplane.noid('', -1, -1, -1);
              });
            },
            child: Icon(Icons.add, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: Colors.blue,
              // <-- Button color
              foregroundColor: Colors.red, // <-- Splash color
            ),
          ),
        ],
      ))
    ]);
  }

  void _deleteAirplane(Airplane plane) {
    var trans = AppLocalizations.of(context)!;
    int index = _planes.indexOf(plane);
    if (index < 0 || index > _planes.length) {
      return;
    }
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(trans.translate("a_confirmdel_t")),
          content:
              Text('${trans.translate("a_confirmdel_c")}${_planes[index].type}'),
          actions: <Widget>[
            FilledButton(
              child: Text(trans.translate("a_yes")),
              onPressed: () {
                Airplane tmp = _planes[index];
                setState(() {
                  if (_selectedPlane == tmp) {
                    _resetSelectedPlane();
                  }
                  _planes.removeAt(index);
                });
                _airplaneDAO.deleteAirplane(tmp);
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

  Widget _detailsPage() {
    var trans = AppLocalizations.of(context)!;
    if (_selectedPlane == null) {
      return Text(trans.translate("a_nosel"));
    } else {
      Airplane plane = _selectedPlane!;
      var edit = [
        _planeForm(),
        Container(
            margin: EdgeInsets.all(4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _resetSelectedPlane();
                        });
                      },
                      child: Row(children: [
                        Icon(Icons.undo),
                        Text(trans.translate("a_unsel"))
                      ])),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          int index = _planes.indexOf(_selectedPlane!);
                          Airplane newPlane = Airplane(
                              _selectedPlane?.id,
                              _typeTextCtl.value.text,
                              int.parse(_passengerTextCtl.value.text),
                              int.parse(_speedTextCtl.value.text),
                              int.parse(_rangeTextCtl.value.text));
                          _airplaneDAO.updateAirplane(newPlane);
                          setState(() {
                            _planes[index] = newPlane;
                            _selectedPlane = newPlane;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(trans.translate("a_updated"))),
                          );
                        }
                      },
                      child: Row(children: [
                        Icon(Icons.save),
                        Text(trans.translate("a_update"))
                      ])),
                  ElevatedButton(
                      onPressed: () {
                        _deleteAirplane(plane);
                      },
                      child: Row(children: [
                        Icon(Icons.delete),
                        Text(trans.translate("a_delete"))
                      ])),
                ])),
      ];
      var add = [
        _planeForm(),
        Container(
            margin: EdgeInsets.all(4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveToDataRepo();
                          _addPlane();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(trans.translate("a_added"))),
                          );
                        }
                      },
                      child: Row(children: [
                        Icon(Icons.save),
                        Text(trans.translate("a_add"))
                      ])),
                  ElevatedButton(
                      onPressed: () {
                        _reloadFromDataRepo();
                      },
                      child: Row(children: [
                        Icon(Icons.refresh),
                        Text(trans.translate("a_reload"))
                      ])),
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _saveToDataRepo();
                          _resetSelectedPlane();
                        });
                      },
                      child: Row(children: [
                        Icon(Icons.cancel),
                        Text(trans.translate("a_clear"))
                      ])),
                ]))
      ];
      if (_selectedPlane!.id == null) {
        return Column(children: add);
      } else {
        return Column(children: edit);
      }
    }
  }

  Widget _planeForm() {
    var trans = AppLocalizations.of(context)!;
    return Form(
        key: _formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _selectedPlane?.id != null
                  ? TextFormField(
                      controller: _idTextCtl,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      enabled: false)
                  : Text(trans.translate("a_new_p")),
              TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(CupertinoIcons.airplane),
                    hintText: trans.translate("a_typehint"),
                    labelText: trans.translate("a_typelabel"),
                  ),
                  controller: _typeTextCtl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  }),
              TextFormField(
                  controller: _passengerTextCtl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                    icon: Icon(CupertinoIcons.person),
                    hintText: trans.translate("a_pass_hint"),
                    labelText: trans.translate("a_pass_label"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an integer';
                    }
                    return null;
                  }),
              TextFormField(
                  controller: _rangeTextCtl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                      icon: Icon(Icons.route),
                      hintText: trans.translate("a_range_hint"),
                      labelText: trans.translate("a_range_label")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an integer';
                    }
                    return null;
                  }),
              TextFormField(
                  controller: _speedTextCtl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                      icon: Icon(Icons.speed),
                      labelText: trans.translate("a_spd_label"),
                      hintText: trans.translate("a_spd_hint")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an integer';
                    }
                    return null;
                  }),
            ]));
  }

  void _reloadFromDataRepo() {
    DataRepository.loadData().then((done) {
      setState(() {
        _typeTextCtl.text = DataRepository.planeType;
        _passengerTextCtl.text = DataRepository.planePassengers;
        _rangeTextCtl.text = DataRepository.planeRange;
        _speedTextCtl.text = DataRepository.planeSpeed;
      });
    });
  }

  void _saveToDataRepo() {
    DataRepository.planeType = _typeTextCtl.value.text;
    DataRepository.planePassengers = _passengerTextCtl.value.text;
    DataRepository.planeRange = _rangeTextCtl.value.text;
    DataRepository.planeSpeed = _speedTextCtl.value.text;
    DataRepository.saveData();
  }

  void _resetSelectedPlane() {
    _selectedPlane = null;
    _idTextCtl.text = "";
    _typeTextCtl.text = "";
    _passengerTextCtl.text = "";
    _speedTextCtl.text = "";
    _rangeTextCtl.text = "";
  }

  //This function gets run when you click the button
  void _addPlane() {
    int idx = _planes.length;
    Airplane noid = Airplane.noid(
        _typeTextCtl.value.text,
        int.parse(_passengerTextCtl.value.text),
        int.parse(_speedTextCtl.value.text),
        int.parse(_rangeTextCtl.value.text));
    setState(() {
      idx = _planes.length;
      _selectedPlane = noid;
      _planes.add(noid);
    });
    _airplaneDAO.insertAirplane(noid).then((id) {
      setState(() {
        _planes[idx] = Airplane.fromNoid(id, noid);
        _selectedPlane = _planes[idx];
      });
    });
  }
}
