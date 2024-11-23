import 'package:flutter/material.dart';
import 'package:ezoneapp/functions/database/database_helper.dart';

class ContactDropdown extends StatefulWidget {
  @override
  _ContactDropdownState createState() => _ContactDropdownState();
}

class _ContactDropdownState extends State<ContactDropdown> {
  TextEditingController searchController = TextEditingController();
  String selectedContact = '';
  List<Map<String, dynamic>> contactList = [];
  List<Map<String, dynamic>> filteredContactList = [];
  OverlayEntry? dropdownOverlayEntry;
  final LayerLink layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  @override
  void dispose() {
    searchController.dispose();
    dropdownOverlayEntry?.remove();
    super.dispose();
  }

  // Fetch data from the contactdatatable
  Future<void> fetchContacts() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query('contactdatatable');

    setState(() {
      contactList = result.map((contact) {
        String displayName = contact['name'] ?? '${contact['first_name'] ?? ''} ${contact['last_name'] ?? ''}'.trim();
        return {
          'id': contact['id'],
          'displayName': displayName,
        };
      }).toList();
      filteredContactList = contactList;
    });
  }

  // Filter contacts based on search input
  void filterContacts(String query) {
    setState(() {
      filteredContactList = contactList.where((contact) {
        return contact['displayName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
    dropdownOverlayEntry?.markNeedsBuild();
  }

  // Show or hide the dropdown overlay
  void toggleDropdown() {
    if (dropdownOverlayEntry == null) {
      dropdownOverlayEntry = _createDropdownOverlay();
      Overlay.of(context).insert(dropdownOverlayEntry!);
    } else {
      dropdownOverlayEntry?.remove();
      dropdownOverlayEntry = null;
    }
  }

  // Create dropdown overlay entry
  OverlayEntry _createDropdownOverlay() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset(0, 60),
            showWhenUnlinked: false,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterContacts,
                      decoration: InputDecoration(
                        labelText: "Search customer",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredContactList.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContactList[index];
                        return ListTile(
                          title: Text(contact['displayName']),
                          onTap: () {
                            setState(() {
                              selectedContact = "${contact['displayName']}";
                            });
                            toggleDropdown();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onTap: toggleDropdown,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: selectedContact.isEmpty ? "Select a customer" : selectedContact,
              hintText: selectedContact.isEmpty ? "Select a customer" : null,
              suffixIcon: Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}
