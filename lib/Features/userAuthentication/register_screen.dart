import 'package:chitter_chatter/Features/userAuthentication/login_screen.dart';
import 'package:chitter_chatter/Features/userAuthentication/user_information_screen.dart';
import 'package:chitter_chatter/common_utils/widgets/colors.dart';
import 'package:chitter_chatter/common_utils/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _reEnterPassword;
  String? _phoneNumber;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _reEnterPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _reEnterPassword.dispose();
    super.dispose();
  }

  Future<bool> _isPhoneNumberAlreadyInUse(String phoneNumber) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: appBarColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;

          return Container(
            alignment: isWideScreen ? Alignment.center : Alignment.topCenter,
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? 400 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_email, "Enter your email", Icons.email),
                      const SizedBox(height: 20),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white24,
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        initialCountryCode: 'BD',
                        onChanged: (phone) {
                          _phoneNumber = phone.completeNumber;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _password,
                        "Enter your password",
                        Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _reEnterPassword,
                        "Re-enter your password",
                        Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          final email = _email.text.trim();
                          final password = _password.text.trim();
                          final reEnterPassword = _reEnterPassword.text.trim();

                          if (password != reEnterPassword) {
                            _showSnackBar(context, "Password did not match");
                            return;
                          }

                          if (_phoneNumber == null) {
                            _showSnackBar(
                                context, "Please enter a valid phone number");
                            return;
                          }

                          final phoneNumberExists =
                          await _isPhoneNumberAlreadyInUse(_phoneNumber!);
                          if (phoneNumberExists) {
                            _showSnackBar(
                                context, "Phone number is already in use!");
                            return;
                          }

                          try {
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                email: email, password: password);

                            final userId = userCredential.user?.uid;
                            if (userId != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .set({
                                'email': email,
                                'phoneNumber': _phoneNumber,
                              });
                            }

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const UserInformationScreen()),
                            );
                          } on FirebaseAuthException catch (e) {
                            _handleFirebaseError(e, context);
                          }
                        },
                        text: 'Register',
                        child: const Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Go to Login Screen",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool isPassword = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleFirebaseError(FirebaseAuthException e, BuildContext context) {
    String errorMessage = "An unexpected error occurred.";
    if (e.code == 'email-already-in-use') {
      errorMessage = "Email already in use. Try another.";
    } else if (e.code == 'invalid-email') {
      errorMessage = "Please enter a valid email address.";
    } else {
      errorMessage =
      "Password must contain an uppercase letter, lowercase letter, numeric and special character.";
    }
    _showSnackBar(context, errorMessage);
  }

  void _showSnackBar(BuildContext context, String message) {
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
        backgroundColor: errorMessageColor,
      ),
    );
  }
}