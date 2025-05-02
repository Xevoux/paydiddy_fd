import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/utils/http_helper.dart';

class TransactionService {
  // Mendapatkan daftar transaksi user
  Future<List<Transaction>> getUserTransactions() async {
    final response = await HttpHelper.get('transactions');
    List<Transaction> transactions = [];

    for (var item in response['data']) {
      transactions.add(Transaction.fromJson(item));
    }

    return transactions;
  }

  // Mendapatkan semua transaksi (khusus admin)
  Future<List<Transaction>> getAllTransactions() async {
    final response = await HttpHelper.get('admin/transactions');
    List<Transaction> transactions = [];

    for (var item in response['data']) {
      transactions.add(Transaction.fromJson(item));
    }

    return transactions;
  }

  // Mendapatkan detail transaksi berdasarkan ID
  Future<Transaction> getTransactionById(int id) async {
    final response = await HttpHelper.get('transactions/$id');
    return Transaction.fromJson(response['data']);
  }

  // Membuat transaksi baru
  Future<Transaction> createTransaction({
    required int gameId,
    required int packageId,
    required String gameUserId,
    String? gameUsername,
    String? paymentMethod,
  }) async {
    final data = {
      'game_id': gameId,
      'package_id': packageId,
      'game_user_id': gameUserId,
    };

    if (gameUsername != null && gameUsername.isNotEmpty) {
      data['game_username'] = gameUsername;
    }

    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      data['payment_method'] = paymentMethod;
    }

    final response = await HttpHelper.post('transactions', data);
    return Transaction.fromJson(response['data']);
  }

  // Membatalkan transaksi
  Future<Transaction> cancelTransaction(int id) async {
    final response = await HttpHelper.post('transactions/$id/cancel', {});
    return Transaction.fromJson(response['data']);
  }

  // Mendapatkan status pembayaran
  Future<Map<String, dynamic>> getPaymentStatus(int id) async {
    final response = await HttpHelper.get('transactions/$id/payment-status');
    return response;
  }

  // Mengupdate status pembayaran (callback)
  Future<Transaction> updatePaymentStatus(int id, String status, Map<String, dynamic> paymentDetails) async {
    final response = await HttpHelper.post('transactions/$id/update-status', {
      'status': status,
      'payment_details': paymentDetails,
    });
    return Transaction.fromJson(response['data']);
  }

  // Mendapatkan metode pembayaran yang tersedia
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await HttpHelper.get('payment-methods');
    List<Map<String, dynamic>> methods = [];

    for (var item in response['data']) {
      methods.add(Map<String, dynamic>.from(item));
    }

    return methods;
  }

  // Admin: Filter transaksi berdasarkan tanggal
  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final formattedStartDate = startDate.toIso8601String().split('T')[0];
    final formattedEndDate = endDate.toIso8601String().split('T')[0];

    final response = await HttpHelper.get(
        'admin/transactions/filter?start_date=$formattedStartDate&end_date=$formattedEndDate'
    );

    List<Transaction> transactions = [];
    for (var item in response['data']) {
      transactions.add(Transaction.fromJson(item));
    }

    return transactions;
  }

  // Admin: Mendapatkan statistik transaksi
  Future<Map<String, dynamic>> getTransactionStatistics() async {
    final response = await HttpHelper.get('admin/transactions/statistics');
    return response['data'];
  }
}