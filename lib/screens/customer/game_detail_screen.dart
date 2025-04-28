import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/services/game_service.dart';
import 'package:paydiddy/screens/customer/top_up_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:paydiddy/models/game_package.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;
  final String gameName;
  final String? gameImage;

  const GameDetailScreen({
    Key? key,
    required this.gameId,
    required this.gameName,
    this.gameImage,
  }) : super(key: key);

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final GameService _gameService = GameService();
  bool _isLoading = true;
  Game? _game;
  List<GamePackage> _packages = [];
  String _error = '';

  // Controller untuk ID game
  final _gameUserIdController = TextEditingController();
  final _gameUsernameController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String _verifiedUsername = '';

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  @override
  void dispose() {
    _gameUserIdController.dispose();
    _gameUsernameController.dispose();
    super.dispose();
  }

  _loadGameData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Mendapatkan detail game
      final game = await _gameService.getGameById(widget.gameId);

      // Mendapatkan paket game
      final packages = await _gameService.getGamePackages(widget.gameId);

      setState(() {
        _game = game;
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  _verifyGameId() async {
    if (_gameUserIdController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'ID Game tidak boleh kosong',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _verifiedUsername = '';
    });

    try {
      final result = await _gameService.verifyGameId(
        widget.gameId,
        _gameUserIdController.text,
      );

      setState(() {
        _isVerifying = false;
        _isVerified = result['verified'] ?? false;
        _verifiedUsername = result['username'] ?? '';

        if (_isVerified && _verifiedUsername.isNotEmpty) {
          _gameUsernameController.text = _verifiedUsername;
        }
      });

      if (_isVerified) {
        Fluttertoast.showToast(
          msg: 'ID Game berhasil diverifikasi',
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'ID Game tidak valid',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.gameName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGameData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Info
                  Row(
                    children: [
                      // Game Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          image: _game?.image != null && _game!.image.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(_game!.image),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _game?.image == null || _game!.image.isEmpty
                            ? Icon(
                          Icons.games,
                          color: Colors.blue[300],
                          size: 40,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Game Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _game?.name ?? widget.gameName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _game?.category ?? 'Game',
                              style: TextStyle(
                                color: Colors.blue[100],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Game Description
                  if (_game?.description != null && _game!.description.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _game!.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Game ID Form
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Akun Game',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Game ID Field
                  TextFormField(
                    controller: _gameUserIdController,
                    decoration: InputDecoration(
                      labelText: 'ID Game',
                      hintText: 'Masukkan ID game Anda',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: _isVerifying
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.check_circle),
                        color: _isVerified ? Colors.green : Colors.grey,
                        onPressed: _verifyGameId,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 12),

                  // Username Field
                  TextFormField(
                    controller: _gameUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Nama akun game Anda',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    enabled: !_isVerified, // Disable if verified
                  ),
                ],
              ),
            ),

            // Package List Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Nominal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Package Grid
                  _packages.isEmpty
                      ? const Center(
                    child: Text(
                      'Tidak ada paket tersedia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      return _buildPackageCard(package);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(GamePackage package) {
    return GestureDetector(
      onTap: () {
        if (_gameUserIdController.text.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Harap masukkan ID Game terlebih dahulu',
            backgroundColor: Colors.red,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopUpScreen(
              game: _game!,
              package: package,
              gameUserId: _gameUserIdController.text,
              gameUsername: _gameUsernameController.text,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
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
            // Denomination
            Text(
              package.denomination,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Price
            if (package.isPromo && package.discountPrice != null) ...[
              // Original Price (strikethrough)
              Text(
                'Rp ${package.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              // Discount Price
              Text(
                'Rp ${package.discountPrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              Text(
                'Rp ${package.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],

            // Promo Badge
            if (package.isPromo && package.formattedDiscount != null)
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Diskon ${package.formattedDiscount}',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}