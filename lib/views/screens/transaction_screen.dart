import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              title: 'Basic Pack:',
              minutes: '50 minutes',
              price: '\$5.99',
              validity: 'Valid for 30 days',
              date: '21/01/2024',
              status: 'Paid',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Last week',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              title: 'Popular Pack:',
              minutes: '80 minutes',
              price: '\$10.99',
              validity: 'Valid for 30 days',
              date: '21/01/2024',
              status: 'Paid',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              title: 'Unlimited Pack:',
              minutes: 'Unlimited minutes',
              price: '\$29.99/month',
              validity: '',
              date: '21/01/2024',
              status: 'Failed',
              statusColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String minutes,
    required String price,
    required String validity,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            minutes,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          if (validity.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              validity,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}