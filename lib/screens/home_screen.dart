import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await ApiService.getBalance();
      setState(() {
        _balance = data['balance'];
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load balance: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Current Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '\$${_balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchBalance,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBalance,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBalanceCard(),
                    SizedBox(height: 20),
                    Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildActionButton('Deposit', Icons.add, () async {
                      await Navigator.pushNamed(context, '/deposit');
                      _fetchBalance();
                    }),
                    SizedBox(height: 10),
                    _buildActionButton('Withdraw', Icons.remove, () async {
                      await Navigator.pushNamed(context, '/withdraw');
                      _fetchBalance();
                    }),
                    SizedBox(height: 10),
                    _buildActionButton('Transfer', Icons.send, () async {
                      await Navigator.pushNamed(context, '/transfer');
                      _fetchBalance();
                    }),
                    SizedBox(height: 10),
                    _buildActionButton('Transaction History', Icons.history, () {
                      Navigator.pushNamed(context, '/history');
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}