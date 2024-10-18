import 'package:flutter/material.dart';
import '../main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import "./transfer_page.dart";

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  bool _isLoading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchUsername();
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

  Future<void> _fetchUsername() async {
    try {
      final data = await ApiService.getUserInfo();
      setState(() {
        _username = data['username'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load username: ${e.toString()}')),
      );
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
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
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

  void _showTransferDialog(String username) {
    TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer to $username'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Transfer'),
            onPressed: () {
              // Get the amount from the TextField and call _transfer
              String amountText = _amountController.text.trim();
              if (amountText.isNotEmpty) {
                double amount = double.tryParse(amountText) ?? 0.0;
                if (amount > 0) {
                  Navigator.of(context).pop(); // Close the dialog
                  ApiService.transfer(username, amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please enter a valid amount greater than 0')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter an amount')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your QR Code'),
        content: Container(
          width: 200,
          height: 200,
          child: QrImageView(
            data: _username,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _scanQRCode() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QRViewExample(),
    ));

    if (result == true) {
      // QR scan and transfer were successful, refresh the balance
      await _fetchBalance();
    }
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildActionButton(
                        'Generate QR Code', Icons.qr_code, _showQRCode),
                    SizedBox(height: 10),
                    _buildActionButton(
                        'Scan to Pay', Icons.qr_code_scanner, _scanQRCode),
                    SizedBox(height: 10),
                    _buildActionButton('Transfer', Icons.send, () async {
                      await Navigator.pushNamed(context, '/transfer');
                      _fetchBalance();
                    }),
                    SizedBox(height: 10),
                    _buildActionButton('Transaction History', Icons.history,
                        () {
                      Navigator.pushNamed(context, '/history');
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan result: $result'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData.code!;
      });
      controller.pauseCamera();
      bool? success = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TransferPage(username: scanData.code!),
        ),
      );
      if (success == true) {
        Navigator.of(context)
            .pop(true); // Return true to HomeScreen if transfer was successful
      } else {
        controller
            .resumeCamera(); // Resume camera if user returns without transferring
      }
    });
  }
// Remove the _showTransferDialog and _transfer methods as they're no longer needed

  void _showTransferDialog(String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer to $username'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
          onSubmitted: (value) => _transfer(username, double.parse(value)),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Transfer'),
            onPressed: () {
              // Get the amount from the TextField and call _transfer
            },
          ),
        ],
      ),
    );
  }

  void _transfer(String toUsername, double amount) async {
    try {
      bool success = await ApiService.transfer(toUsername, amount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer successful')),
        );
        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Return to HomeScreen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
