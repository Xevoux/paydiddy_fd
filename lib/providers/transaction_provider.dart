import 'package:flutter/material.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all transactions for the user
  Future<void> fetchTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      final transactions = await _transactionService.getUserTransactions();
      _transactions = transactions;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch transaction details
  Future<void> fetchTransactionDetails(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _transactionService.getTransactionById(transactionId);
      _selectedTransaction = transaction;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch payment methods
  Future<void> fetchPaymentMethods() async {
    _setLoading(true);
    _clearError();

    try {
      final methods = await _transactionService.getPaymentMethods();
      _paymentMethods = methods;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new transaction
  Future<Transaction> createTransaction({
    required int gameId,
    required int packageId,
    required String gameUserId,
    String? gameUsername,
    String? paymentMethod,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _transactionService.createTransaction(
        gameId: gameId,
        packageId: packageId,
        gameUserId: gameUserId,
        gameUsername: gameUsername,
        paymentMethod: paymentMethod,
      );

      // Add to transactions list
      _transactions.add(transaction);
      _selectedTransaction = transaction;
      notifyListeners();

      return transaction;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel transaction
  Future<Transaction> cancelTransaction(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _transactionService.cancelTransaction(transactionId);

      // Update transaction in list
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index >= 0) {
        _transactions[index] = transaction;
      }

      if (_selectedTransaction?.id == transactionId) {
        _selectedTransaction = transaction;
      }

      notifyListeners();
      return transaction;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get transaction status
  Future<Map<String, dynamic>> getPaymentStatus(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final status = await _transactionService.getPaymentStatus(transactionId);
      return status;
    } catch (e) {
      _setError(e.toString());
      return {'status': 'error', 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // Filter transactions by status
  List<Transaction> filterTransactionsByStatus(String status) {
    if (status.toLowerCase() == 'semua' || status.isEmpty) {
      return _transactions;
    }

    String statusCode = _getStatusCodeFromDisplay(status);
    return _transactions.where((t) => t.status == statusCode).toList();
  }

  String _getStatusCodeFromDisplay(String displayStatus) {
    switch (displayStatus.toLowerCase()) {
      case 'pending':
      case 'menunggu pembayaran':
        return Transaction.STATUS_PENDING;
      case 'berhasil':
      case 'sukses':
        return Transaction.STATUS_SUCCESS;
      case 'diproses':
      case 'processing':
        return Transaction.STATUS_PROCESSING;
      case 'gagal':
      case 'failed':
        return Transaction.STATUS_FAILED;
      case 'dibatalkan':
      case 'cancelled':
        return Transaction.STATUS_CANCELLED;
      case 'dikembalikan':
      case 'refunded':
        return Transaction.STATUS_REFUNDED;
      default:
        return '';
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected transaction
  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
}