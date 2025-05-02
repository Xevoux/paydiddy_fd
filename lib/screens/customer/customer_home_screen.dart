import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/providers/game_provider.dart';
import 'package:paydiddy/screens/auth/login_screen.dart';
import 'package:paydiddy/screens/customer/game_detail_screen.dart';
import 'package:paydiddy/screens/customer/game_list_screen.dart';
import 'package:paydiddy/screens/customer/transaction_history_screen.dart';
import 'package:paydiddy/screens/customer/customer_settings_screen.dart';
import 'package:provider/provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _balance = "Rp 0";
  bool _isLoading = true;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _promoList = [
    {
      'title': 'Diskon 25% Mobile Legends',
      'desc': 'Top up diamond ML hemat!',
      'color': Colors.blue,
    },
    {
      'title': 'Cashback Genshin Impact',
      'desc': 'Cashback 10% untuk pembelian Genesis Crystal',
      'color': Colors.teal,
    },
    {
      'title': 'Bonus Free Fire',
      'desc': 'Beli Diamond Free Fire, dapatkan bonus 10%',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      // Load user data
      await userProvider.getUserProfile();

      // Load popular games
      await gameProvider.fetchPopularGames();

      // Load all games
      await gameProvider.fetchGames();

      // Simulated balance
      setState(() {
        _balance = "Rp 150.000";
      });
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _logout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (!mounted) return;

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

  // Method to navigate to game detail
  _navigateToGameDetail(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(
          gameId: game.id,
          gameName: game.name,
          gameImage: game.image,
        ),
      ),
    );
  }

  // Method to navigate to game list by category
  _navigateToGameList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameListScreen(
          category: category,
          title: category,
        ),
      ),
    );
  }

  // Method to navigate to transaction history
  _navigateToTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    final userName = userProvider.user?.name ?? "Customer";
    final popularGames = gameProvider.popularGames;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'PayDiddy',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // To be implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi akan diimplementasikan')),
              );
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
          await _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info and balance section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Halo, $userName!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.blue[900],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Anda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _balance,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // To be implemented
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Top Up Saldo akan diimplementasikan')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // Adjusted padding to prevent overflow
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text(
                              'Top Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12, // Reduced font size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          'Top Up',
                          Icons.attach_money,
                          Colors.green,
                              () {
                            // Navigate to game list screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameListScreen(
                                  title: 'Semua Game',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          'Riwayat',
                          Icons.history,
                          Colors.orange,
                          _navigateToTransactionHistory,
                        ),
                        _buildQuickAction(
                          'Customer Service',
                          Icons.headset_mic,
                          Colors.blue,
                              () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Customer Service akan diimplementasikan'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Promo Banner - Fixed height to prevent overflow
              Container(
                height: 200,
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Promo Spesial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _promoList.length,
                        itemBuilder: (context, index) {
                          final promo = _promoList[index];
                          return Container(
                            width: 280,
                            height: 160, // Tambahkan tinggi tetap
                            margin: const EdgeInsets.only(right: 16, bottom: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  promo['color'],
                                  promo['color'].withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // Decorative elements
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Positioned(
                                  left: -20,
                                  top: -20,
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),

                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16), // Kurangi padding
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Atur spacing
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promo['title'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4), // Kurangi spacing
                                          Text(
                                            promo['desc'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),

                                      // Action button
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Gunakan Sekarang',
                                            style: TextStyle(
                                              color: promo['color'],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Popular Games
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Game Populer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameListScreen(
                                  title: 'Semua Game',
                                ),
                              ),
                            );
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Popular Games Grid
                    popularGames.isEmpty
                        ? const Center(
                      child: Text(
                        'Tidak ada game tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8, // Adjusted for better proportions
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: popularGames.length > 4 ? 4 : popularGames.length,
                      itemBuilder: (context, index) {
                        final game = popularGames[index];
                        return _buildGameCard(game);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Game Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Game',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category List
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryCard('MOBA', Icons.sports_esports),
                          _buildCategoryCard('Battle Royale', Icons.filter_hdr),
                          _buildCategoryCard('RPG', Icons.emoji_events),
                          _buildCategoryCard('FPS', Icons.filter_center_focus),
                          _buildCategoryCard('Casual', Icons.extension),
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
              break;
            case 1: // Top Up - Navigate to game list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameListScreen(
                    title: 'Semua Game',
                  ),
                ),
              ).then((_) => setState(() => _currentIndex = 0)); // Reset to home after return
              break;
            case 2: // Transactions - Navigate to transaction history
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              ).then((_) => setState(() => _currentIndex = 0)); // Reset to home after return
              break;
            case 3: // Profile - Navigate to settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerSettingsScreen(),
                ),
              ).then((_) => setState(() => _currentIndex = 0)); // Reset to home after return
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

  Widget _buildQuickAction(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => _navigateToGameDetail(game),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: game.image.isNotEmpty
                    ? Image.network(
                  game.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholderImage();
                  },
                )
                    : _buildPlaceholderImage(),
              ),
            ),

            // Game info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Game name
                    Text(
                      game.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Game category
                    Text(
                      game.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Top up button with size constraints
                    SizedBox(
                      width: double.infinity,
                      height: 30, // Fixed height to prevent overflow
                      child: ElevatedButton(
                        onPressed: () => _navigateToGameDetail(game),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(30, 20), // Smaller minimum size
                        ),
                        child: const Text(
                          'Top Up',
                          style: TextStyle(
                            fontSize: 11, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, IconData icon) {
    return InkWell(
      onTap: () => _navigateToGameList(category),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue[900],
              size: 28, // Reduced size
            ),
            const SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13, // Reduced font size
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.videogame_asset,
          color: Colors.grey[400],
          size: 48,
        ),
      ),
    );
  }
}