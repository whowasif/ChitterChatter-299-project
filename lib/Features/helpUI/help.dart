import 'package:chitter_chatter/Features/helpUI/resetPassword.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Getting Started",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              HelpButton(
                title: "How to find phone contacts",
                icon: Icons.contact_page_outlined,
                onPressed: () {
                  // Add action for "How to create a group"
                },
              ),
              HelpButton(
                title: "How to add a new user",
                icon: Icons.group_add,
                onPressed: () {
                  // Add action for "How to create a group"
                },
              ),
              HelpButton(
                title: "How to delete someone from the chat list",
                icon: Icons.delete,
                onPressed: () {
                  // Add action for "How to delete someone from the chat list"
                },
              ),
              HelpButton(
                title: "How to reset password",
                icon: Icons.lock_open,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpResetPassword(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Managing Your Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              HelpButton(
                title: "How to change profile info",
                icon: Icons.person,
                onPressed: () {
                  // Add action for "How to find someone’s profile"
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Chat Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              HelpButton(
                title: "How to search someone in the chat list",
                icon: Icons.person_search,
                onPressed: () {
                  // Add action for "How to search someone in the chat list"
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Sending emoji & images",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              HelpButton(
                title: "How to send emoji and images",
                icon: Icons.send,
                onPressed: () {
                  // Add action for "How to search someone in the chat list"
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const HelpButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: tabColor, // Lavender color
          foregroundColor: Colors.black, // Text and icon color for contrast
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
