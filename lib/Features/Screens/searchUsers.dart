import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chitter_chatter/Features/chatScreen/chat_screen.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _contacts = [];
  List<QueryDocumentSnapshot> _filteredContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load all contacts initially
  Future<void> _loadContacts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('chatList')
          .get();

      setState(() {
        _contacts = snapshot.docs;
        _filteredContacts = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading contacts. Please try again.')),
        );
      }
    }
  }

  // Filter contacts based on search query
  void _searchContacts(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredContacts = _contacts;
      });
      return;
    }

    setState(() {
      _filteredContacts = _contacts.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: _searchContacts,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredContacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
        itemCount: _filteredContacts.length,
        itemBuilder: (context, index) {
          final contactData = _filteredContacts[index].data() as Map<String, dynamic>;
          final profilePic = contactData['profilePic'] as String?;

          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: profilePic != null && profilePic.isNotEmpty
                  ? MemoryImage(base64Decode(profilePic))
                  : const AssetImage('assets/images/default_profile_pic.png') as ImageProvider,
            ),
            title: Text(contactData['name'] ?? 'Unknown Contact'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(userId: contactData['userId']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}