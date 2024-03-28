import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:spencer_frontend/utils/auth_utils.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({Key? key}) : super(key: key);

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<dynamic> _incomeList = [];
  final _formKey = GlobalKey<FormState>();
  String? _source;
  double _amount = 0.0;

  double _amountSpent = 0.0;
  double _totalIncome = 0.0;
  double _amountLeft = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchIncomeSources();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      String? token = await getToken();
      final responseExpenses = await http.get(
        Uri.parse('http://localhost:8000/all_expenses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final responseIncome = await http.get(
        Uri.parse('http://localhost:8000/get_all_income_sources'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (responseExpenses.statusCode == 200 &&
          responseIncome.statusCode == 200) {
        final List<dynamic> expenses = json.decode(responseExpenses.body);
        final List<dynamic> income = json.decode(responseIncome.body);

        double totalExpenses =
            expenses.fold(0, (prev, curr) => prev + (curr['amount'] ?? 0));
        double totalIncome =
            income.fold(0, (prev, curr) => prev + (curr['amount'] ?? 0));

        setState(() {
          _amountSpent = totalExpenses;
          _totalIncome = totalIncome;
          _amountLeft = _totalIncome - _amountSpent;
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchIncomeSources() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('http://localhost:8000/get_all_income_sources'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _incomeList = json.decode(response.body);
        });
      } else {
        print('Failed to fetch income sources: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addIncome() async {
    try {
      String? token = await getToken();
      final requestBody = json.encode({
        'source': _source,
        'amount': _amount,
      });

      final response = await http.post(
        Uri.parse('http://localhost:8000/add-income'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _fetchIncomeSources();
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income added successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add income: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteIncome(String source) async {
    try {
      String? token = await getToken();
      final response = await http.delete(
          Uri.parse('http://localhost:8000/delete-income/$source'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        _fetchIncomeSources();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete income: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _editIncome(String source) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: source,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a source please';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _source = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _incomeList
                          .firstWhere(
                              (income) => income['source'] == source)['amount']
                          .toString(),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
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
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Call update income API
                          try {
                            String? token = await getToken();

                            final requestBody = json.encode({
                              'source': _source,
                              'amount': _amount,
                            });

                            final response = await http.put(
                              Uri.parse(
                                  'http://localhost:8000/update-income/$source'),
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                              },
                              body: requestBody,
                            );

                            if (response.statusCode == 200) {
                              _fetchIncomeSources();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Income updated successfully'),
                                ),
                              );
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to update income: ${response.statusCode}'),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearForm() {
    setState(() {
      _source = '';
      _amount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Income Page",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            // Card with circular progress bar
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Circular progress bar showing expenditure
                        SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Stack(
                            children: [
                              LinearProgressIndicator(
                                value: _amountSpent / _totalIncome,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${((_amountSpent / _totalIncome) * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Total income amount
                        Text(
                          'Total Income:  BWP $_totalIncome', // Use your total income value
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Text showing spent amount
                    Text(
                      'You have spent BWP $_amountSpent',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // List view showing income sources cards
            Expanded(
              child: ListView.builder(
                itemCount: _incomeList.length,
                itemBuilder: (context, index) {
                  final income = _incomeList[index];
                  return IncomeCard(
                    source: income['source'],
                    amount: income['amount'],
                    onDelete: () {
                      _deleteIncome(income['source']);
                    },
                    onEdit: () {
                      _editIncome(income['source']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddIncomeDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddIncomeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Source',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a source please';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _source = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount',
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
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addIncome();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class IncomeCard extends StatelessWidget {
  final String source;
  final double amount;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  IncomeCard({
    required this.source,
    required this.amount,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: const BoxDecoration(
            color: Colors.amber, // Choose your desired color for the line
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
        ),
        title: Text(source),
        subtitle: Text('Amount: $amount'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
