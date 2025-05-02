import 'package:flutter/material.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/utils/http_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = []; // User transactions
  List<Transaction> _allTransactions = []; // All transactions (for admin)
  Transaction? _selectedTransaction;
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get allTransactions => _allTransactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all transactions for the current user
  Future<void> fetchTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await HttpHelper.get('customer/transactions');
      List<Transaction> transactions = [];

      for (var item in response['data']) {
        transactions.add(Transaction.fromJson(item));
      }

      _transactions = transactions;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all transactions (admin only)
  Future<void> fetchAllTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await HttpHelper.get('admin/transactions');
      List<Transaction> transactions = [];

      for (var item in response['data']) {
        transactions.add(Transaction.fromJson(item));
      }

      _allTransactions = transactions;
      notifyListeners();
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
      final response = await HttpHelper.get('customer/transactions/$transactionId');
      _selectedTransaction = Transaction.fromJson(response['data']);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch admin transaction details
  Future<void> fetchAdminTransactionDetails(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await HttpHelper.get('admin/transactions/$transactionId');
      _selectedTransaction = Transaction.fromJson(response['data']);
      notifyListeners();
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
      final response = await HttpHelper.get('customer/payment-methods');
      List<Map<String, dynamic>> methods = [];

      for (var item in response['data']) {
        methods.add(Map<String, dynamic>.from(item));
      }

      _paymentMethods = methods;
      notifyListeners();
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
      final data = {
        'game_id': gameId,
        'package_id': packageId,
        'game_user_id': gameUserId,
        'game_username': gameUsername,
        'payment_method': paymentMethod,
      };

      final response = await HttpHelper.post('customer/transactions', data);
      final transaction = Transaction.fromJson(response['data']);

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

  // Cancel transaction (customer)
  Future<Transaction> cancelTransaction(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await HttpHelper.post('admin/transactions/$transactionId/cancel', {});
      final transaction = Transaction.fromJson(response['data']);

      // Update transaction in admin's list
      final adminIndex = _allTransactions.indexWhere((t) => t.id == transactionId);
      if (adminIndex >= 0) {
        _allTransactions[adminIndex] = transaction;
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

  // Cancel transaction as customer
  Future<Transaction> cancelCustomerTransaction(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await HttpHelper.post('customer/transactions/$transactionId/cancel', {});
      final transaction = Transaction.fromJson(response['data']);

      // Update transaction in user's list
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

  // Update transaction status (admin only)
  Future<Transaction> updateTransactionStatus(
      int transactionId,
      String status,
      String? notes,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final data = {
        'status': status,
      };

      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      final response = await HttpHelper.post(
        'admin/transactions/$transactionId/update-status',
        data,
      );

      final transaction = Transaction.fromJson(response['data']);

      // Update transaction in admin's list
      final adminIndex = _allTransactions.indexWhere((t) => t.id == transactionId);
      if (adminIndex >= 0) {
        _allTransactions[adminIndex] = transaction;
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
      final response = await HttpHelper.get('customer/transactions/$transactionId/payment-status');
      return response;
    } catch (e) {
      _setError(e.toString());
      return {'status': 'error', 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // Get transaction statistics for admin dashboard
  Future<Map<String, dynamic>> getTransactionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      String endpoint = 'admin/transactions/statistics';

      if (startDate != null || endDate != null) {
        List<String> params = [];

        if (startDate != null) {
          params.add('start_date=${startDate.toIso8601String().split('T')[0]}');
        }

        if (endDate != null) {
          params.add('end_date=${endDate.toIso8601String().split('T')[0]}');
        }

        if (params.isNotEmpty) {
          endpoint += '?' + params.join('&');
        }
      }

      final response = await HttpHelper.get(endpoint);
      return response['data'];
    } catch (e) {
      _setError(e.toString());
      return {'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // Filter transactions by status
  List<Transaction> filterTransactionsByStatus(String status) {
    if (status.toLowerCase() == 'semua' || status.isEmpty) {
      return _allTransactions.isEmpty ? _transactions : _allTransactions;
    }

    String statusCode = _getStatusCodeFromDisplay(status);
    return (_allTransactions.isEmpty ? _transactions : _allTransactions)
        .where((t) => t.status == statusCode)
        .toList();
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