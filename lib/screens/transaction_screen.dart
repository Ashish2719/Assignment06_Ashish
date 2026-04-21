import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all';

  List<Map<String, dynamic>> get _filteredTransactions {
    final String query = _searchController.text.trim().toLowerCase();

    return widget.transactions.where((item) {
      final String title = (item['title'] as String).toLowerCase();
      final String subtitle = (item['subtitle'] as String).toLowerCase();
      final String type = item['type'] as String;

      final bool matchesQuery =
          title.contains(query) || subtitle.contains(query);
      final bool matchesType =
          _selectedType == 'all' || type == _selectedType;

      return matchesQuery && matchesType;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip({
    required String value,
    required String label,
  }) {
    final bool isSelected = _selectedType == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedType = value;
        });
      },
      selectedColor: const Color(0xFF111827),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF111827),
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item) {
    final bool isCredit = item['type'] == 'credit';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF3F4F6),
            child: Icon(
              item['icon'] as IconData,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$${(item['amount'] as double).toStringAsFixed(2)}',
            style: TextStyle(
              color:
                  isCredit ? const Color(0xFF16A34A) : const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Search transactions',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip(value: 'all', label: 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(value: 'debit', label: 'Debit'),
                  const SizedBox(width: 8),
                  _buildFilterChip(value: 'credit', label: 'Credit'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions found.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(filtered[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}