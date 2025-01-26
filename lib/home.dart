import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'BDT';
  String _result = '';
  List<String> _currencies = [];
  bool _isLoading = false; // For tracking loading state

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error fetching currencies: $e';
      });
    }
  }

  Future<void> _convertCurrency() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _result = 'Invalid amount';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$_fromCurrency');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final rates = json.decode(response.body)['rates'];
        final double rate = rates[_toCurrency];
        setState(() {
          _result = '${(amount * rate).toStringAsFixed(2)} $_toCurrency';
        });
      } else {
        setState(() {
          _result = 'Failed to fetch rates';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Amount',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _fromCurrency,
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                    });
                  },
                ),
                const Icon(Icons.swap_horiz),
                DropdownButton<String>(
                  value: _toCurrency,
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _convertCurrency,
                child: const Text('Convert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: Size.fromWidth(double.maxFinite),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 100),
           _result.isNotEmpty? Center(
              child: _isLoading
                  ? const CircularProgressIndicator() // Loader
                  : Card(
                color: Colors.teal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Result: $_result',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ):Container(),
          ],
        ),
      ),
    );
  }
}
