import 'package:flutter/material.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/providers/transaction_provider.dart';
import 'package:paydiddy/screens/auth/login_screen.dart';
import 'package:paydiddy/config/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isLoading = true;
  bool _isLoadingStats = true;
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalTransactions': 0,
    'totalRevenue': 0,
    'popularGame': '',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
    _loadRecentTransactions();
  }

  _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserProfile();
    } catch (e) {
      // Handle error silently or show a small notification
      print("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _loadStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final statistics = await transactionProvider.getTransactionStatistics();

      setState(() {
        _stats = {
          'totalUsers': statistics['total_users'] ?? 0,
          'totalTransactions': statistics['total_transactions'] ?? 0,
          'totalRevenue': statistics['total_revenue'] ?? 0,
          'popularGame': statistics['popular_games']?.isNotEmpty ?
          statistics['popular_games'][0]['game_name'] : 'N/A',
        };
      });
    } catch (e) {
      print("Error loading stats: $e");
      // Fallback to default statistics on error
      setState(() {
        _stats = {
          'totalUsers': 0,
          'totalTransactions': 0,
          'totalRevenue': 0,
          'popularGame': 'N/A',
        };
      });
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  _loadRecentTransactions() async {
    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchAllTransactions();
    } catch (e) {
      print("Error loading transactions: $e");
    }
  }

  _logout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (!mounted) return;

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _openWebAdmin(String section) async {
    final url = 'https://admin.paydiddy.com/$section';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userName = userProvider.user?.name ?? "Admin";
    final recentTransactions = transactionProvider.allTransactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              AppRoutes.navigateToAdminSettings(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _loadStats();
          await _loadRecentTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[100],
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Admin PayDiddy',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Row of Stats
              _isLoadingStats
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        'Total Users',
                        _stats['totalUsers'].toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Transaksi',
                        _stats['totalTransactions'].toString(),
                        Icons.payment,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        'Pendapatan',
                        'Rp ${(_stats['totalRevenue'] / 1000000).toStringAsFixed(1)}jt',
                        Icons.monetization_on,
                        Colors.amber,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Game Populer',
                        _stats['popularGame'],
                        Icons.games,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Admin Menu
              const Text(
                'Menu Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Menu Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard('Kelola Game', Icons.games, () {
                    _openWebAdmin('games');
                  }),
                  _buildMenuCard('Transaksi', Icons.receipt_long, () {
                    AppRoutes.navigateToAdminTransactionManagement(context);
                  }),
                  _buildMenuCard('Pengaturan', Icons.settings, () {
                    AppRoutes.navigateToAdminSettings(context);
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      AppRoutes.navigateToAdminTransactionManagement(context);
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Transaction List
              transactionProvider.isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : recentTransactions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.receipt, color: Colors.blue),
                      ),
                      title: Text(transaction.referenceId),
                      subtitle: Text(
                        '${transaction.game?.name ?? 'Unknown'} - ${transaction.package?.name ?? 'Unknown'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(transaction.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              transaction.statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(transaction.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showTransactionDetails(transaction);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
                _confirmCancelTransaction(transaction);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Batalkan Transaksi'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppRoutes.navigateToAdminTransactionManagement(context);
            },
            child: const Text('Lihat di Manajemen Transaksi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelTransaction(Transaction transaction) {
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
                await _loadRecentTransactions();
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue[900],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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