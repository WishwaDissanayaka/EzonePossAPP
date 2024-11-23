import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart'; // for permissions
import 'dart:io'; // for file operations

class QuotationPage extends StatelessWidget {
  final List<Map<String, dynamic>> selectedProducts;

  const QuotationPage({super.key, required this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    double totalPrice = selectedProducts.fold(
      0,
      (sum, item) => sum + item['subtotal'] - item['discount'],
    );

    Future<void> saveAsPdf() async {
      final pdf = pw.Document();

      // Create PDF content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Quotation Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Product', 'Quantity', 'Subtotal', 'Discount'],
                    ...selectedProducts.map((product) => [
                          product['name'],
                          '${product['quantity']}',
                          '\$${product['subtotal'].toStringAsFixed(2)}',
                          '\$${product['discount'].toStringAsFixed(2)}',
                        ]),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Items: ${selectedProducts.length}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          // Get the Downloads directory
          final downloadPath = Directory('/storage/emulated/0/Download');
          if (!await downloadPath.exists()) {
            downloadPath.create(recursive: true);
          }

          // Define the file path
          final file = File('${downloadPath.path}/quotation.pdf');

          // Save the PDF file
          await file.writeAsBytes(await pdf.save());

          // Notify the user that the file has been saved
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF saved in Downloads folder.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error while saving PDF: $e')),
          );
        }
      } else {
        // Handle the case where permission is not granted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QUOTATION',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 25, 196, 33),
                Color.fromARGB(255, 58, 80, 226),
                Color.fromARGB(255, 7, 182, 236),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quotation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Subtotal')),
                    DataColumn(label: Text('Discount')),
                  ],
                  rows: selectedProducts.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product['name'])),
                      DataCell(Text('${product['quantity']}')),
                      DataCell(Text(
                          '\$${product['subtotal'].toStringAsFixed(2)}')),
                      DataCell(Text(
                          '\$${product['discount'].toStringAsFixed(2)}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items: ${selectedProducts.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Place buttons at the bottom of the page for saving and sharing
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: saveAsPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Save as PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
