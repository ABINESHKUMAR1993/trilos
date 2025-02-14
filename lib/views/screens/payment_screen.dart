import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final int talktime;
  final int payableAmount;

  const PaymentPage({
    super.key,
    required this.talktime,
    required this.payableAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int? selectedUPIMethod;
  int? selectedOtherPaymentMethod;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProcessing = false;

  void _handlePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to previous screen
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountRow('Talktime', '₹${widget.talktime}'),
              const SizedBox(height: 12),
              _buildAmountRow('Payable Amount', '₹${widget.payableAmount}'),
              const SizedBox(height: 24),
              const Text(
                'UPI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUPIOption('Gpay', 'assets/images/png/gpay.png', 0),
                  _buildUPIOption('Paytm', 'assets/images/png/paytm.png', 1),
                  _buildUPIOption(
                    'Phonepe',
                    'assets/images/png/phonepe.png',
                    2,
                  ),
                  _buildUPIOption('Bhim', 'assets/images/png/upi.png', 3),
                ],
              ),
              const SizedBox(height: 24),
              _buildPaymentOption(0, 'QR Code', 'assets/images/png/qr.png'),
              const SizedBox(height: 16),
              _buildPaymentOption(
                1,
                'Credit/Debit Card',
                'assets/images/png/atm.png',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (selectedUPIMethod == null &&
                                  selectedOtherPaymentMethod == null) ||
                              _isProcessing
                          ? null
                          : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isProcessing
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          amount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildUPIOption(String label, String imagePath, int index) {
    return InkWell(
      onTap:
          _isProcessing
              ? null
              : () {
                setState(() {
                  selectedUPIMethod = index;
                  selectedOtherPaymentMethod = null;
                });
              },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  selectedUPIMethod == index
                      ? Colors.pink[100]
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath, width: 36, height: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: selectedUPIMethod == index ? Colors.pink : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, String imagePath) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOtherPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                selectedOtherPaymentMethod == index
                    ? Colors.pink
                    : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Radio<int>(
              value: index,
              groupValue: selectedOtherPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedOtherPaymentMethod = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
