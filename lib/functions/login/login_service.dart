import 'package:ezoneapp/screens/methods.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ezoneapp/functions/database/datatable.dart';
import '../database/database_helper.dart';
import 'package:ezoneapp/screens/home.dart';
import 'config.dart';

class LoginService {
  final String loginAPI = ('${Config.baseurlink}/oauth/token');

  Future<void> login(
      String username, String password, BuildContext context) async {
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(loginAPI),
          body: {
            'client_id': Config.clientId,
            'client_secret': Config.clientSecret,
            'username': username,
            'password': password,
            'grant_type': 'password',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Config.token = data['access_token'];

          if (Config.token != null) {
            final db = await DatabaseHelper.instance.database;
            final classdataTables = DataTables();

            await classdataTables.deleteDataTables(db);
            await classdataTables.createDataTables(db);

            await classdataTables.insertUserAuthentication(username, password);

            await classdataTables.fetchContactDataTable('${Config.token}');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }
        } 
        else if (Config.token == null) {
          _showError(context,'Server authentication failed, check username password.');
        }
      } 
      catch (e) {
        _showError(context, 'Network error. Checking local credentials.');
        await _attemptLocalLogin(username, password, context);
      }
    } 
    else {
      _showError(context, 'Please enter both username and password!');
    }
  }


  Future<void> _attemptLocalLogin(String username, String password, BuildContext context) async {
    bool isValidUser = await _checkLocalCredentials(username, password);
    if (isValidUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(),
        ),
      );
    } else {
      _showError(
          context, 'Offline login failed. Please check your credentials.');
    }
  }


  Future<bool> _checkLocalCredentials(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query('userauthenticationtable',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }


  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
