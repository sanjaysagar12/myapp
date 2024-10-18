import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class TransferPage extends StatefulWidget {
  final String username;

  TransferPage({required this.username});

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isTransferring = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _transfer() async {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      bool success = await ApiService.transfer(widget.username, amount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer successful')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isTransferring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Transfer', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'To',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue[50],
                              child: Text(
                                widget.username[0].toUpperCase(),
                                style: TextStyle(fontSize: 20, color: Colors.blue[700], fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              widget.username,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 48),
                        Text(
                          'Amount',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[400]!),
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                '₹',
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.black87),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                        SizedBox(height: 48),
                        Text(
                          'From',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue[100]!),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.account_balance_wallet, color: Colors.blue[700]),
                            title: Text('Wallet Balance', style: TextStyle(fontWeight: FontWeight.w600)),
                            trailing: Icon(Icons.check_circle, color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _isTransferring ? null : _transfer,
                  child: _isTransferring
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    // onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}