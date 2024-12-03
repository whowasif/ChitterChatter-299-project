import 'dart:convert'; // For base64 decoding
import 'package:chitter_chatter/Features/chatScreen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  Stream<QuerySnapshot> _getChatList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('chatList')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteContact(String documentId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('chatList')
          .doc(documentId)
          .delete();
    } catch (e) {
      print("Error deleting contact: $e");
    }
  }

  Future<void> _initializeUnreadMessages(String documentId, Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('hasUnreadMessages')) {
        final currentUser = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('chatList')
            .doc(documentId)
            .set({
          'hasUnreadMessages': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error initializing unread messages: $e");
    }
  }

  void _confirmDelete(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Contact"),
          content: const Text("Are you sure you want to delete this contact?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteContact(documentId);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getChatList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No chats available"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Initialize hasUnreadMessages if not found
            if (!data.containsKey('hasUnreadMessages')) {
              _initializeUnreadMessages(doc.id, data);
            }

            final hasUnreadMessages = data['hasUnreadMessages'] ?? false;

            final profilePicData = data['profilePic'] as String?;
            final profileImage = profilePicData != null && profilePicData.isNotEmpty
                ? MemoryImage(base64Decode(profilePicData)) as ImageProvider
                : const NetworkImage('https://www.example.com/default-profile-pic.png') as ImageProvider;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: hasUnreadMessages ? Colors.blue.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    // Clear unread messages flag when opening chat
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('chatList')
                        .doc(doc.id)
                        .update({'hasUnreadMessages': false});

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(userId: data['userId']),
                      ),
                    );
                  },
                  title: Text(
                    data['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: profileImage,
                      ),
                      if (hasUnreadMessages)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          _confirmDelete(context, doc.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}