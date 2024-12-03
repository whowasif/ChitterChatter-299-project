import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chitter_chatter/Features/chatScreen/chat_screen.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';

class SearchContacts extends StatefulWidget {
  final List<Contact> contacts; // List of all contacts

  const SearchContacts({Key? key, required this.contacts}) : super(key: key);

  @override
  State<SearchContacts> createState() => _SearchContactsState();
}

class _SearchContactsState extends State<SearchContacts> {
  List<Contact> filteredContacts = []; // Filtered contacts
  String query = ""; // Search query

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts; // Show all contacts initially
  }

  void _updateSearchQuery(String searchText) {
    setState(() {
      query = searchText.toLowerCase();
      filteredContacts = widget.contacts
          .where((contact) =>
          contact.displayName.toLowerCase().contains(query))
          .toList();
    });
  }

  /// Normalize phone number
  String _normalizePhoneNumber(String phoneNumber) {
    String normalized = '';
    for (int i = 0; i < phoneNumber.length; i++) {
      final char = phoneNumber[i];
      if (char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          char.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        normalized += char;
      } else if (char == '+' && normalized.isEmpty) {
        normalized += char;
      }
    }
    return normalized;
  }

  /// Check contact registration in Firebase
  Future<String?> _checkContactRegistration(String phoneNumber) async {
    try {
      final normalizedNumber = _normalizePhoneNumber(phoneNumber);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: normalizedNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print("Error checking contact registration: $e");
      return null;
    }
  }

  /// Show message in SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: tabColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: _updateSearchQuery,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search contacts...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
      body: filteredContacts.isEmpty
          ? const Center(child: Text("No matching contacts"))
          : ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          final phoneNumber = contact.phones.isNotEmpty
              ? contact.phones.first.number
              : 'No number';

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.displayName),
            subtitle: Text(phoneNumber),
            onTap: () async {
              if (phoneNumber == 'No number') {
                _showMessage("Contact has no valid phone number");
                return;
              }

              final contactUserId =
              await _checkContactRegistration(phoneNumber);

              if (contactUserId != null) {
                Navigator.pop(context); // Close search
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(userId: contactUserId),
                  ),
                );
              } else {
                _showMessage("Contact is not registered on the app");
              }
            },
          );
        },
      ),
    );
  }
}
