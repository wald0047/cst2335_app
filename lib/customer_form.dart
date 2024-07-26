import 'package:cst2335_app/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/customerdao.dart';
import 'customer_repository.dart';

class CustomerForm extends StatefulWidget {
  final bool
      isAdding; // Flag to indicate if the form is for adding a new customer
  final Customer? selectedItem; // The customer being edited (if any)
  final CustomerDAO dao; // Data Access Object for customer operations
  final VoidCallback
      onSuccess; // Callback function to invoke on successful operation
  final VoidCallback
      onClose; // Callback function to invoke when closing the form

  const CustomerForm({
    super.key,
    required this.isAdding,
    required this.dao,
    required this.onSuccess,
    required this.onClose,
    this.selectedItem,
  });

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

  // Populate the form fields based on whether we are adding or editing
  void _populateForm() {
    if (widget.isAdding) {
      CustomerRepository.loadSwitch();
      switchValue = CustomerRepository.switchValue;
      if (switchValue) _loadForm(); // Load previous data if switch is on
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

  // Load data from repository into the form
  void _loadForm() {
    CustomerRepository.loadData();
    setState(() {
      _firstnameController.text = CustomerRepository.firstName;
      _lastnameController.text = CustomerRepository.lastName;
      _addressController.text = CustomerRepository.address;
      _birthdateController.text = CustomerRepository.birthdate;
    });
  }

  // Save form data to repository
  void _saveForm() {
    CustomerRepository.firstName = _firstnameController.value.text;
    CustomerRepository.lastName = _lastnameController.value.text;
    CustomerRepository.address = _addressController.value.text;
    CustomerRepository.birthdate = _birthdateController.value.text;
    CustomerRepository.saveData();
  }

  // Clear the form fields
  void _clearForm() {
    setState(() {
      _firstnameController.text = "";
      _lastnameController.text = "";
      _addressController.text = "";
      _birthdateController.text = "";
    });
  }

  // Show a date picker and update birthdate field
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

  // Handle form submission
  void handleSubmit() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('c_alert_title')!),
        content: Text(widget.isAdding
            ? AppLocalizations.of(context)!
                .translate('c_create_customer_message')!
            : AppLocalizations.of(context)!
                .translate('c_update_customer_message')!),
        actions: <Widget>[
          ElevatedButton(
              child: Text(
                  AppLocalizations.of(context)!.translate('c_confirm_button')!),
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
                              ? AppLocalizations.of(context)!.translate(
                                  'c_create_customer_success_message')!
                              : AppLocalizations.of(context)!.translate(
                                  'c_update_customer_success_message')!),
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
                            ? AppLocalizations.of(context)!.translate(
                                    'c_create_customer_fail_message')! +
                                e.toString()
                            : AppLocalizations.of(context)!.translate(
                                    'c_update_customer_fail_message')! +
                                e.toString()),
                        backgroundColor: Colors.red));
                  }
                }
                Navigator.pop(context);
              }),
          ElevatedButton(
              child: Text(
                  AppLocalizations.of(context)!.translate('c_cancel_button')!),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  // Handle customer deletion
  void handleDelete() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('c_alert_title')!),
        content: Text(AppLocalizations.of(context)!
            .translate('c_delete_customer_message')!),
        actions: <Widget>[
          ElevatedButton(
              child: Text(
                  AppLocalizations.of(context)!.translate('c_confirm_button')!),
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  try {
                    widget.dao.deleteCustomer(widget.selectedItem!);
                    widget.onSuccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .translate('c_delete_customer_success_message')!),
                          backgroundColor: Colors.green),
                    );
                    _clearForm();
                    widget.onClose();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                                .translate('c_delete_customer_fail_message')! +
                            e.toString()),
                        backgroundColor: Colors.red));
                  }
                }
                Navigator.pop(context);
              }),
          ElevatedButton(
              child: Text(
                  AppLocalizations.of(context)!.translate('c_cancel_button')!),
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
                          Text(AppLocalizations.of(context)!
                              .translate('c_load_customer_data_message')!),
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
                    if (!widget.isAdding)
                      TextFormField(
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
                      decoration: InputDecoration(
                          icon: const Icon(Icons.person),
                          hintText: AppLocalizations.of(context)!
                              .translate('c_first_name_hint_text')!,
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!
                              .translate('c_first_name_label')!),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('c_error_text')!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.perm_identity),
                          hintText: AppLocalizations.of(context)!
                              .translate('c_last_name_hint_text')!,
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!
                              .translate('c_last_name_label')!),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('c_last_name_error_text')!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.house_rounded),
                          hintText: AppLocalizations.of(context)!
                              .translate('c_address_hint_text')!,
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!
                              .translate('c_address_label')!),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('c_address_error_text')!;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _birthdateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: AppLocalizations.of(context)!
                            .translate('c_birthdate_hint_text')!,
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!
                            .translate('c_birthdate_label')!,
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('c_birthdate_error_text')!;
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
                            child: Text(widget.isAdding
                                ? AppLocalizations.of(context)!
                                    .translate('c_create_button')!
                                : AppLocalizations.of(context)!
                                    .translate('c_update_button')!)),
                        const SizedBox(width: 12),
                        if (!widget.isAdding)
                          ElevatedButton(
                              onPressed: handleDelete,
                              child: Text(AppLocalizations.of(context)!
                                  .translate('c_delete_button')!)),
                        const SizedBox(width: 12),
                        ElevatedButton(
                            onPressed: widget.onClose,
                            child: Text(AppLocalizations.of(context)!
                                .translate('c_cancel_button')!)),
                      ],
                    )
                  ],
                ),
              )
            : Center(
                child: Text(
                    AppLocalizations.of(context)!
                        .translate('c_no_selected_customer_message')!,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold))),
      ),
    );
  }
}
