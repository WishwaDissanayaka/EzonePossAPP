import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<dynamic> items = [];
  bool isLoading = true;
  int currentPage = 1;
  final int perPage = 10; // Number of items per page
  bool hasMoreItems = true; // Flag to check if more items are available
  Timer? _timer; // Timer for polling
  TextEditingController searchController = TextEditingController();
  String query = ''; // Search query

  @override
  void initState() {
    super.initState();
    fetchItems();

    // Start polling every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 100), (timer) {
      print('Refreshing items...');
      resetPagination();
      fetchItems();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }

  void resetPagination() {
    setState(() {
      items = [];
      currentPage = 1;
      hasMoreItems = true;
      isLoading = true;
    });
  }

  Future<void> fetchItems({String searchQuery = ''}) async {
    const String apiUrl = "https://posdemo.ezoneit.com/connector/api/product";
    const String token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxNCIsImp0aSI6IjQ1YTg1YzgzMjM2NDEwNTBkODQwODczN2QxOGFjMjk1YzczYmU0ZGVjYzRiMjQ1NDEyNjljMjk5MzRkNGMyZTBiNTk4NjhmNDI1MmMwOTQzIiwiaWF0IjoxNzMwNDM3NTgzLjMyOTgyNiwibmJmIjoxNzMwNDM3NTgzLjMyOTgzMiwiZXhwIjoxNzYxOTczNTgzLjI5MDcyLCJzdWIiOiIyIiwic2NvcGVzIjpbXX0.k3QRR7fs2h-ulXHLQbmzYw7QKXuwc-kUMIKXX5_HQKcd3xh3_ctM2a0SZRevpQQoeInTZUQjiw-tanweRkaFXXmh5x4PWt0JkY40YAGEDjFqfMDASKtAfoCghKyQ5wIYEAZ6yD5cQSRYgxcMrIhHbmU1l5nKMkcg8XLoaUDoiawk-7PcSi9PnrQROXNk1UpoDm7En9S-Ia-CrpMmEkfb3wrlsySG8ZjSiM00oABcvFm-_wvEjibb__paA7G8OqfVKmbS3AnyI34I2qLL0ZzNUwhahG6_WHZ7ooPldpD3S_GZf1I7x_CYqnoxzlFYtBUcYLP5OzQvnx-LZYa8T8kFzjWRWOMvaoRiLivOlRqxBHzuDi5NRq-I171kTV1uj41Gy9E0JYx6aNMpXajAfkUXhXPFIZ0e2xhGvGyIbjF5zWD_oKM4rIXgKsfZhTdqzivPgs_M935EiWWAulfoWae8zsrUa6Ri4RX9cemVBa5R97Mc4ZTmxV21gjKVEoOlPZ9INGZxM3UAw_z5WY0286yUGM7lUhHLUhvJ5nF5BLn3kTG8sEHxPNImi9_CvQ-JHjR2gb4tmS2nYWJUnrFr9Nee16UgLmqk9u3Tk-IC7uPFMbCe4aPnYo4fH_jJuQ1eC7M2TjZZk3pm6opTelzulqHX9kyXilCQ_Roshztfveke_Lc";

    while (hasMoreItems) {
      try {
        final response = await http.get(
          Uri.parse(
              '$apiUrl?per_page=$perPage&page=$currentPage&name=$searchQuery'),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newItems = data['data'] as List<dynamic>;

          setState(() {
            items.addAll(newItems);
            isLoading = false;
            currentPage++;
            hasMoreItems = newItems
                .isNotEmpty; // Continue fetching if there are more items
          });

          print("Fetched page $currentPage: ${newItems.length} items");
        } else {
          throw Exception('Failed to load items');
        }
      } catch (e) {
        print('Error: $e');
        break;
      }
    }
  }

  void onSearch(String query) {
    setState(() {
      this.query = query;
      resetPagination();
    });
    fetchItems(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items List (Updated every 10 seconds)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search items by name or SKU...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => onSearch(searchController.text),
                ),
              ),
              onSubmitted: onSearch,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 3 / 2,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'SKU: ${item['sku'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Manual fetch triggered');
          resetPagination();
          fetchItems(searchQuery: query); // Fetch using the current query
        },
        tooltip: 'Refresh Items Manually',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
