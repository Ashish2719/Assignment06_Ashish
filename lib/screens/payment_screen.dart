import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (kDebugMode) {
      print('Payment form submitted');
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      if (kDebugMode) {
        print('Payment failed: validation error');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the form errors.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final double amount = double.parse(_amountController.text.trim());

    if (kDebugMode) {
      print('Payment successful: \$${_amountController.text.trim()}');
      print('Recipient: ${_recipientController.text.trim()}');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          recipientName: _recipientController.text.trim(),
          amount: amount,
          note: _noteController.text.trim(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wideLayout = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wideLayout ? 500 : double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Transfer Details'),
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          hintText: 'Recipient full name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Recipient name is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Enter a valid recipient name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Recipient account number',
                          prefixIcon: Icon(Icons.credit_card_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Account number is required';
                          }
                          if (!RegExp(r'^\d{8,16}$').hasMatch(value.trim())) {
                            return 'Enter 8 to 16 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Amount',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Amount is required';
                          }

                          final double? parsed = double.tryParse(value.trim());

                          if (parsed == null) {
                            return 'Enter a valid amount';
                          }
                          if (parsed <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          if (parsed > 5000) {
                            return 'Demo transfer limit is \$5000';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add a note (optional)',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 44),
                            child: Icon(Icons.sticky_note_2_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      CustomButton(
                        text: 'Send Now',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _submitPayment,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This is a demo payment flow using mock data.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}