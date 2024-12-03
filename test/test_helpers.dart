// test/helpers/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chitter_chatter/Features/userAuthentication/user_information_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

/// Test data constants for authentication testing
class TestData {
  // Private constructor to prevent instantiation
  TestData._();

  // Valid test data
  static const String validEmail = 'aunkonhabib@gmail.com';
  static const String validPassword = 'Test123!@#';
  static const String validPhoneNumber = '+8801712345678';
  static const String validName = 'Test User';

  // Invalid test data
  static const String invalidEmail = 'invalid.email';
  static const String weakPassword = 'weak';
  static const String existingEmail = 'existing@email.com';
  static const String existingPhone = '+8801712345679';
  static const String invalidPhoneNumber = '123';

  // Error messages
  static const String invalidEmailError = 'Please enter a valid email';
  static const String weakPasswordError = 'Password must be at least 8 characters';
  static const String passwordMismatchError = 'Passwords do not match';
  static const String invalidPhoneError = 'Please enter a valid phone number';
}

/// Helper class for testing registration functionality
class TestHelper {
  // Private constructor to prevent instantiation
  TestHelper._();

  /// Fills the registration form with provided data
  static Future<void> fillRegistrationForm(
      WidgetTester tester, {
        required String email,
        required String password,
        required String confirmPassword,
        required String phoneNumber,
      }) async {
    await _enterTextInField(tester, 0, email);
    await _enterTextInField(tester, 1, password);
    await _enterTextInField(tester, 2, confirmPassword);
    await _enterPhoneNumber(tester, phoneNumber);
    await tester.pumpAndSettle();
  }

  /// Helper method to enter text in a specific TextField
  static Future<void> _enterTextInField(
      WidgetTester tester,
      int fieldIndex,
      String text,
      ) async {
    await tester.enterText(
      find.byType(TextField).at(fieldIndex),
      text,
    );
  }

  /// Helper method to enter phone number in IntlPhoneField
  static Future<void> _enterPhoneNumber(
      WidgetTester tester,
      String phoneNumber,
      ) async {
    final phoneField = find.byType(IntlPhoneField);
    await tester.tap(phoneField);
    await tester.enterText(
      find.descendant(
        of: phoneField,
        matching: find.byType(TextField),
      ),
      // Remove country code if it exists
      phoneNumber.startsWith('+') ? phoneNumber.substring(3) : phoneNumber,
    );
  }

  /// Submits the registration form
  static Future<void> submitForm(WidgetTester tester) async {
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
  }

  /// Verifies that an error message is displayed
  static Future<void> verifyErrorMessage(
      WidgetTester tester,
      String expectedMessage,
      ) async {
    expect(
      find.text(expectedMessage),
      findsOneWidget,
      reason: 'Expected error message "$expectedMessage" was not found',
    );
  }

  /// Verifies successful registration by checking for UserInformationScreen
  static Future<void> verifySuccessfulRegistration(
      WidgetTester tester,
      ) async {
    expect(
      find.byType(UserInformationScreen),
      findsOneWidget,
      reason: 'UserInformationScreen was not found after registration',
    );
  }

  /// Verifies form field validation states
  static Future<void> verifyFieldValidation(
      WidgetTester tester, {
        bool shouldEmailBeValid = true,
        bool shouldPasswordBeValid = true,
        bool shouldPhoneBeValid = true,
      }) async {
    if (!shouldEmailBeValid) {
      expect(find.text(TestData.invalidEmailError), findsOneWidget);
    }
    if (!shouldPasswordBeValid) {
      expect(find.text(TestData.weakPasswordError), findsOneWidget);
    }
    if (!shouldPhoneBeValid) {
      expect(find.text(TestData.invalidPhoneError), findsOneWidget);
    }
  }
}