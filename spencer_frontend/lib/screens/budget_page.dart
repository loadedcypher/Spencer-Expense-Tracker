import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:spencer_frontend/utils/auth_utils.dart';

class Stack<T> {
  final List<T> _items = [];

  void push(T item) {
    _items.add(item);
  }

  void pushAll(List<T> items) {
    _items.addAll(items);
  }

  T pop() {
    if (isEmpty()) {
      throw StateError('Cannot pop from an empty stack');
    }
    return _items.removeLast();
  }

  T peek() {
    if (isEmpty()) {
      throw StateError('Cannot peek into an empty stack');
    }
    return _items.last;
  }

  bool isEmpty() {
    return _items.isEmpty;
  }

  int size() {
    return _items.length;
  }

  T peekAt(int index) {
    if (index < 0 || index >= size()) {
      throw RangeError.index(index, this, 'index', null, size());
    }
    return _items[index];
  }
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  Stack<dynamic> _budgetStack = Stack<dynamic>();

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
          _budgetStack = Stack<dynamic>();
          _budgetStack.pushAll(json.decode(response.body));
        });
      } else {
        print('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addBudget(dynamic budget) async {
    try {
      String? token = await getToken();
      final requestBody = json.encode(budget);

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

  Future<void> _deleteBudget(dynamic budget) async {
    try {
      String? token = await getToken();
      final response = await http.delete(
        Uri.parse('http://localhost:8000/delete_budget/${budget['category']}'),
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

  void _editBudget(dynamic oldBudget, dynamic newBudget) async {
    try {
      String? token = await getToken();
      final requestBody = json.encode(newBudget);

      final response = await http.put(
        Uri.parse(
            'http://localhost:8000/update_budget/${oldBudget['category']}'),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update budget: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _budgetStack.isEmpty()
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _budgetStack.size(),
              itemBuilder: (context, index) {
                final budget = _budgetStack.peekAt(index);
                return BudgetCard(
                  category: budget['category'],
                  amount: budget['amount'],
                  onDelete: () {
                    _deleteBudget(budget);
                  },
                  onEdit: () {
                    _editBudget(budget, budget);
                  },
                );
              },
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
        String category = '';
        double amount = 0.0;

        return AlertDialog(
          title: const Text('Add Expense'),
          content: Form(
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
                    category = value;
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
                    amount = double.tryParse(value) ?? 0.0;
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
                if (category.isNotEmpty && amount > 0) {
                  _addBudget({'category': category, 'amount': amount});
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
