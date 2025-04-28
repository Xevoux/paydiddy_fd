import 'package:flutter/material.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/services/transaction_service.dart';
import 'package:paydiddy/screens/customer/transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  // Status filter options
  final List<String> _statusFilters = ['Semua', 'Pending', 'Berhasil', 'Diproses', 'Gagal', 'Dibatalkan'];
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _transactionService.getUserTransactions();

      setState(() {
        _transactions = transactions;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  _applyFilters() {
    if (_selectedStatus == 'Semua') {
      _filteredTransactions = List.from(_transactions);
    } else {
      String statusCode = _getStatusCodeFromDisplay(_selectedStatus);
      _filteredTransactions = _transactions.where((t) => t.status == statusCode).toList();
    }

    // Sort by date (newest first)
    _filteredTransactions.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
  }

  String _getStatusCodeFromDisplay(String displayStatus) {
    switch (displayStatus.toLowerCase()) {
      case 'pending':
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case Transaction.STATUS_PENDING:
        return Icons.access_time;
      case Transaction.STATUS_PROCESSING:
        return Icons.sync;
      case Transaction.STATUS_SUCCESS:
        return Icons.check_circle;
      case Transaction.STATUS_FAILED:
        return Icons.error;
      case Transaction.STATUS_CANCELLED:
        return Icons.cancel;
      case Transaction.STATUS_REFUNDED:
        return Icons.replay;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue[900],
              labelColor: Colors.blue[900],
              unselectedLabelColor: Colors.grey[600],
              tabs: const [
                Tab(text: 'Semua Transaksi'),
                Tab(text: 'Filter Status'),
              ],
              onTap: (index) {
                if (index == 0) {
                  setState(() {
                    _selectedStatus = 'Semua';
                    _applyFilters();
                  });
                }
              },
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Transactions Tab
          _buildTransactionList(),

          // Filter Tab
          _buildFilterOptions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTransactions,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              color: Colors.grey[400],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus == 'Semua'
                  ? 'Belum ada transaksi'
                  : 'Tidak ada transaksi $_selectedStatus',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadTransactions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildFilterOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter berdasarkan Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusFilters.map((status) {
              final isSelected = _selectedStatus == status;

              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[900] : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = status;
                      _applyFilters();
                      _tabController.animateTo(0); // Switch to first tab to show results
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedStatus = 'Semua';
                _applyFilters();
                _tabController.animateTo(0); // Switch to first tab to show results
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Hapus Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final gameName = transaction.game?.name ?? 'Unknown Game';
    final packageName = transaction.package?.denomination ?? 'Unknown Package';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(
                transaction: transaction,
              ),
            ),
          ).then((_) => _loadTransactions()); // Refresh after returning
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${transaction.referenceId}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    transaction.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const Divider(height: 16),

              // Game and Package Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.games,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          packageName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amount and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(transaction.status)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(transaction.status),
                          size: 14,
                          color: _getStatusColor(transaction.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(transaction.status),
                          ),
                        ),
                      ],
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