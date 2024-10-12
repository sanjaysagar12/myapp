import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      final data = await ApiService.getBalance();
      setState(() {
        _balance = data['balance'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load balance: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: RefreshIndicator(
        onRefresh: _fetchBalance,
        child: ListView(
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Your Balance:',
                  ),
                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/deposit');
                      _fetchBalance();
                    },
                    child: Text('Deposit'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/withdraw');
                      _fetchBalance();
                    },
                    child: Text('Withdraw'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/transfer');
                      _fetchBalance();
                    },
                    child: Text('Transfer'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: Text('Transaction History'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}