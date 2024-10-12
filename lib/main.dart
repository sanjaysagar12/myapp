import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/withdraw_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/transaction_history_screen.dart';

void main() {
  runApp(BankApp());
}

class BankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bank App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/deposit': (context) => DepositScreen(),
        '/withdraw': (context) => WithdrawScreen(),
        '/transfer': (context) => TransferScreen(),
        '/history': (context) => TransactionHistoryScreen(),
      },
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://simplebank.portos.site';
  static String? token;

 
  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'username': username, 'password': password},
    );

    return response.statusCode == 201;
  }

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      token = data['access_token'];
      return true;
    }
    return false;
  }

  static Future<Map<String, dynamic>> getBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/balance'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'balance': double.parse(data['balance'].toString())};
    }
    throw Exception('Failed to load balance: ${response.body}');
  }

  static Future<bool> deposit(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/deposit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'amount': amount.toString()},
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Deposit failed: ${response.body}');
  }

  static Future<bool> withdraw(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/withdraw'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'amount': amount.toString()},
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Withdrawal failed: ${response.body}');
  }

  static Future<bool> transfer(String toUsername, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'to_username': toUsername,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Transfer failed: ${response.body}');
  }
  static Future<List<dynamic>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load transactions');
  }
}