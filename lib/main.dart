import 'package:chitter_chatter/Features/Screens/homepage.dart';
import 'package:chitter_chatter/Features/Screens/welcome_screen.dart';
import 'package:chitter_chatter/Features/chatScreen/chat_screen.dart';
import 'package:chitter_chatter/Features/helpUI/help.dart';
import 'package:chitter_chatter/Features/helpUI/resetPassword.dart';
import 'package:chitter_chatter/Features/selectContacts/contactsPage.dart';
import 'package:chitter_chatter/Features/userAuthentication/email_varification_screen.dart';
import 'package:chitter_chatter/Features/userAuthentication/forgot_password_screen.dart';
import 'package:chitter_chatter/Features/userAuthentication/login_screen.dart';
import 'package:chitter_chatter/Features/userAuthentication/register_screen.dart';
import 'package:chitter_chatter/Features/userAuthentication/user_information_screen.dart';
import 'package:chitter_chatter/Features/userProfile/profile_screen.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chitter-Chatter',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: const Homepage(),
    );
  }
}
