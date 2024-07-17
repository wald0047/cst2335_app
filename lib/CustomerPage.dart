import 'package:flutter/material.dart';
import 'package:cst2335_app/database.dart';
import 'package:cst2335_app/customerdao.dart';
import 'package:cst2335_app/customer.dart';
import 'package:cst2335_app/customer_form.dart';
import 'package:cst2335_app/customer_list.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});
  @override
  State<CustomerPage> createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {

  late CustomerDAO dao;
  var customers = <Customer>[];
  var list = <Customer>[];
  String keyword = "";

  Customer? selectedItem;
  bool isAdding = false;

  void _loadDatabase() async {
    var database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    dao = database.customerDAO;
    _loadCustomers();
  }

  void _loadCustomers() async {
    var items = await dao.getAllCustomers();
    customers.clear();
    setState(() {
      customers.addAll(items);
      _filterList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }


  void _filterList(){
    setState(() {
      list = keyword.isEmpty ? customers : customers.where((item){
        return item.firstName.toLowerCase().contains(keyword.toLowerCase()) ||
            item.lastName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Widget listPage() {
    return CustomerList(
        customers: list,
        onSearchCustomer: (String keyword){
          setState(() {
            this.keyword = keyword;
            _filterList();
          });
        },
        onAddCustomer: () {
          setState(() {
            isAdding = true;
          });
        },
        onSelectCustomer: (Customer item) {
          setState(() {
            selectedItem = item;
          });
        });
  }

  Widget formPage() {
    return CustomerForm(
        dao: dao,
        isAdding: isAdding,
        selectedItem: selectedItem,
        onSuccess: _loadCustomers,
        onClose: () {
          setState(() {
            if (isAdding) {
              isAdding = false;
            } else if (selectedItem != null) {
              selectedItem = null;
            }
          });
        });
  }

  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    if ((width > height) && (width > 720)) {
      return Row(children: [
        Expanded(flex: 1, child: listPage()), //Left side
        Expanded(flex: 2, child: formPage()) //Right side
      ]);
    } else {
      return isAdding || selectedItem != null ? formPage() : listPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Customer'),
      ),
      body: responsiveLayout(),
    );
  }
}
