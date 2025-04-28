import 'package:paydiddy/models/game.dart';
import 'game_package.dart';

class Transaction {
  final int id;
  final int userId;
  final int gameId;
  final int packageId;
  final String gameUserId;
  final double amount;
  final String status;
  final String referenceId;
  final String? paymentMethod;
  final String? paymentDetails;
  final String? gameUsername;
  final String? createdAt;
  final String? updatedAt;
  final Game? game;
  final GamePackage? package;

  Transaction({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.packageId,
    required this.gameUserId,
    required this.amount,
    required this.status,
    required this.referenceId,
    this.paymentMethod,
    this.paymentDetails,
    this.gameUsername,
    this.createdAt,
    this.updatedAt,
    this.game,
    this.package,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      gameId: json['game_id'],
      packageId: json['package_id'],
      gameUserId: json['game_user_id'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      referenceId: json['reference_id'],
      paymentMethod: json['payment_method'],
      paymentDetails: json['payment_details'],
      gameUsername: json['game_username'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      package: json['package'] != null ? GamePackage.fromJson(json['package']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_id': gameId,
      'package_id': packageId,
      'game_user_id': gameUserId,
      'amount': amount,
      'status': status,
      'reference_id': referenceId,
      'payment_method': paymentMethod,
      'payment_details': paymentDetails,
      'game_username': gameUsername,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Status constants
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_PROCESSING = 'processing';
  static const String STATUS_SUCCESS = 'success';
  static const String STATUS_FAILED = 'failed';
  static const String STATUS_CANCELLED = 'cancelled';
  static const String STATUS_REFUNDED = 'refunded';

  // Helper methods to check status
  bool get isPending => status == STATUS_PENDING;
  bool get isProcessing => status == STATUS_PROCESSING;
  bool get isSuccess => status == STATUS_SUCCESS;
  bool get isFailed => status == STATUS_FAILED;
  bool get isCancelled => status == STATUS_CANCELLED;
  bool get isRefunded => status == STATUS_REFUNDED;

  // Get status color
  String get statusColorHex {
    switch (status) {
      case STATUS_PENDING:
        return '#FFA000'; // Orange
      case STATUS_PROCESSING:
        return '#2196F3'; // Blue
      case STATUS_SUCCESS:
        return '#4CAF50'; // Green
      case STATUS_FAILED:
        return '#F44336'; // Red
      case STATUS_CANCELLED:
        return '#9E9E9E'; // Grey
      case STATUS_REFUNDED:
        return '#9C27B0'; // Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get formatted status text
  String get statusText {
    switch (status) {
      case STATUS_PENDING:
        return 'Menunggu Pembayaran';
      case STATUS_PROCESSING:
        return 'Diproses';
      case STATUS_SUCCESS:
        return 'Berhasil';
      case STATUS_FAILED:
        return 'Gagal';
      case STATUS_CANCELLED:
        return 'Dibatalkan';
      case STATUS_REFUNDED:
        return 'Dikembalikan';
      default:
        return 'Unknown';
    }
  }

  // Get formatted date
  String get formattedDate {
    if (createdAt == null) return '-';
    return createdAt!.substring(0, 10); // Simple date format (yyyy-mm-dd)
  }

  // Get formatted amount
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
}