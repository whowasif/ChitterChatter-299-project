import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSearch extends StatefulWidget {
  final String currentUserId;

  const MessageSearch({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<MessageSearch> createState() => _MessageSearchState();
}

class _MessageSearchState extends State<MessageSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];

  void _searchMessages(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: widget.currentUserId)
          .get();

      final filteredResults = snapshot.docs.where((doc) {
        final message = doc['message']?.toString().toLowerCase() ?? '';
        return message.contains(query.toLowerCase());
      }).toList();

      setState(() {
        _searchResults = filteredResults;
      });
    } catch (e) {
      print("Error searching messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search messages',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _searchMessages,
        ),
        backgroundColor: appBarColor,
      ),
      body: _searchResults.isEmpty
          ? const Center(
        child: Text(
          'No messages found',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final message = _searchResults[index];

          return ListTile(
            title: Text(
              message['message'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Sent at: ${DateTime.fromMillisecondsSinceEpoch((message['timestamp'] as Timestamp).millisecondsSinceEpoch)}",
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Navigate to the message in chat screen or highlight it
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}