import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:paydiddy/screens/customer/transaction_detail_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionSuccessScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionSuccessScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
          (route) => false,
    );
  }

  void _copyToClipboard(String text, String label) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Transaksi Berhasil',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _goToHome(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Success Header
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.green,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Transaksi Berhasil!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pesanan Anda sedang diproses',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction Info
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Transaction ID
                    _buildInfoRow(
                      'ID Transaksi',
                      transaction.referenceId,
                      isCopiable: true,
                      onCopy: () => _copyToClipboard(transaction.referenceId, 'ID Transaksi'),
                    ),
                    const Divider(height: 24),

                    // Game Info
                    _buildInfoRow(
                      'Game',
                      transaction.game?.name ?? 'Unknown Game',
                    ),
                    const SizedBox(height: 12),

                    // Package Info
                    _buildInfoRow(
                      'Item',
                      transaction.package?.denomination ?? 'Unknown Package',
                    ),
                    const SizedBox(height: 12),

                    // Game ID
                    _buildInfoRow(
                      'ID Game',
                      transaction.gameUserId,
                      isCopiable: true,
                      onCopy: () => _copyToClipboard(transaction.gameUserId, 'ID Game'),
                    ),

                    if (transaction.gameUsername != null && transaction.gameUsername!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Username',
                        transaction.gameUsername!,
                      ),
                    ],

                    const Divider(height: 24),

                    // Payment Info
                    _buildInfoRow(
                      'Metode Pembayaran',
                      transaction.paymentMethod ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),

                    // Total Amount
                    _buildInfoRow(
                      'Total Bayar',
                      'Rp ${transaction.amount.toStringAsFixed(0)}',
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status
                    _buildInfoRow(
                      'Status',
                      transaction.statusText,
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(transaction.status),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionDetailScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Detail Transaksi'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: Colors.blue.shade900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _goToHome(context),
                            icon: const Icon(Icons.home),
                            label: const Text('Kembali ke Home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Payment Information or Instructions would go here if needed
                    if (transaction.isPending) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                                  'Menunggu Pembayaran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Silakan selesaikan pembayaran sesuai dengan instruksi yang telah dikirimkan melalui email atau lihat detail transaksi.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        bool isCopiable = false,
        VoidCallback? onCopy,
        TextStyle? labelStyle,
        TextStyle? valueStyle,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: labelStyle ?? TextStyle(
              color: Colors.grey[600],
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
                  style: valueStyle ?? const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
    );
  }
}