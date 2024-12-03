import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chitter_chatter/Features/userAuthentication/register_screen.dart';
import 'test_helpers.dart';

void main() {
  group('RegisterScreen Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const MaterialApp(
        home: RegisterScreen(),
      );
    });

    group('Success Scenarios', () {
      testWidgets(
        'completes registration with valid data',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifySuccessfulRegistration(tester);
        },
      );
    });

    group('Password Validation', () {
      testWidgets(
        'shows error for weak password',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.weakPassword,
            confirmPassword: TestData.weakPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Password must contain an uppercase letter, lowercase letter, numeric and special character.',
          );
        },
      );

      testWidgets(
        'shows error when passwords do not match',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: '${TestData.validPassword}1',
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Password did not match',
          );
        },
      );

      testWidgets(
        'shows error for empty password',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: '',
            confirmPassword: '',
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Please enter a password',
          );
        },
      );
    });

    group('Email Validation', () {
      testWidgets(
        'shows error for existing email',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.existingEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Email already in use. Try another.',
          );
        },
      );

      testWidgets(
        'shows error for invalid email format',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.invalidEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Please enter a valid email address',
          );
        },
      );

      testWidgets(
        'shows error for empty email',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: '',
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Please enter an email address',
          );
        },
      );
    });

    group('Phone Number Validation', () {
      testWidgets(
        'shows error for existing phone number',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.existingPhone,
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Phone number is already in use!',
          );
        },
      );

      testWidgets(
        'shows error for invalid phone format',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: '123',
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Please enter a valid phone number',
          );
        },
      );

      testWidgets(
        'shows error for empty phone number',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: '',
          );

          await TestHelper.submitForm(tester);
          await TestHelper.verifyErrorMessage(
            tester,
            'Please enter a phone number',
          );
        },
      );
    });

    group('Form Interaction Tests', () {
      testWidgets(
        'register button should be enabled only when form is valid',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          final registerButton = find.text('Register');
          expect(tester.widget<ElevatedButton>(registerButton).enabled, false);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          await tester.pump();
          expect(tester.widget<ElevatedButton>(registerButton).enabled, true);
        },
      );

      testWidgets(
        'should show loading indicator when submitting',
            (WidgetTester tester) async {
          await tester.pumpWidget(testWidget);

          await TestHelper.fillRegistrationForm(
            tester,
            email: TestData.validEmail,
            password: TestData.validPassword,
            confirmPassword: TestData.validPassword,
            phoneNumber: TestData.validPhoneNumber,
          );

          // Tap register but don't await pumpAndSettle
          await tester.tap(find.text('Register'));
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );
    });
  });
}