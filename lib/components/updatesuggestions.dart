//import 'package:flutter/material.dart';

List<String> _suggestedItems = [];

void _updateSuggestions(String query, List<String> items, Function(List<String>) setSuggestions) {
  if (query.isEmpty) {
    setSuggestions([]);
  } else {
    final suggestions = items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setSuggestions(suggestions);
  }
}
