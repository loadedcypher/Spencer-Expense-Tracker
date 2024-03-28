import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:spencer_frontend/utils/auth_utils.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<dynamic> _budget_list = [];
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://localhost:8000/get_all_budgets'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _budget_list = json.decode(response.body);
        });
      } else {
        print('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addBudget() async {
    try {
      String? token = await getToken();

      final requestBody = json.encode({
        'category': _category,
        'amount': _amount,
      });

      final response = await http.post(
        Uri.parse('http://localhost:8000/add_budget'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _fetchBudgets();
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget added successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add budget: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _clearForm() {
    setState(() {
      _category = '';
      _amount = 0.0;
    });
  }

  Future<void> _deleteBudget(String category) async {
    try {
      String? token = await getToken();

      final response = await http.delete(
        Uri.parse('http://localhost:8000/delete_budget/$category'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchBudgets();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete budget: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _editBudget(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Budget'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Budget Category',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a Budget category please';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _amount.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Amount Spent',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _amount = double.parse(value);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Call update budget API
                  try {
                    String? token = await getToken();

                    final requestBody = json.encode({
                      'category': _category,
                      'amount': _amount,
                    });

                    final response = await http.put(
                      Uri.parse(
                          'http://localhost:8000/update_budget/$category'),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: requestBody,
                    );

                    if (response.statusCode == 200) {
                      _fetchBudgets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget updated successfully'),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to update budget: ${response.statusCode}'),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error: $e');
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _budget_list.isNotEmpty
          ? ListView.builder(
              itemCount: _budget_list.length,
              itemBuilder: (context, index) {
                final budget = _budget_list[index];
                return BudgetCard(
                  category: budget['category'],
                  amount: budget['amount'],
                  onDelete: () {
                    _deleteBudget(budget['category']);
                  },
                  onEdit: () {
                    _editBudget(budget['category']);
                  },
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBudgetDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Budget Category',
                      hintText:
                          'Budget Category e.g (Groceries, Toiletries..)'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a Budget category please';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _category = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount Spent',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _amount = double.parse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addBudget();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class BudgetCard extends StatelessWidget {
  final String category;
  final double amount;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  BudgetCard({
    required this.category,
    required this.amount,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
        color: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text('Amount: $amount'),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
