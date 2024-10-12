import 'package:flutter/material.dart';
import '../main.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final transactions = await ApiService.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTransactionItem(dynamic transaction) {
    IconData icon;
    Color color;
    String title;

    switch (transaction['type']) {
      case 'deposit':
        icon = Icons.arrow_downward;
        color = Colors.green;
        title = 'Deposit';
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        color = Colors.red;
        title = 'Withdrawal';
        break;
      case 'transfer':
        icon = Icons.swap_horiz;
        color = Colors.blue;
        title = transaction['from_user_id'] != null ? 'Received Transfer' : 'Sent Transfer';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        title = 'Unknown';
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          transaction['timestamp'],
        ),
        trailing: Text(
          '\$${transaction['amount'].toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTransactions,
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(_transactions[index]);
                    },
                  ),
                ),
    );
  }
}