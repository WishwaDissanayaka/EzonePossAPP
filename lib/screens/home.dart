import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';

import 'package:ezoneapp/screens/methods.dart';
import 'package:ezoneapp/components/custom_app_bar.dart';
import 'package:ezoneapp/screens/product.dart';
import 'package:ezoneapp/screens/quotation.dart';
import 'package:ezoneapp/screens/calculator.dart';

import 'package:ezoneapp/functions/contactDropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();
  
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

//=============== VARIABLE DECLARATION =======================================//

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCustomerType = 'Walk-in Customer';
  String? selectedAgent;
  String? selectedSellingType = 'Default Selling';
  DateTime? selectedDate = DateTime.now(); // Set default to today's date
  int _currentIndex = 0;

  String? _selectedPayment = 'cash';

  final List<String> customerTypes = ['Walk-in Customer', 'New Customer'];
  final List<String> agents = ['Agent 1', 'Agent 2', 'Agent 3'];
  final List<String> sellingTypes = ['Default Selling', 'Whole Sale'];
  final TextEditingController _searchController = TextEditingController();

  List<String> _items = []; // List to store product names and SKUs
  List<String> _suggestedItems = [];
  final List<Map<String, dynamic>> _selectedProducts = [];
  Timer? _timer; // Timer for polling

  //================= SET STATE AND TIMER =====================================//

  @override
  void initState() {
    super.initState();
    fetchProductNamesAndSKUs(); // Fetch items on page load

    // Start polling every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // ignore: avoid_print
      print('Refreshing product list...');
      fetchProductNamesAndSKUs();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchProductNamesAndSKUs() async {
    const String apiUrl = "https://posdemo.ezoneit.com/connector/api/product";
    const String token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxNCIsImp0aSI6ImYyNTYzN2YxYTgzY2ZkYmNmMmNiMDE2N2U3ZGMwZDVjOThlZTQyYWQyZTk1ZTNhYmE0Zjg2MmMyYzNmNWU1MTdiNzYxZTVhMDhkYjc5NmU3IiwiaWF0IjoxNzI3ODQwNDQ0LjI1MjU5MiwibmJmIjoxNzI3ODQwNDQ0LjI1MjU5NSwiZXhwIjoxNzU5Mzc2NDQ0LjA3NTc1Mywic3ViIjoiMiIsInNjb3BlcyI6W119.Df_21NnZ8UlyMfhB7vRP0u9R3Y7vFfDydafEqXSASMGw0P7Uzs9QOGaGSi3H0EyWcejAH0vdW80eO6wd0ZQ0hf9S_SV-amifqMqY4xzJBYdB9Up2Z5iNfBvY8w2CClvSIxF63R1na2UuoAzfDnNg6QX2KuH97GqHa6eeBxhJn0DRVIIADOYU8VLmaHf9TY5Bt8M5ByqGfxqaCAVilRhmT3ywKBl1whw1q9PC-dIi1cKkerNCg16S8xudJ0vRe2voQPu8z3caQN9350uGE9RkKmbbm98QPSGHzUqfTgNtwc5d-U66XgIKAH31UYzcAGvOtkJOvBnnH-1UEXxH7lihGvgHXlvaZqDls8HLjv6g6flx5lDyrYvgfK1Fo7lTTsshnxDzanNtmyQ2m5D-WXw3jGtaw7jYwDk6kc7vSTR8hTfi0sn-uz0L4QU5hr5jzoBQOz8Gj0vCdcEZNlAKqWXUJK7uOZesICFpj9HXakZNtUKmiypQ0T7ZnlX8a25iPJQZHOzlen6zjVHUzEPpvbhHtEl56PhDpKoBWwuCFzbuJ7nWs5H5uuX9CJ_WvRJhuKiaeiuwkp0JH6SH3qjsLrSD7On24uP44HuNtLlFJy--OWp-jrB0W03A7FvCQ9B7mSDrII26WCdW0mKIYntB6KElF6QRkkCWSNjMFTntbDkgETs"; // Replace with actual token

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _items = data['data'].map<String>((item) {
            return '${item['name']} (${item['sku'] ?? 'N/A'})'; // Format: Name (SKU)
          }).toList();
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //================= BARCODE SCANNER FUNCTION ======================================= //

  Future<void> scanBarcode() async {
    String barcodeValue = "Scan a barcode";

    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcodeValue = result.rawContent.isEmpty
            ? "Failed to get barcode"
            : result.rawContent;

        // Update the search bar with the scanned barcode value
        if (barcodeValue != "Failed to get barcode") {
          _searchController.text =
              barcodeValue; // Set the scanned value in the search bar
          _updateSuggestions(
              barcodeValue); // Trigger the search function with the scanned value
        }
      });
    } catch (e) {
      setState(() {
        barcodeValue = "Error occurred: $e"; 
      });
    }
  }

  //=============== SEARCH BOX SUGGESTIONS FUNCTION ==================================//

  void _updateSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _suggestedItems = [];
      } else {
        _suggestedItems = _items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  //================= ADD TO DATA TABLE FUNCTION ======================================//

  void _addSelectedItemToTable(String itemName) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(itemName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 1;

                setState(() {
                  _selectedProducts.add({
                    'name': itemName,
                    'quantity': quantity,
                    'subtotal': 10.00 * quantity,
                    'discount': 0,
                  });
                });

                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //===================== DATA TABLE FUNCTIONS FUNCTION ==============================//

  void _incrementQuantity(int index) {
    setState(() {
      _selectedProducts[index]['quantity']++;
      _updateSubtotal(index);
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_selectedProducts[index]['quantity'] > 1) {
        _selectedProducts[index]['quantity']--;
        _updateSubtotal(index);
      }
    });
  }

  //=================== UPDATE SUBTOTAL FUNCTION =====================================//

  void _updateSubtotal(int index) {
    final quantity = _selectedProducts[index]['quantity'];
    const pricePerUnit = 10.00; // Fixed price for simplicity
    _selectedProducts[index]['subtotal'] = quantity * pricePerUnit;
  }

  void _deleteProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _updateDiscount(int index, String value) {
    setState(() {
      final discount = double.tryParse(value) ?? 0.0;
      _selectedProducts[index]['discount'] = discount;
    });
  }

  //========= Handle navigation taps on the bottom navigation bar ==========//

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemsPage()),
      );
    } else if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled:
            true, // This makes the modal take up the full screen
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.95, // Adjust space at the top
            child: CalculatorPage(),
          );
        },
      );
    }
  }

  //=========== SELECT DATE FUNCTION =========================================//

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  double _getResponsiveFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.04; // 4% of screen width
  }










  //=========================================================================//
  //=========================================================================//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar01(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                controller: _searchController,
                onChanged: _updateSuggestions,
                decoration: InputDecoration(
                  labelText: 'SKU / Scan / Name',
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size (4% of screen width)
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _updateSuggestions(_searchController.text); // Trigger search when pressing the search button
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () => scanBarcode(), // Scan barcode and update search bar
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_suggestedItems.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestedItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestedItems[index]),
                      onTap: () {
                        _addSelectedItemToTable(_suggestedItems[index]);
                      },
                    );
                  },
                ),

              const SizedBox(height: 16),

              // ======================= Data Table ========================//

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(0, 3), // Position of shadow
                      ),
                    ],
                    border: Border.all(
                        color: Colors.blueAccent, width: 2), // Border styling
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Subtotal')),
                      DataColumn(label: Text('Discount')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _selectedProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;

                      return DataRow(cells: [
                        DataCell(Text(product['name'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _decrementQuantity(index),
                              ),
                              Text('${product['quantity']}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _incrementQuantity(index),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(
                            '\$${product['subtotal'].toStringAsFixed(2)}')),
                        DataCell(
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _updateDiscount(index, value),
                            decoration: const InputDecoration(
                              hintText: 'Discount',
                            ),
                            controller: TextEditingController(
                              text: product['discount'].toString(),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(index),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              //=================== Options (Drop Down) =====================//

              Row(
                children: [
                 
                  SizedBox(
                    child: ContactDropdown()
                  ),
                  
                  const SizedBox(width: 25),
                  
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: DropdownButton<String>(
                      value: selectedSellingType, // Default value
                      hint: const Text('Selling Type'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSellingType = newValue;
                        });
                      },
                      items: sellingTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                 
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: DropdownButton<String>(
                      value: selectedAgent,
                      hint: const Text('Commission Agent',style: TextStyle(fontSize: 13)),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedAgent = newValue;
                        });
                      },
                      items: agents.map((String agent) {
                        return DropdownMenuItem<String>(
                          value: agent,
                          child: Text(agent,style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                    ),
                  ),
                 
                  const SizedBox(width: 20),
                  
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: DropdownButton<String>(
                      hint: const Text('Payment',style: TextStyle(fontSize: 13)),
                      isExpanded: true,
                      value: _selectedPayment, // Set default value here
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'cash',
                          child: Text('Cash',style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem<String>(
                          value: 'card',
                          child: Text('Card',style:  TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem<String>(
                          value: 'check',
                          child: Text('Check',style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPayment = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes buttons with spacing
                children: [

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.266,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuotationPage(
                              selectedProducts: _selectedProducts, // Pass selected items to Quotation
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Quotation',
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.266,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(
                          fontSize: 9.0,
                        ), // Show today's date by default
                      ),
                    ),
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.266, // 26.6% width
                    child: ElevatedButton(
                      onPressed: () {
                        //create sell function should be here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Button corner radius
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size (4% of screen width)
                        ),
                      ),
                    ),
                  ),

                ],
              )


            ],
          ),
        ),
      ),



      //================= BOTTOM  NAVIGATION BAR ============================//

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
        


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for floating button
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BusinessLocationPage()),
          );
        },
        backgroundColor: Color.fromARGB(255, 203, 128, 171), // Button color
        child: Icon(Icons.table_chart_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at the bottom center



    );
  }
}
