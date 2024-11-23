import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezoneapp/functions/contactDropdown.dart';

// void main() {
//   runApp(MyApp());
// } import 'package:ezoneapp/components/database_helper.dart';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BusinessLocationPage(),
//     );
//   }
// }

class BusinessLocationPage extends StatefulWidget {
  const BusinessLocationPage({super.key});

  @override
  _BusinessLocationPageState createState() => _BusinessLocationPageState();
}

class _BusinessLocationPageState extends State<BusinessLocationPage> {
  List<dynamic> businessLocations = [];
  List<dynamic> paymentMethods = [];
  String? selectedBusiness;
  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    fetchBusinessLocations();
  }

  Future<void> fetchBusinessLocations() async {
    const String url = "https://posdemo.ezoneit.com/connector/api/business-location";
    const String token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxNCIsImp0aSI6ImE3Y2MwMzVlMzU4MWYwNGY2N2RmMGIxMTQ1MGJiZWJhMjRlOWYzZTZiMzM3MmE3OGMzNmM0MTYyZDAzMWQ0YzYwMGIxNjU4MDlhYjZlNGQ4IiwiaWF0IjoxNzI3ODY5NDM1LjAxOTc4NCwibmJmIjoxNzI3ODY5NDM1LjAxOTc4OCwiZXhwIjoxNzU5NDA1NDM0LjkyOTU5Mywic3ViIjoiMiIsInNjb3BlcyI6W119.x3CAISzL9p2BDqfUyyYyc9KGZJG-g_Anoh94Ta_vY30sLzjzjycc7yz4s-6bmEK7e_5YmJewEuDin-f-EFs8GbmVLdUK1oEEeOuUnxV3p5MhcP0JEQGi37etpqQZ8R6DkL0ZL-JwQ6s9zxGlAAByCCxnD4B1d_GSFSPMYivY6zfzHuiQS4-RfclwVmIBurwpbAjmY8v8PVbsbcPVtEq7RzSHk8UsxTQhwu_uw8PjwxXNSHisE40VbBriTaUvd3BRpX52ZYu0JZJLRTyvBuut-49JHGpX-wqAaRqVFr7GQv8YbDGulZqb5puo5Xl8-Gmkcwr2sUoRbDzAxGrSxmqXGvXhXwHGPd99LZulJSQO2kQE6ftK-7KnaZwiiH3ai_TVoaUX7DLvH1f6Yo_rXGqeUrzCpCeeh6xQj6nDOBOHFf28jBkpyxzkdbCCG6MIjp6q9qMgSVA1jJRtKYThRGBqYRVQOBz_DfotQo1F6e_wbtz9ja_vjKGoN81DWOC5tpwPm-Ur75xd-ZKGFK3rlaaU7VlsxNLPr6nx6GazaiEsv7RNRN16BWXI7_2-l-vNozKAD9jKyuogHInJNTSzIvX-Ss4gBJWwj009lAlXuvmFhvt1AYwWjc9l9PQYwqNYPnmXYxIKa3kSGod3XU36W8mA9FPNlEALO-M3BFGoOxdTrng";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        businessLocations = jsonResponse['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void onBusinessSelected(String? businessId) {
    setState(() {
      selectedBusiness = businessId;
      paymentMethods = businessLocations
          .firstWhere((location) => location['id'].toString() == businessId)['payment_methods']
          .where((method) => method['label'] != "Custom Payment 1")
          .toList();
      selectedPaymentMethod = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Select Business"),
              value: selectedBusiness,
              isExpanded: true,
              onChanged: (String? newValue) {
                onBusinessSelected(newValue);
              },
              items: businessLocations.map<DropdownMenuItem<String>>((location) {
                return DropdownMenuItem<String>(
                  value: location['id'].toString(),
                  child: Text(location['name']),
                );
              }).toList(),
            ),


            const SizedBox(height: 20),

            
            DropdownButton<String>(
              hint: const Text("Select Payment Method"),
              value: selectedPaymentMethod,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = newValue;
                });
              },
              items: paymentMethods.map<DropdownMenuItem<String>>((method) {
                return DropdownMenuItem<String>(
                  value: method['name'],
                  child: Text(method['label']),
                );
              }).toList(),
            ),


             const SizedBox(height: 20),

             SizedBox(
                    child: ContactDropdown()
                  ),
           ],
          
          


          
        ),
      ),
    );
  }
}
