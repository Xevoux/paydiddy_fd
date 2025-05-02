import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:paydiddy/screens/customer/customer_settings_screen.dart';
import 'package:paydiddy/screens/customer/transaction_history_screen.dart';
import 'package:paydiddy/services/game_service.dart';
import 'package:paydiddy/screens/customer/game_detail_screen.dart';

class GameListScreen extends StatefulWidget {
  final String? category;
  final String title;

  const GameListScreen({Key? key, this.category, this.title = 'Daftar Game'}) : super(key: key);

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final GameService _gameService = GameService();
  List<Game> _games = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Game> games;
      if (widget.category != null) {
        games = await _gameService.getGamesByCategory(widget.category!);
      } else {
        games = await _gameService.getGames();
      }

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  _searchGames(String keyword) async {
    if (keyword.trim().isEmpty) {
      _loadGames();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await _gameService.searchGames(keyword.trim());
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerHomeScreen(),
          ),
        ).then((_) => setState(() => _currentIndex = 1));
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionHistoryScreen(),
          ),
        ).then((_) => setState(() => _currentIndex = 1));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerSettingsScreen(),
          ),
        ).then((_) => setState(() => _currentIndex = 1));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari game...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _searchGames,
        )
            : Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _loadGames();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadGames, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, color: Colors.grey[400], size: 60),
            const SizedBox(height: 16),
            Text(_isSearching ? 'Tidak ada game yang ditemukan' : 'Belum ada game tersedia', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_isSearching && _searchController.text.isNotEmpty) {
          await _searchGames(_searchController.text);
        } else {
          await _loadGames();
        }
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _games.length,
        itemBuilder: (context, index) => _buildGameCard(_games[index]),
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameDetailScreen(
            gameId: game.id,
            gameName: game.name,
            gameImage: game.image,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: game.image.isNotEmpty
                    ? Image.network(
                  game.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                  loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                      ? child
                      : _buildPlaceholderImage(),
                )
                    : _buildPlaceholderImage(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                // Kurangi padding vertikal untuk menghemat ruang
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Gunakan mainAxisSize.min agar column tidak mengambil ruang berlebih
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Tambahkan ConstrainedBox untuk membatasi tinggi tombol
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 32),
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameDetailScreen(
                              gameId: game.id,
                              gameName: game.name,
                              gameImage: game.image,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Top Up',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.videogame_asset, color: Colors.grey[400], size: 48),
      ),
    );
  }
}