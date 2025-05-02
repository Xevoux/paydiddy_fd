// Pastikan sudah ada dependency ini di pubspec.yaml
// flutter_datetime_picker_plus: ^2.0.1

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:paydiddy/screens/customer/game_list_screen.dart';
import 'package:paydiddy/screens/customer/customer_settings_screen.dart';
import 'package:paydiddy/screens/customer/transaction_detail_screen.dart';
import 'package:paydiddy/services/transaction_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _searchController = TextEditingController();
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 2;

  final List<String> _statusFilters = ['Semua', 'Menunggu Pembayaran', 'Berhasil', 'Diproses', 'Gagal', 'Dibatalkan'];
  String _selectedStatus = 'Semua';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _transactionService.getUserTransactions();
      _transactions = transactions;
      _applyFilters();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Transaction> filtered = List.from(_transactions);

    if (_selectedStatus != 'Semua') {
      String code = _getStatusCodeFromDisplay(_selectedStatus);
      filtered = filtered.where((t) => t.status == code).toList();
    }

    if (_startDate != null) {
      filtered = filtered.where((t) {
        final createdAt = DateTime.tryParse(t.createdAt ?? '');
        if (createdAt == null) return false;
        return createdAt.isAfter(_startDate!) || createdAt.isAtSameMomentAs(_startDate!);
      }).toList();
    }

    if (_endDate != null) {
      final end = _endDate!.add(const Duration(days: 1));
      filtered = filtered.where((t) {
        final createdAt = DateTime.tryParse(t.createdAt ?? '');
        if (createdAt == null) return false;
        return createdAt.isBefore(end);
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final term = _searchController.text.toLowerCase();
      filtered = filtered.where((t) {
        final text = [
          t.referenceId.toLowerCase(),
          t.gameUserId.toLowerCase(),
          t.game?.name?.toLowerCase() ?? '',
          t.gameUsername?.toLowerCase() ?? '',
        ].join(' ');
        return text.contains(term);
      }).toList();
    }

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '');
      final bDate = DateTime.tryParse(b.createdAt ?? '');
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  String _getStatusCodeFromDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu pembayaran':
        return Transaction.STATUS_PENDING;
      case 'berhasil':
        return Transaction.STATUS_SUCCESS;
      case 'diproses':
        return Transaction.STATUS_PROCESSING;
      case 'gagal':
        return Transaction.STATUS_FAILED;
      case 'dibatalkan':
        return Transaction.STATUS_CANCELLED;
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Transaction.STATUS_PENDING:
        return Colors.orange;
      case Transaction.STATUS_PROCESSING:
        return Colors.blue;
      case Transaction.STATUS_SUCCESS:
        return Colors.green;
      case Transaction.STATUS_FAILED:
        return Colors.red;
      case Transaction.STATUS_CANCELLED:
        return Colors.grey;
      case Transaction.STATUS_REFUNDED:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _selectDateRange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Rentang Tanggal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(_startDate == null
                  ? 'Tanggal Mulai'
                  : 'Mulai: ${DateFormat('dd MMM yyyy').format(_startDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  currentTime: _startDate ?? DateTime.now(),
                  onConfirm: (date) => setState(() => _startDate = date),
                  locale: LocaleType.id,
                );
              },
            ),
            ListTile(
              title: Text(_endDate == null
                  ? 'Tanggal Akhir'
                  : 'Akhir: ${DateFormat('dd MMM yyyy').format(_endDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  currentTime: _endDate ?? DateTime.now(),
                  onConfirm: (date) => setState(() => _endDate = date),
                  locale: LocaleType.id,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            color: Colors.blue[900],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari ID transaksi, user ID, atau game',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _statusFilters.map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value ?? 'Semua');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: _selectDateRange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTransactions,
              child: _filteredTransactions.isEmpty
                  ? const Center(child: Text('Tidak ada transaksi ditemukan'))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final t = _filteredTransactions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailScreen(transaction: t),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ID: ${t.referenceId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(t.formattedDate, style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.gamepad, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.game?.name ?? 'Unknown Game',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(
                                        '${t.package?.name ?? 'Unknown Package'} (ID: ${t.gameUserId})',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(t.formattedAmount,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900])),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(t.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        t.statusText,
                                        style: TextStyle(
                                            color: _getStatusColor(t.status), fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GameListScreen(title: 'Semua Game')));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSettingsScreen()));
              break;
          }
        },
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Top Up'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}