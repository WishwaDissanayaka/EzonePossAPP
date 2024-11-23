// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ezoneapp/components/custom_app_bar.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';

// import 'package:ezoneapp/components/custom_app_bar.dart';
// import 'package:ezoneapp/screens/product.dart';
// import 'package:ezoneapp/screens/quotation.dart';
// import 'package:ezoneapp/components/calculator.dart';
// import 'package:ezoneapp/screens/methods.dart';

// class HomeScreen extends StatefulWidget {
//   final String username;
//   final String token;

//   const HomeScreen({super.key, required this.username, required this.token});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<dynamic> businessLocations = [];
//   List<dynamic> paymentMethods = [];
//   String? selectedBusiness;
//   String? selectedPaymentMethod;

//   String? selectedCustomerType = 'Walk-in Customer';
//   String? selectedAgent;
//   String? selectedSellingType = 'Default Selling';
//   DateTime? selectedDate = DateTime.now(); // Set default to today's date
//   int _currentIndex = 0;

//   String? _selectedPayment = 'cash';

//   final List<String> customerTypes = ['Walk-in Customer', 'New Customer'];
//   final List<String> agents = ['Agent 1', 'Agent 2', 'Agent 3'];
//   final List<String> sellingTypes = ['Default Selling', 'Whole Sale'];
//   final TextEditingController _searchController = TextEditingController();

//   List<String> _items = []; // List to store product names and SKUs
//   List<String> _suggestedItems = [];
//   final List<Map<String, dynamic>> _selectedProducts = [];
//   Timer? _timer; // Timer for polling



//   @override
//   void initState() {
//     super.initState();
//     fetchBusinessLocations();
//   }

//   Future<void> fetchBusinessLocations() async {
//     const String url = "https://posdemo.ezoneit.com/connector/api/business-location";

//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer ${widget.token}', // Use the token passed from HomeScreen
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       setState(() {
//         businessLocations = jsonResponse['data'];
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   void onBusinessSelected(String? businessId) {
//     setState(() {
//       selectedBusiness = businessId;
//       paymentMethods = businessLocations
//           .firstWhere((location) => location['id'].toString() == businessId)['payment_methods']
//           .where((method) => method['label'] != "Custom Payment 1")
//           .toList();
//       selectedPaymentMethod = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar01(),
//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           // Centered welcome note
//           Center(
//             child: Text(
//               'Welcome Mr, ${widget.username}!',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Business Location Dropdown
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: DropdownButton<String>(
//               hint: const Text("Select Business"),
//               value: selectedBusiness,
//               isExpanded: true,
//               onChanged: (String? newValue) {
//                 onBusinessSelected(newValue);
//               },
//               items: businessLocations.map<DropdownMenuItem<String>>((location) {
//                 return DropdownMenuItem<String>(
//                   value: location['id'].toString(),
//                   child: Text(location['name']),
//                 );
//               }).toList(),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Payment Method Dropdown
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: DropdownButton<String>(
//               hint: const Text("Select Payment Method"),
//               value: selectedPaymentMethod,
//               isExpanded: true,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedPaymentMethod = newValue;
//                 });
//               },
//               items: paymentMethods.map<DropdownMenuItem<String>>((method) {
//                 return DropdownMenuItem<String>(
//                   value: method['name'],
//                   child: Text(method['label']),
//                 );
//               }).toList(),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Additional content with token usage
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Add your DataTable and other widgets here, utilizing `widget.token` as needed
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
