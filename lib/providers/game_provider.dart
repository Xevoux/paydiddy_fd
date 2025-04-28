import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/services/game_service.dart';
import '../models/game_package.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  List<Game> _games = [];
  List<Game> _popularGames = [];
  Game? _selectedGame;
  List<GamePackage> _packages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Game> get games => _games;
  List<Game> get popularGames => _popularGames;
  Game? get selectedGame => _selectedGame;
  List<GamePackage> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all games
  Future<void> fetchGames() async {
    _setLoading(true);
    _clearError();

    try {
      final games = await _gameService.getGames();
      _games = games;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch popular games
  Future<void> fetchPopularGames() async {
    _setLoading(true);
    _clearError();

    try {
      final games = await _gameService.getPopularGames();
      _popularGames = games;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch games by category
  Future<List<Game>> fetchGamesByCategory(String category) async {
    _setLoading(true);
    _clearError();

    try {
      final games = await _gameService.getGamesByCategory(category);
      return games;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Fetch game details
  Future<void> fetchGameDetails(int gameId) async {
    _setLoading(true);
    _clearError();

    try {
      final game = await _gameService.getGameById(gameId);
      _selectedGame = game;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch game packages
  Future<void> fetchGamePackages(int gameId) async {
    _setLoading(true);
    _clearError();

    try {
      final packages = await _gameService.getGamePackages(gameId);
      _packages = packages;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search games
  Future<List<Game>> searchGames(String keyword) async {
    _setLoading(true);
    _clearError();

    try {
      final games = await _gameService.searchGames(keyword);
      return games;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Verify game ID
  Future<Map<String, dynamic>> verifyGameId(int gameId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _gameService.verifyGameId(gameId, userId);
      return result;
    } catch (e) {
      _setError(e.toString());
      return {'verified': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
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

  // Clear selected game
  void clearSelectedGame() {
    _selectedGame = null;
    _packages = [];
    notifyListeners();
  }
}