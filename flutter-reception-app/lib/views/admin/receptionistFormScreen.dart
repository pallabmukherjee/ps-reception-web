import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';

class ReceptionistFormScreen extends StatefulWidget {
  @override
  _ReceptionistFormScreenState createState() => _ReceptionistFormScreenState();
}

class _ReceptionistFormScreenState extends State<ReceptionistFormScreen> {
  int _selectedIndex = 1; // Track the selected index for BottomNavigationBar
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _receptionistNameController = TextEditingController();
  final TextEditingController _receptionistMobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('receptionist_name');
    String? savedMobile = prefs.getString('receptionist_mobile');

    if (savedName != null) {
      _receptionistNameController.text = savedName;
    }
    if (savedMobile != null) {
      _receptionistMobileController.text = savedMobile;
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('receptionist_name', _receptionistNameController.text);
    prefs.setString('receptionist_mobile', _receptionistMobileController.text);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved successfully!')));
    Navigator.pushReplacementNamed(context, '/adminhome');
  }

  // Remove saved data (for logout)
  Future<void> _removeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('receptionist_name');
    prefs.remove('receptionist_mobile');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data removed on logout')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Receptionist Form", showBackButton: true),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              // Receptionist Name
              TextFormField(
                controller: _receptionistNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Receptionist Name"),
                  hintText: "Enter Receptionist Name",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter the receptionist name' : null,
              ),
              SizedBox(height: 20),
              // Receptionist Mobile
              TextFormField(
                controller: _receptionistMobileController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Receptionist Mobile"),
                  hintText: "Enter Receptionist Mobile",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter the receptionist mobile number' : null,
              ),
              SizedBox(height: 20),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _saveData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFa3d95d),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Save Data", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
              SizedBox(height: 50),
              Text(
                "Submitted complain can be edited or deleted before end duty. No complain can be edited or deleted after end duty.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 25), // Add some space between the two texts
              Text(
                "সাবমিট করা কমপ্লেন ডিউটি এন্ড করার আগে পর্যন্ত এডিট বা ডিলিট করা যাবে। ডিউটি এন্ড করার পর আর কমপ্লেন এডিট বা ডিলিট করা যাবে না।",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
