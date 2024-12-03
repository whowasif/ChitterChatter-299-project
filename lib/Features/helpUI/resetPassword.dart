import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:flutter/material.dart';

class HelpResetPassword extends StatelessWidget {
  const HelpResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Your Password'),
        backgroundColor: appBarColor,
      ),
      body: const Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text(
              'Please follow the steps',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
                  '1. Logout from the app by clicking on the logout button on the rightmost corner of the screen.\n'
                  '2. You will be redirected to the login screen where you will find a Forgot Password? button.\n'
                  '3. After clicking on the button you will be redirected to a screen.\n'
                  '4. Provide your email.\n'
                  '5. A password reset email will be sent to the provided email.\n'
                  '6. Open the email and click on the link.\n'
                  '7. A new password field will show up and you can provide the new password and click on save to reset your password.\n',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16),
            Text(
              'Thank you for using our app!',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}