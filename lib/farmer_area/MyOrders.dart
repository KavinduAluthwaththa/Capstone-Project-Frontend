import 'package:capsfront/constraints/api_endpoint.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyOrdersPage(),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> _orders = [];
  final String apiUrl =  ApiEndpoints.getRequests;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _orders = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }

  Future<void> deleteOrder(int requestId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$requestId'));
      if (response.statusCode == 200) {
        setState(() {
          _orders.removeWhere((order) => order['requestID'] == requestId);
        });
      } else {
        throw Exception('Failed to delete order');
      }
    } catch (error) {
      print("Error deleting order: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF98D178),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 20),
                Text(
                  "My Orders",
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // List of My Orders
          Expanded(
            child: _orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      return OrderRequestTile(
                        requestId: _orders[index]['requestID'],
                        cropName: _orders[index]['cropName'],
                        date: _orders[index]['date'],
                        amount: _orders[index]['amount'].toString(),
                        onDelete: deleteOrder,
                      );
                    },
                  ),
          ),

          // Bottom Navigation Bar
          // BottomNavigationBar(
          //   backgroundColor: const Color(0xFF4E7033),
          //   selectedItemColor: Colors.white,
          //   unselectedItemColor: Colors.white,
          //   showUnselectedLabels: true,
          //   items: const [
          //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          //     BottomNavigationBarItem(icon: Icon(Icons.android), label: "AI chat bot"),
          //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "My account"),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class OrderRequestTile extends StatelessWidget {
  final int requestId;
  final String cropName;
  final String date;
  final String amount;
  final Function(int) onDelete;

  const OrderRequestTile({
    super.key,
    required this.requestId,
    required this.cropName,
    required this.date,
    required this.amount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD8EBC2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cropName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 5),
                  Text(date, style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
              Text("Amount: $amount", style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(requestId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
