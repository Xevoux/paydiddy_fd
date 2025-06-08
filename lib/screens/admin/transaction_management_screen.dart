import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/providers/transaction_provider.dart';
import 'package:paydiddy/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class TransactionManagementScreen extends StatefulWidget {
  const TransactionManagementScreen({super.key});

  @override
  State<TransactionManagementScreen> createState() => _TransactionManagementScreenState();
}

class _TransactionManagementScreenState extends State<TransactionManagementScreen> {
  bool _isLoading = true;
  String _selectedStatusFilter = 'Semua';
  DateTime? _startDate;
  DateTime? _endDate;
  List<Transaction> _filteredTransactions = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'Semua',
    'Menunggu Pembayaran',
    'Diproses',
    'Berhasil',
    'Gagal',
    'Dibatalkan'
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    // Add search listener
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransactions);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchAllTransactions();
      _filterTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading transactions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTransactions() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    List<Transaction> transactions = transactionProvider.allTransactions;

    // Filter by status
    if (_selectedStatusFilter != 'Semua') {
      transactions = transactionProvider.filterTransactionsByStatus(_selectedStatusFilter);
    }

    // Filter by date range
    if (_startDate != null) {
      transactions = transactions.where((t) {
        if (t.createdAt == null) return false;
        final transactionDate = DateTime.parse(t.createdAt!);
        return transactionDate.isAfter(_startDate!) ||
            transactionDate.isAtSameMomentAs(_startDate!);
      }).toList();
    }

    if (_endDate != null) {
      final nextDay = _endDate!.add(const Duration(days: 1));
      transactions = transactions.where((t) {
        if (t.createdAt == null) return false;
        final transactionDate = DateTime.parse(t.createdAt!);
        return transactionDate.isBefore(nextDay);
      }).toList();
    }

    // Filter by search term (user ID, transaction ID, game name)
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      transactions = transactions.where((t) {
        final searchString = [
          t.referenceId.toLowerCase(),
          t.gameUserId.toLowerCase(),
          t.game?.name.toLowerCase() ?? '',
          t.gameUsername?.toLowerCase() ?? '',
          t.userId.toString(),
        ].join(' ');
        return searchString.contains(searchTerm);
      }).toList();
    }

    // Sort by date (newest first)
    transactions.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!));
    });

    setState(() {
      _filteredTransactions = transactions;
    });
  }

  Future<void> _cancelTransaction(Transaction transaction) async {
    if (transaction.status != Transaction.STATUS_PENDING) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya transaksi dengan status "Menunggu Pembayaran" yang dapat dibatalkan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Transaksi'),
        content: Text('Apakah Anda yakin ingin membatalkan transaksi ${transaction.referenceId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              try {
                final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                await transactionProvider.cancelTransaction(transaction.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaksi berhasil dibatalkan'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Refresh data
                await _loadTransactions();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1),
                      maxTime: DateTime.now(),
                      currentTime: _startDate ?? DateTime.now(),
                      locale: LocaleType.id,
                      onConfirm: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
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
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1),
                      maxTime: DateTime.now(),
                      currentTime: _endDate ?? DateTime.now(),
                      locale: LocaleType.id,
                      onConfirm: (date) {
                        setState(() {
                          _endDate = date;
                        });
                      },
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
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _filterTransactions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search and filter section
          Container(
            color: Colors.blue[900],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari ID transaksi, user ID, atau game',
                    hintStyle: TextStyle(color: Colors.blue[100]),
                    prefixIcon: Icon(Icons.search, color: Colors.blue[100]),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatusFilter,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatusFilter = value;
                            });
                            _filterTransactions();
                          }
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
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                if (_startDate != null || _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.blue[100]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                        : _startDate != null
                                        ? 'Dari ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                                        : 'Sampai ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      _startDate = null;
                                      _endDate = null;
                                    });
                                    _filterTransactions();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Transaction list
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada transaksi ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  final Color statusColor = _getStatusColor(transaction.status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _showTransactionDetails(transaction),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'ID: ${transaction.referenceId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  transaction.formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.games,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.game?.name ?? 'Unknown Game',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${transaction.package?.name ?? 'Unknown Package'} (ID: ${transaction.gameUserId})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      transaction.formattedAmount,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        transaction.statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (transaction.isPending)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _cancelTransaction(transaction),
                                      icon: const Icon(Icons.cancel, size: 16),
                                      label: const Text('Batalkan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
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

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID Transaksi', transaction.referenceId),
              _buildDetailItem('Game', transaction.game?.name ?? 'Unknown'),
              _buildDetailItem('Paket', transaction.package?.name ?? 'Unknown'),
              _buildDetailItem('Jumlah', transaction.formattedAmount),
              _buildDetailItem('Game ID', transaction.gameUserId),
              if (transaction.gameUsername != null && transaction.gameUsername!.isNotEmpty)
                _buildDetailItem('Username', transaction.gameUsername!),
              _buildDetailItem('Status', transaction.statusText),
              _buildDetailItem('Metode Pembayaran', transaction.paymentMethod ?? '-'),
              _buildDetailItem('Tanggal', transaction.formattedDate),
              _buildDetailItem('User ID', transaction.userId.toString()),
            ],
          ),
        ),
        actions: [
          if (transaction.isPending)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelTransaction(transaction);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Batalkan Transaksi'),
            ),
          if (transaction.isPending || transaction.isProcessing)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateTransactionStatus(transaction);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Update Status'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _updateTransactionStatus(Transaction transaction) {
    final statusController = TextEditingController();
    final noteController = TextEditingController();
    String selectedStatus = transaction.status;

    final statusOptions = [
      {'value': Transaction.STATUS_PENDING, 'label': 'Menunggu Pembayaran'},
      {'value': Transaction.STATUS_PROCESSING, 'label': 'Diproses'},
      {'value': Transaction.STATUS_SUCCESS, 'label': 'Berhasil'},
      {'value': Transaction.STATUS_FAILED, 'label': 'Gagal'},
      {'value': Transaction.STATUS_CANCELLED, 'label': 'Dibatalkan'},
      {'value': Transaction.STATUS_REFUNDED, 'label': 'Dikembalikan'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Status Transaksi'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID Transaksi: ${transaction.referenceId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Status Baru:'),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status['value']!,
                        child: Text(status['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Catatan Admin:'),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                    await transactionProvider.updateTransactionStatus(
                      transaction.id,
                      selectedStatus,
                      noteController.text.isNotEmpty ? noteController.text : null,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status transaksi berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Refresh data
                    await _loadTransactions();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}