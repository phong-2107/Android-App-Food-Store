import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_android_final/config/config_url.dart';

class CustomerOrderPage extends StatefulWidget {
  const CustomerOrderPage({super.key});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}OrderM'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['\$values'] != null && jsonResponse['\$values'] is List) {
          final data = jsonResponse['\$values'] as List<dynamic>;
          setState(() {
            orders.clear();
            orders.addAll(data.map((item) {
              return {
                "idOrder": item['idOrder'] ?? -1,
                "idUser": item['id'] ?? '',
                "idCanteen": item['idCanteen'] ?? '',
                "amount": item['amount'] ?? 0.0,
                "vatValue": item['vatValue'] ?? 0.0,
                "finalAmount": item['finalAmount'] ?? 0.0,
                "specialNote": item['specialNote'] ?? '',
                "creationDate": item['creDate'] ?? '',
              };
            }).toList());
          });
        } else {
          print("Error: `\$values` is null or not a list");
        }
      } else {
        print("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Order ID: ${order['idOrder']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${order['idUser']}'),
                  Text('Canteen ID: ${order['idCanteen']}'),
                  Text('Amount: ${order['amount']}'),
                  Text('VAT: ${order['vatValue']}'),
                  Text('Final Amount: ${order['finalAmount']}'),
                  Text('Special Note: ${order['specialNote']}'),
                  Text('Created At: ${order['creationDate']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
