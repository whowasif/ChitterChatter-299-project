import 'dart:convert';  // For base64 decoding
import 'package:chitter_chatter/Features/Screens/searchUsers.dart';
import 'package:chitter_chatter/Features/chatScreen/contact_list.dart';
import 'package:chitter_chatter/Features/helpUI/help.dart';
import 'package:chitter_chatter/Features/selectContacts/contactsPage.dart'; // Import the ProfileScreen
import 'package:chitter_chatter/Features/status/status.dart';
import 'package:chitter_chatter/Features/userAuthentication/login_screen.dart';
import 'package:chitter_chatter/Features/userProfile/profile_screen.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _Homepage createState() => _Homepage();
}

class _Homepage extends State<Homepage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? profileName;
  String? profilePictureBase64;
  bool _loading = true; // Flag to show a loading indicator
  String? userStatus;
  List<Map<String, dynamic>> recentStatus = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Updated length to 2
    _userData(); // Fetch user data on initialization
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {});
  }

  // Fetch user data (profile picture and name) from Firestore
  Future<void> _userData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final storiesCollection = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('stories')
            .orderBy('date', descending: true)
            .get();

        // Find the most recent statuses within the last 24 hours
        List<Map<String, dynamic>> statuses = [];
        final currentTime = DateTime.now();
        for (var doc in storiesCollection.docs) {
          final data = doc.data();
          final timestamp = data['date'] as Timestamp;
          final statusDate = timestamp.toDate();

          if (currentTime.difference(statusDate).inHours < 24) {
            statuses.add({
              'status': data['status'],
              'date': statusDate,
            });
          }
        }

        if (doc.exists) {
          setState(() {
            profileName = doc['name'];
            profilePictureBase64 =
            doc['profilePicture']; // Get base64 string for the image
            recentStatus = statuses;
            _loading = false; // Stop loading once data is fetched
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chitter-Chatter",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.help,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchUsers()),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              } catch (e) {
                print("Error signing out: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Error signing out. Please try again.")),
                );
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: appBarColor,
            child: _loading
                ? const Center(
                child:
                CircularProgressIndicator()) // Show loading indicator while fetching data
                : GestureDetector(
              onTap: () {
                // Navigate to ProfileScreen when the profile section is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  // Profile Picture, decoded from base64
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profilePictureBase64 != null
                        ? MemoryImage(
                        base64Decode(profilePictureBase64!))
                        : const AssetImage(
                        'assets/images/default_profile_pic.png') as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  // Profile Name
                  Text(
                    profileName ?? "User Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar with Increased Height
          PreferredSize(
            preferredSize: const Size.fromHeight(
                60), // Adjust height for larger tab size
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "Chats",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "Status",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: ContactList()),
                Center(child: StatusTab()),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactsPage(),
            ),
          );
        },
        backgroundColor: tabColor,
        child: const Icon(Icons.comment),
      ),
    );
  }
}
