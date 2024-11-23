import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';

class DataTables {
  final String baseurlink = 'https://posdemo.ezoneit.com';

  Future<void> createDataTables(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS userauthenticationtable (username TEXT, password TEXT)");
    await db.execute("CREATE TABLE IF NOT EXISTS contactdatatable (id INTEGER PRIMARY KEY, business_id INTEGER, type TEXT,contact_type TEXT, supplier_business_name TEXT, name TEXT, prefix TEXT, first_name TEXT, middle_name TEXT, last_name TEXT, email TEXT, contact_id TEXT, city TEXT, state TEXT, mobile TEXT, credit_limit TEXT, balance TEXT, shipping_address TEXT)");
    await db.execute("CREATE TABLE IF NOT EXISTS businessdatatable (id INT PRIMARY KEY, name TEXT, start_date TEXT, owner_id INT)");
    await db.execute("CREATE TABLE IF NOT EXISTS locationdatatable (id INT PRIMARY KEY, business_id TEXT, location_id TEXT, name TEXT, landmark TEXT, state TEXT, city TEXT, mobile TEXT)");
    await db.execute("CREATE TABLE IF NOT EXISTS paymentmethoddatatable (location_id TEXT, default_payment_accounts TEXT)");
  }


  Future<void> deleteDataTables(Database db) async {
    await db.execute("DROP TABLE IF EXISTS userauthenticationtable");
    await db.execute("DROP TABLE IF EXISTS contactdatatable");
    await db.execute("DROP TABLE IF EXISTS businessdatatable");
    await db.execute("DROP TABLE IF EXISTS locationdatatable");
    await db.execute("DROP TABLE IF EXISTS paymentmethoddatatable");
  }



  Future<void> insertUserAuthentication(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'userauthenticationtable', // Replace with the actual table name
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> fetchContactDataTable(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseurlink/connector/api/contactapi'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> contacts = data['data'];

        final db = await DatabaseHelper.instance.database;

        // Clear existing data in contactdatatable before inserting new data
        await db.delete('contactdatatable');

        // Insert new data
        for (var contact in contacts) {
          await db.insert('contactdatatable', {
            'id': contact['id'],
            'business_id': contact['business_id'],
            'type': contact['type'],
            'contact_type': contact['contact_type'],
            'supplier_business_name': contact['supplier_business_name'],
            'name': contact['name'],
            'prefix': contact['prefix'],
            'first_name': contact['first_name'],
            'middle_name': contact['middle_name'],
            'last_name': contact['last_name'],
            'email': contact['email'],
            'contact_id': contact['contact_id'],
            'city': contact['city'],
            'state': contact['state'],
            'mobile': contact['mobile'],
            'credit_limit': contact['credit_limit'] ?? "0.0000",
            'balance': contact['balance'] ?? "0.0000",
            'shipping_address': contact['shipping_address'],
          });
        }
        print("Data fetched and stored successfully in contactdatatable.");
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching data: $e");
    }
  }


}
