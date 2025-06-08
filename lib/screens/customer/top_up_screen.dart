import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/models/game_package.dart';
import 'package:paydiddy/services/transaction_service.dart';
import 'package:paydiddy/screens/customer/transaction_success_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopUpScreen extends StatefulWidget {
  final Game game;
  final GamePackage package;
  final String gameUserId;
  final String gameUsername;

  const TopUpScreen({
    super.key,
    required this.game,
    required this.package,
    required this.gameUserId,
    required this.gameUsername,
  });

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TransactionService _transactionService = TransactionService();

  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedPaymentMethod;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final methods = await _transactionService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        // Set default payment method if available
        if (methods.isNotEmpty) {
          _selectedPaymentMethod = methods[0]['code'];
        }
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

  _processTransaction() async {
    if (_selectedPaymentMethod == null) {
      Fluttertoast.showToast(
        msg: 'Silakan pilih metode pembayaran',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final transaction = await _transactionService.createTransaction(
        gameId: widget.game.id,
        packageId: widget.package.id,
        gameUserId: widget.gameUserId,
        gameUsername: widget.gameUsername,
        paymentMethod: _selectedPaymentMethod,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionSuccessScreen(
            transaction: transaction,
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalPrice = widget.package.finalPrice;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Top Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Game Info Row
                    Row(
                      children: [
                        // Game Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: widget.game.image.isNotEmpty
                                ? DecorationImage(
                              image: NetworkImage(widget.game.image),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: widget.game.image.isEmpty
                              ? Icon(
                            Icons.games,
                            color: Colors.blue[300],
                            size: 30,
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Game and Package Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.game.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.package.name,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.package.denomination,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // User Game Info
                    Column(
                      children: [
                        _buildInfoRow('ID Game', widget.gameUserId),
                        const SizedBox(height: 8),
                        _buildInfoRow('Username', widget.gameUsername.isNotEmpty ? widget.gameUsername : '-'),
                      ],
                    ),

                    const Divider(height: 32),

                    // Price Summary
                    Column(
                      children: [
                        _buildInfoRow('Harga', 'Rp ${widget.package.price.toStringAsFixed(0)}'),
                        if (widget.package.isPromo && widget.package.discountPrice != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Diskon',
                            '- Rp ${(widget.package.price - widget.package.discountPrice!).toStringAsFixed(0)}',
                            valueColor: Colors.green,
                          ),
                        ],
                        const Divider(height: 16),
                        _buildInfoRow(
                          'Total Bayar',
                          'Rp ${finalPrice.toStringAsFixed(0)}',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          valueStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method List
                    _paymentMethods.isEmpty
                        ? const Center(
                      child: Text(
                        'Tidak ada metode pembayaran tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : Column(
                      children: _paymentMethods.map((method) {
                        return _buildPaymentMethodItem(method);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Process Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _processTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.blue[300],
              ),
              child: _isProcessing
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Bayar Sekarang - Rp ${finalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        Color? valueColor,
        TextStyle? labelStyle,
        TextStyle? valueStyle,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? TextStyle(color: Colors.grey[700]),
        ),
        Text(
          value,
          style: valueStyle ?? TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final bool isSelected = _selectedPaymentMethod == method['code'];

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['code'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              )
                  : null,
            ),

            // Payment logo/icon (would use an image in a real app)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getPaymentIcon(method['type'] ?? ''),
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Payment details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['description'] ?? 'Pembayaran instan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'qris':
        return Icons.qr_code;
      case 'credit':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}