import 'dart:convert';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusTab extends StatefulWidget {
  const StatusTab({super.key});

  @override
  _StatusTabState createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  bool _loading = true;
  bool _isCreatingStatus = false;
  final TextEditingController _statusController = TextEditingController();
  List<Map<String, dynamic>> recentStatus = [];

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
  }

  Future<void> _fetchStatuses() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final currentTime = DateTime.now();
      List<Map<String, dynamic>> statuses = [];

      // Fetch current user's stories
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final currentUserName = currentUserDoc.data()?['name'] ?? 'Unknown User';
      final currentUserProfilePic =
          currentUserDoc.data()?['profilePicture'] ?? '';

      final userStories = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('stories')
          .orderBy('date', descending: true)
          .get();

      statuses.addAll(_extractRecentStatuses(
        userStories.docs,
        currentUserName,
        currentTime,
        currentUserProfilePic,
      ));

      // Fetch all users and their stories (replace this later with a friend-based filter)
      final allUsers =
          await FirebaseFirestore.instance.collection('users').get();
      for (var userDoc in allUsers.docs) {
        if (userDoc.id == userId) continue; // Skip the current user

        final chatUserName = userDoc.data()?['name'] ?? 'Unknown User';
        final chatUserProfilePic = userDoc.data()?['profilePicture'] ?? '';

        final chatUserStories = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('stories')
            .orderBy('date', descending: true)
            .get();

        statuses.addAll(_extractRecentStatuses(
          chatUserStories.docs,
          chatUserName,
          currentTime,
          chatUserProfilePic,
        ));
      }

      setState(() {
        recentStatus = statuses;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching statuses: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status cannot be empty')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('stories')
          .add({
        'status': _statusController.text.trim(),
        'date': Timestamp.now(),
      });

      setState(() {
        _isCreatingStatus = false;
        _statusController.clear();
      });

      await _fetchStatuses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create status: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _extractRecentStatuses(
      List<QueryDocumentSnapshot> docs,
      String userName,
      DateTime currentTime,
      String profilePicture) {
    return docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['date'] as Timestamp?;
          final statusDate = timestamp?.toDate();

          if (statusDate != null &&
              currentTime.difference(statusDate).inHours < 24) {
            return {
              'name': userName,
              'status': data['status'] ?? 'No Status',
              'date': statusDate,
              'profilePicture': profilePicture,
            };
          }
          return null;
        })
        .where((status) => status != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  Widget _buildProfileAvatar(String? profilePicture) {
    if (profilePicture != null && profilePicture.isNotEmpty) {
      try {
        final decodedImage = base64Decode(profilePicture);
        return CircleAvatar(
          backgroundImage: MemoryImage(decodedImage),
          backgroundColor: Colors.grey[300],
        );
      } catch (e) {
        print("Error decoding profile picture: $e");
        return _defaultProfileAvatar();
      }
    }
    return _defaultProfileAvatar();
  }

  Widget _defaultProfileAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Status Creation Section
              if (_isCreatingStatus)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _statusController,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        maxLength: 250,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  tabColor, // Set the button color to green
                            ),
                            onPressed: _createStatus,
                            child: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Status List Section
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : recentStatus.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentStatus.length,
                          itemBuilder: (context, index) {
                            final status = recentStatus[index];
                            return ListTile(
                              leading:
                                  _buildProfileAvatar(status['profilePicture']),
                              title: Text(
                                status['name'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status['status'] ?? 'No Status',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    status['date'] != null
                                        ? "Posted on: ${_formatDate(status['date'])}"
                                        : "Date not available",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No status available",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCreatingStatus = !_isCreatingStatus;
          });
        },
        backgroundColor: tabColor,
        child: Icon(_isCreatingStatus ? Icons.close : Icons.add),
      ),
    );
  }
}
