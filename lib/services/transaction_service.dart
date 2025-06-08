import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/utils/http_helper.dart';

class TransactionService {
  // Mendapatkan daftar transaksi user
  Future<List<Transaction>> getUserTransactions() async {
    try {
      final response = await HttpHelper.get('transactions');
      List<Transaction> transactions = [];

      for (var item in response['data']) {
        transactions.add(Transaction.fromJson(item));
      }

      return transactions;
    } catch (e) {
      print('Error getting user transactions: $e');
      throw Exception('Gagal memuat riwayat transaksi: ${e.toString()}');
    }
  }

  // Mendapatkan semua transaksi (khusus admin)
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await HttpHelper.get('admin/transactions');
      List<Transaction> transactions = [];

      for (var item in response['data']) {
        transactions.add(Transaction.fromJson(item));
      }

      return transactions;
    } catch (e) {
      print('Error getting all transactions: $e');
      throw Exception('Gagal memuat semua transaksi: ${e.toString()}');
    }
  }

  // Mendapatkan detail transaksi berdasarkan ID
  Future<Transaction> getTransactionById(int id) async {
    try {
      final response = await HttpHelper.get('transactions/$id');
      return Transaction.fromJson(response['data']);
    } catch (e) {
      print('Error getting transaction by ID: $e');
      throw Exception('Gagal memuat detail transaksi: ${e.toString()}');
    }
  }

  // Membuat transaksi baru
  Future<Transaction> createTransaction({
    required int gameId,
    required int packageId,
    required String gameUserId,
    String? gameUsername,
    String? paymentMethod,
  }) async {
    try {
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

      print('Creating transaction with data: $data');
      final response = await HttpHelper.post('transactions', data);
      return Transaction.fromJson(response['data']);
    } catch (e) {
      print('Error creating transaction: $e');
      throw Exception('Gagal membuat transaksi: ${e.toString()}');
    }
  }

  // Membatalkan transaksi
  Future<Transaction> cancelTransaction(int id) async {
    try {
      final response = await HttpHelper.post('transactions/$id/cancel', {});
      return Transaction.fromJson(response['data']);
    } catch (e) {
      print('Error canceling transaction: $e');
      throw Exception('Gagal membatalkan transaksi: ${e.toString()}');
    }
  }

  // Mendapatkan status pembayaran
  Future<Map<String, dynamic>> getPaymentStatus(int id) async {
    try {
      final response = await HttpHelper.get('transactions/$id/payment-status');
      return response;
    } catch (e) {
      print('Error getting payment status: $e');
      throw Exception('Gagal memuat status pembayaran: ${e.toString()}');
    }
  }

  // Mengupdate status pembayaran (callback)
  Future<Transaction> updatePaymentStatus(int id, String status, Map<String, dynamic> paymentDetails) async {
    try {
      final response = await HttpHelper.post('transactions/$id/update-status', {
        'status': status,
        'payment_details': paymentDetails,
      });
      return Transaction.fromJson(response['data']);
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Gagal mengupdate status pembayaran: ${e.toString()}');
    }
  }

  // Mendapatkan metode pembayaran yang tersedia
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      print('Fetching payment methods...');

      // Debug: cek apakah endpoint benar
      final response = await HttpHelper.get('payment-methods');

      print('Payment methods response received: $response');

      if (response == null) {
        throw Exception('Response is null');
      }

      if (response['data'] == null) {
        throw Exception('Data is null in response');
      }

      List<Map<String, dynamic>> methods = [];

      final dataList = response['data'] as List;
      print('Payment methods count: ${dataList.length}');

      for (var item in dataList) {
        if (item != null) {
          methods.add(Map<String, dynamic>.from(item));
        }
      }

      print('Processed payment methods: $methods');
      return methods;

    } catch (e) {
      print('Error getting payment methods: $e');
      print('Error type: ${e.runtimeType}');

      // Jika ada error, coba return hardcoded methods untuk testing
      print('Returning fallback payment methods for testing...');
      return [
        {
          'code': 'bank_transfer',
          'name': 'Transfer Bank',
          'type': 'bank',
          'description': 'Transfer melalui ATM, Mobile Banking, atau Internet Banking',
        },
        {
          'code': 'ewallet_ovo',
          'name': 'OVO',
          'type': 'ewallet',
          'description': 'Pembayaran melalui OVO',
        },
        {
          'code': 'ewallet_gopay',
          'name': 'GoPay',
          'type': 'ewallet',
          'description': 'Pembayaran melalui GoPay',
        },
        {
          'code': 'ewallet_dana',
          'name': 'DANA',
          'type': 'ewallet',
          'description': 'Pembayaran melalui DANA',
        },
        {
          'code': 'qris',
          'name': 'QRIS',
          'type': 'qris',
          'description': 'Scan QR Code untuk pembayaran',
        },
      ];
    }
  }

  // Admin: Filter transaksi berdasarkan tanggal
  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
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
    } catch (e) {
      print('Error getting transactions by date range: $e');
      throw Exception('Gagal memuat transaksi berdasarkan tanggal: ${e.toString()}');
    }
  }

  // Admin: Mendapatkan statistik transaksi
  Future<Map<String, dynamic>> getTransactionStatistics() async {
    try {
      final response = await HttpHelper.get('admin/transactions/statistics');
      return response['data'];
    } catch (e) {
      print('Error getting transaction statistics: $e');
      throw Exception('Gagal memuat statistik transaksi: ${e.toString()}');
    }
  }
}