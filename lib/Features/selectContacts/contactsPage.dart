import 'package:chitter_chatter/Features/chatScreen/chat_screen.dart';
import 'package:chitter_chatter/Features/selectContacts/search_contacts.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  /// Function to normalize phone numbers
  String _normalizePhoneNumber(String phoneNumber) {
    String normalized = '';
    for (int i = 0; i < phoneNumber.length; i++) {
      final char = phoneNumber[i];
      if (char.codeUnitAt(0) >= '0'.codeUnitAt(0) && char.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        normalized += char;
      } else if (char == '+' && normalized.isEmpty) {
        normalized += char;
      }
    }
    return normalized;
  }

  /// Fetch contacts and normalize phone numbers in-place
  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Fetch contacts with properties
      List<Contact> contactList = await FlutterContacts.getContacts(withProperties: true);

      // Normalize phone numbers in-place
      for (var contact in contactList) {
        for (var i = 0; i < contact.phones.length; i++) {
          contact.phones[i] = Phone(
            _normalizePhoneNumber(contact.phones[i].number), // Normalize the number
            label: contact.phones[i].label, // Keep the label
          );
        }
      }

      // Update the state with normalized contacts
      setState(() {
        contacts = contactList;
      });
    }
  }

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

  Future<void> _addToChatList(String contactUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final contactDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(contactUserId)
        .get();

    if (contactDoc.exists) {
      final contactData = contactDoc.data();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('chatList')
          .doc(contactUserId)
          .set({
        'name': contactData?['name'] ?? '',
        'profilePic': contactData?['profilePicture'] ?? '',
        'userId': contactUserId,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: tabColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        backgroundColor: appBarColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchContacts(contacts: contacts),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';

          return InkWell(
            onTap: () async {
              final contactUserId = await _checkContactRegistration(phoneNumber);

              if (contactUserId != null) {
                await _addToChatList(contactUserId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(userId: contactUserId),
                  ),
                );
              } else {
                _showMessage("Contact is not registered on the app");
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: contact.photo != null
                      ? MemoryImage(contact.photo!)
                      : const NetworkImage('https://www.example.com/default-profile-pic.png'),
                ),
                title: Text(
                  contact.displayName,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  phoneNumber.isNotEmpty ? phoneNumber : 'No number',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
