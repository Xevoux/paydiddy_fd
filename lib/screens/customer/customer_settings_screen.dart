import 'package:flutter/material.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/screens/auth/login_screen.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:paydiddy/screens/customer/game_list_screen.dart';
import 'package:paydiddy/screens/customer/transaction_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paydiddy/utils/constants.dart';
import 'package:paydiddy/utils/validators.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  String _appVersion = '';
  bool _isLoading = false;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Logout failed: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isChangingPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ubah Password'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Password Saat Ini',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password saat ini tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Password Baru',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              if (isChangingPassword)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isChangingPassword = true;
                      });

                      try {
                        final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false
                        );

                        await userProvider.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                          confirmPassword: confirmPasswordController.text,
                        );

                        Fluttertoast.showToast(
                          msg: 'Password berhasil diubah',
                          backgroundColor: Colors.green,
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: 'Gagal mengubah password: $e',
                          backgroundColor: Colors.red,
                        );

                        setState(() {
                          isChangingPassword = false;
                        });
                      }
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      color: Colors.blue[900],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Email',
                          style: TextStyle(
                            color: Colors.blue[100],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Sections
            const Text(
              'Pengaturan Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.person,
              iconColor: Colors.blue,
              title: 'Edit Profil',
              subtitle: 'Ubah informasi pribadi Anda',
              onTap: () {
                Navigator.pushNamed(context, '/customer/edit-profile');
              },
            ),
            _buildSettingCard(
              icon: Icons.notifications,
              iconColor: Colors.orange,
              title: 'Notifikasi',
              subtitle: 'Atur preferensi notifikasi',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Fitur Notifikasi akan diimplementasikan',
                  backgroundColor: Colors.blue,
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.payment,
              iconColor: Colors.green,
              title: 'Metode Pembayaran',
              subtitle: 'Kelola metode pembayaran Anda',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Fitur Metode Pembayaran akan diimplementasikan',
                  backgroundColor: Colors.blue,
                );
              },
            ),
            _buildSettingCard(
              icon: Icons.lock,
              iconColor: Colors.purple,
              title: 'Ubah Password',
              subtitle: 'Perbarui password Anda',
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Lainnya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.info,
              iconColor: Colors.teal,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi $_appVersion',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'PayDiddy',
                  applicationVersion: _appVersion,
                  applicationIcon: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'PD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  children: [
                    const Text(
                      'PayDiddy adalah aplikasi top up game yang cepat, mudah, dan aman. Nikmati berbagai promo menarik dan layanan pelanggan yang responsif.',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _logout,
                icon: _isLoading
                    ? Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.logout),
                label: Text(_isLoading ? 'Logging out...' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on index
          switch (index) {
            case 0: // Home - Already on home
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerHomeScreen(),
                ),
              ).then((_) => setState(() => _currentIndex = 3));
              break;
            case 1: // Top Up - Navigate to game list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameListScreen(
                    title: 'Semua Game',
                  ),
                ),
              ).then((_) => setState(() => _currentIndex = 3));
              break;
            case 2: // Transactions - Navigate to transaction history
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              ).then((_) => setState(() => _currentIndex = 3));
              break;
            case 3: // Profile - Already on settings
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Top Up'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}