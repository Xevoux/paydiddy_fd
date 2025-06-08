import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/services/transaction_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  bool _isCancelling = false;
  Transaction? _updatedTransaction;

  @override
  void initState() {
    super.initState();
    _refreshTransactionStatus();
  }

  _refreshTransactionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Refresh transaction status from API
      final updatedTransaction = await _transactionService.getTransactionById(widget.transaction.id);
      setState(() {
        _updatedTransaction = updatedTransaction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  _cancelTransaction() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final updatedTransaction = await _transactionService.cancelTransaction(widget.transaction.id);
      setState(() {
        _updatedTransaction = updatedTransaction;
        _isCancelling = false;
      });

      Fluttertoast.showToast(
        msg: 'Transaksi berhasil dibatalkan',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      setState(() {
        _isCancelling = false;
      });

      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '$label berhasil disalin',
      backgroundColor: Colors.green,
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

  String _getStatusDescription(String status) {
    switch (status) {
      case Transaction.STATUS_PENDING:
        return 'Menunggu pembayaran Anda';
      case Transaction.STATUS_PROCESSING:
        return 'Transaksi sedang diproses';
      case Transaction.STATUS_SUCCESS:
        return 'Transaksi telah berhasil diselesaikan';
      case Transaction.STATUS_FAILED:
        return 'Transaksi gagal diselesaikan';
      case Transaction.STATUS_CANCELLED:
        return 'Transaksi telah dibatalkan';
      case Transaction.STATUS_REFUNDED:
        return 'Pembayaran telah dikembalikan';
      default:
        return 'Status transaksi tidak diketahui';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use updated transaction if available, otherwise use original
    final transaction = _updatedTransaction ?? widget.transaction;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshTransactionStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(20),
              color: _getStatusColor(transaction.status),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(transaction.status),
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusDescription(transaction.status),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Show cancel button for pending transactions
                  if (transaction.isPending) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isCancelling ? null : _cancelTransaction,
                      icon: _isCancelling
                          ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.cancel),
                      label: Text(_isCancelling ? 'Membatalkan...' : 'Batalkan Transaksi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _getStatusColor(transaction.status),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Transaction Details
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Informasi Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${transaction.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Transaction ID
                  _buildDetailItem(
                    'ID Transaksi',
                    transaction.referenceId,
                    isCopiable: true,
                    onCopy: () => _copyToClipboard(transaction.referenceId, 'ID Transaksi'),
                  ),

                  // Date and Time
                  _buildDetailItem(
                    'Tanggal',
                    transaction.createdAt != null
                        ? _formatDateTime(transaction.createdAt!)
                        : '-',
                  ),

                  // Game Info
                  if (transaction.game != null) ...[
                    _buildDetailItem(
                      'Game',
                      transaction.game!.name,
                    ),
                  ],

                  // Package Info
                  if (transaction.package != null) ...[
                    _buildDetailItem(
                      'Item',
                      '${transaction.package!.name} (${transaction.package!.denomination})',
                    ),
                  ],

                  // Game ID and Username
                  _buildDetailItem(
                    'ID Game',
                    transaction.gameUserId,
                    isCopiable: true,
                    onCopy: () => _copyToClipboard(transaction.gameUserId, 'ID Game'),
                  ),

                  if (transaction.gameUsername != null && transaction.gameUsername!.isNotEmpty)
                    _buildDetailItem(
                      'Username',
                      transaction.gameUsername!,
                    ),
                ],
              ),
            ),

            // Payment Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Payment Method
                  _buildDetailItem(
                    'Metode Pembayaran',
                    transaction.paymentMethod ?? 'Unknown',
                  ),

                  // Price Details
                  if (transaction.package != null) ...[
                    _buildDetailItem(
                      'Harga',
                      'Rp ${transaction.package!.price.toStringAsFixed(0)}',
                    ),

                    // Show discount if applicable
                    if (transaction.package!.isPromo && transaction.package!.discountPrice != null)
                      _buildDetailItem(
                        'Diskon',
                        '- Rp ${(transaction.package!.price - transaction.package!.discountPrice!).toStringAsFixed(0)}',
                        valueColor: Colors.green,
                      ),
                  ],

                  // Total Amount
                  _buildDetailItem(
                    'Total Bayar',
                    'Rp ${transaction.amount.toStringAsFixed(0)}',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    valueStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Instructions (if pending payment)
            if (transaction.isPending)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.orange[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instruksi Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Silakan selesaikan pembayaran Anda dengan mengikuti instruksi berikut:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Example payment instructions
                    // In a real app, these would come from the payment provider
                    if (transaction.paymentMethod?.toLowerCase().contains('bank') ?? false) ...[
                      _buildPaymentStep(1, 'Transfer ke rekening Bank XXX dengan nomor 1234567890'),
                      _buildPaymentStep(2, 'Gunakan nominal tepat sesuai tagihan: Rp ${transaction.amount.toStringAsFixed(0)}'),
                      _buildPaymentStep(3, 'Masukkan ID transaksi ${transaction.referenceId} sebagai keterangan transfer'),
                      _buildPaymentStep(4, 'Simpan bukti transfer untuk konfirmasi jika diperlukan'),
                    ] else if (transaction.paymentMethod?.toLowerCase().contains('wallet') ?? false) ...[
                      _buildPaymentStep(1, 'Buka aplikasi e-wallet Anda'),
                      _buildPaymentStep(2, 'Scan QR code atau masukkan nomor merchant 1234567890'),
                      _buildPaymentStep(3, 'Masukkan jumlah pembayaran: Rp ${transaction.amount.toStringAsFixed(0)}'),
                      _buildPaymentStep(4, 'Konfirmasi dan selesaikan pembayaran di aplikasi e-wallet Anda'),
                    ] else ...[
                      _buildPaymentStep(1, 'Pilih metode pembayaran yang tersedia'),
                      _buildPaymentStep(2, 'Ikuti instruksi pembayaran yang diberikan'),
                      _buildPaymentStep(3, 'Pastikan pembayaran dilakukan sebelum batas waktu berakhir'),
                      _buildPaymentStep(4, 'Transaksi akan diproses otomatis setelah pembayaran berhasil'),
                    ],

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.orange[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selesaikan pembayaran dalam waktu 24 jam atau transaksi akan dibatalkan secara otomatis.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String label,
      String value, {
        bool isCopiable = false,
        VoidCallback? onCopy,
        TextStyle? labelStyle,
        TextStyle? valueStyle,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: labelStyle ?? TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: valueStyle ?? TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: valueColor,
                    ),
                  ),
                ),
                if (isCopiable && onCopy != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey[600],
                    onPressed: onCopy,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(int step, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}