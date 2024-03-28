import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spencer_frontend/screens/budget_page.dart';
import 'package:spencer_frontend/screens/expenses_page.dart';
import 'dart:convert';

import 'package:spencer_frontend/screens/income_page.dart';
import 'package:spencer_frontend/utils/auth_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String? _username;

  static const List<Widget> _pages = <Widget>[
    IncomePage(),
    ExpensesPage(),
    BudgetPage(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://localhost:8000/get_user_details'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userDetails = json.decode(response.body);
        setState(() {
          _username = userDetails['email'];
        });
      } else {
        print('Failed to get user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _username ?? 'Loading...', // Show username or 'Loading...'
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add functionality for settings
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Budget',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
