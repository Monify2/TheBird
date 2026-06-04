import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _contactController = TextEditingController();
  final FocusNode _contactFocusNode = FocusNode();

  String _inputType = 'email';
  String _countryCode = '+1';
  bool _isLoading = false;

  void _detectInputType(String text) {
    setState(() {
      _inputType = text.contains('@') ? 'email' : 'phone';
    });
  }

  void _onCountryCodeChange(String code) {
    setState(() {
      _countryCode = code;
    });
  }

  TextInputType _getKeyboardType() {
    return _inputType == 'email' ? TextInputType.emailAddress : TextInputType.phone;
  }

  String _getPlaceholder() {
    return _inputType == 'email' ? 'Email Address' : 'Mobile Number';
  }

  Future<void> _handleSendCode() async {
    if (_contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email or phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // This method should be implemented in your AuthProvider
      await auth.sendPasswordReset(_contactController.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset code sent to ${_contactController.text}')),
        );
        context.go('/reset-password');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    _contactFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your email or phone number to receive a password reset code.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Contact Input with Country Code
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (_inputType == 'phone')
                      CountryCodePicker(
                        onChanged: _onCountryCodeChange,
                        initialSelection: 'US',
                        favorite: const ['US', 'NG', 'GB'],
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: true,
                        alignLeft: false,
                        flag: true,
                        flagWidth: 24,
                      ),
                    Expanded(
                      child: TextField(
                        controller: _contactController,
                        keyboardType: _getKeyboardType(),
                        onChanged: _detectInputType,
                        focusNode: _contactFocusNode,
                        decoration: InputDecoration(
                          hintText: _getPlaceholder(),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: _inputType == 'email'
                              ? const Icon(Icons.email_outlined)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Send Code Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D5FEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Reset Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Remember your password? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/');
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF5D5FEF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
