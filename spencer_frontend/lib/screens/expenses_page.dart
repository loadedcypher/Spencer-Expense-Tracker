import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:spencer_frontend/utils/auth_utils.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<dynamic> _expenses = [];
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String? _selectedCategory;
  double _amountSpent = 0.0;
  DateTime _expenseDate = DateTime.now();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _fetchCategories();
  }

  Future<void> _fetchExpenses() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://localhost:8000/all_expenses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _expenses = json.decode(response.body);
        });
      } else {
        print('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchCategories() async {
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
          _categories = List<String>.from(
            json.decode(response.body).map((budget) => budget['category']),
          );
        });
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addExpense() async {
    try {
      String? token = await getToken();

      final requestBody = json.encode({
        'title': _title,
        'description': _description,
        'amount_spent': _amountSpent,
        'expense_category': _selectedCategory
      });

      final response = await http.post(
        Uri.parse('http://localhost:8000/add-expense'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _fetchExpenses();
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateExpense(String id) async {
    try {
      String? token = await getToken();

      final requestBody = json.encode({
        'title': _title,
        'description': _description,
        'amount_spent': _amountSpent,
        'expense_category': _selectedCategory,
        'date_spent': _expenseDate.toIso8601String(),
      });

      final response = await http.put(
        Uri.parse('http://localhost:8000/update-expense/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _fetchExpenses();
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update expense: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      String? token = await getToken();

      final response = await http.delete(
        Uri.parse('http://localhost:8000/delete-expense/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchExpenses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete expense: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _clearForm() {
    setState(() {
      _title = "";
      _description = "";
      _selectedCategory = null;
      _amountSpent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _expenses.isNotEmpty
          ? ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        decoration: const BoxDecoration(
                          color: Colors
                              .blue, // Choose your desired color for the line
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                      title: Text(
                        expense['title'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Amount: BWP${expense['amount_spent'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${DateTime.parse(expense['date_spent']).toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditExpenseDialog(expense);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteExpense(expense['_id']);
                            },
                          ),
                        ],
                      ),
                    ));
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog() {
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
                    labelText: 'Expense Title',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _title = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _description = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Expense Category',
                  ),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an expense category';
                    }
                    return null;
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
                    _amountSpent = double.parse(value);
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
                  _addExpense();
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

  void _showEditExpenseDialog(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: expense['title'],
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _title = value;
                  },
                ),
                TextFormField(
                  initialValue: expense['description'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _description = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Expense Category',
                  ),
                  value: expense['expense_category'],
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an expense category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: expense['amount_spent'].toString(),
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
                    _amountSpent = double.parse(value);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(expense['date_spent']),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _expenseDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                      'When did you purchase this?: ${_expenseDate.toString().split(' ')[0]}'),
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
                  _updateExpense(expense['_id']);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
