import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/customerdao.dart';
import 'customer_repository.dart';

class CustomerForm extends StatefulWidget {
  final bool isAdding;
  final Customer? selectedItem;
  final CustomerDAO dao;
  final VoidCallback onSuccess;
  final VoidCallback onClose;

  const CustomerForm(
      {super.key,
      required this.isAdding,
      required this.dao,
      required this.onSuccess,
      required this.onClose,
      this.selectedItem});

  @override
  CustomerFormState createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm> {
  late TextEditingController _idController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _addressController;
  late TextEditingController _birthdateController;
  final _formKey = GlobalKey<FormState>();
  bool switchValue = true;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _addressController = TextEditingController();
    _birthdateController = TextEditingController();
    _populateForm();
  }

  @override
  void didUpdateWidget(CustomerForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAdding != oldWidget.isAdding ||
        widget.selectedItem != oldWidget.selectedItem) {
      _populateForm();
    }
  }

  void _populateForm() {
    if (widget.isAdding) {
      CustomerRepository.loadSwitch();
      switchValue = CustomerRepository.switchValue;
      if (switchValue) _loadForm();
    } else if (widget.selectedItem != null) {
      setState(() {
        _idController.text = widget.selectedItem!.id.toString();
        _firstnameController.text = widget.selectedItem!.firstName;
        _lastnameController.text = widget.selectedItem!.lastName;
        _addressController.text = widget.selectedItem!.address;
        _birthdateController.text =
            DateFormat('yyyy/MM/dd').format(widget.selectedItem!.birthdate);
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    CustomerRepository.switchValue = switchValue;
    CustomerRepository.saveSwitch();
    super.dispose();
  }

  void _loadForm() {
    CustomerRepository.loadData();
    setState(() {
      _firstnameController.text = CustomerRepository.firstName;
      _lastnameController.text = CustomerRepository.lastName;
      _addressController.text = CustomerRepository.address;
      _birthdateController.text = CustomerRepository.birthdate;
    });
  }

  void _saveForm() {
    CustomerRepository.firstName = _firstnameController.value.text;
    CustomerRepository.lastName = _lastnameController.value.text;
    CustomerRepository.address = _addressController.value.text;
    CustomerRepository.birthdate = _birthdateController.value.text;
    CustomerRepository.saveData();
  }

  void _clearForm() {
    setState(() {
      _firstnameController.text = "";
      _lastnameController.text = "";
      _addressController.text = "";
      _birthdateController.text = "";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy/MM/dd').format(picked);
      });
    }
  }

  void handleSubmit() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Alert'),
        content: const Text("Do you want to create the customer?"),
        actions: <Widget>[
          ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  try {
                    final DateFormat formatter = DateFormat('yyyy/MM/dd');
                    DateTime birthdate =
                        formatter.parse(_birthdateController.value.text);
                    Customer item = Customer(
                        widget.isAdding
                            ? Customer.ID++
                            : widget.selectedItem!.id,
                        _firstnameController.value.text,
                        _lastnameController.value.text,
                        _addressController.value.text,
                        birthdate);
                    widget.isAdding
                        ? widget.dao.insertCustomer(item)
                        : widget.dao.updateCustomer(item);
                    widget.onSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(widget.isAdding
                              ? 'Customer added!'
                              : 'Customer updated!'),
                          backgroundColor: Colors.green),
                    );
                    if (widget.isAdding) {
                      _saveForm();
                      _clearForm();
                      widget.onClose();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.isAdding
                            ? "Fail to add the customer: $e"
                            : "Fail to update the customer: $e"),
                        backgroundColor: Colors.red));
                  }
                }
                Navigator.pop(context);
              }),
          ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  void handleDelete() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Alert'),
        content: const Text("Do you want to delete this customer?"),
        actions: <Widget>[
          ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  try {
                    widget.dao.deleteCustomer(widget.selectedItem!);
                    widget.onSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Customer deleted!'),
                          backgroundColor: Colors.green),
                    );
                    _clearForm();
                    widget.onClose();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Fail to delete the customer: $e"),
                        backgroundColor: Colors.red));
                  }
                }
                Navigator.pop(context);
              }),
          ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      margin: const EdgeInsets.all(16.0),
      child: widget.isAdding || widget.selectedItem != null
          ? Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 36),
                  const Icon(
                    Icons.account_circle,
                    size: 120,
                  ),
                  const SizedBox(height: 24),
                  if (widget.isAdding)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const Text(
                            'Load the previous customer data?'), // Label for the switch
                        const SizedBox(width: 8),
                        Switch(
                          value: switchValue,
                          onChanged: (value) {
                            setState(() {
                              switchValue = value;
                            });
                            value ? _loadForm() : _clearForm();
                          },
                        ),
                      ],
                    ),
                  if(!widget.isAdding) TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                        labelText: "ID"),
                    enabled: false,
                  ),
                  SizedBox(height: widget.isAdding ? 12 : 24),
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: "Enter your first name ...",
                        border: OutlineInputBorder(),
                        labelText: "First Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.perm_identity),
                        hintText: "Enter your last name ...",
                        border: OutlineInputBorder(),
                        labelText: "Last Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.house_rounded),
                        hintText: "Enter your address ...",
                        border: OutlineInputBorder(),
                        labelText: "Address"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      labelText: "Birthdate",
                      hintText: "Select your birthdate",
                    ),
                    onTap: () {
                      _selectDate(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your birthdate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: handleSubmit,
                          child: Text(widget.isAdding ? "Create" : "Update")),
                      const SizedBox(width: 12),
                      if (!widget.isAdding)
                        ElevatedButton(
                            onPressed: handleDelete,
                            child: const Text("Delete")),
                      const SizedBox(width: 12),
                      ElevatedButton(
                          onPressed: widget.onClose,
                          child: const Text("Cancel")),
                    ],
                  )
                ],
              ),
            )
          : const Center(
              child: Text("No customer is selected.",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold))),
    ));
  }
}
