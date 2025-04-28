import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/models/game_package.dart';
import 'package:paydiddy/utils/http_helper.dart';

class GameService {
  // Mendapatkan daftar game
  Future<List<Game>> getGames() async {
    final response = await HttpHelper.get('games');
    List<Game> games = [];

    for (var item in response['data']) {
      games.add(Game.fromJson(item));
    }

    return games;
  }

  // Mendapatkan detail game berdasarkan ID
  Future<Game> getGameById(int id) async {
    final response = await HttpHelper.get('games/$id');
    return Game.fromJson(response['data']);
  }

  // Mendapatkan paket game berdasarkan game ID
  Future<List<GamePackage>> getGamePackages(int gameId) async {
    final response = await HttpHelper.get('games/$gameId/packages');
    List<GamePackage> packages = [];

    for (var item in response['data']) {
      packages.add(GamePackage.fromJson(item));
    }

    return packages;
  }

  // Verifikasi ID Game (untuk form top up)
  Future<Map<String, dynamic>> verifyGameId(int gameId, String userId) async {
    final response = await HttpHelper.post('games/verify-id', {
      'game_id': gameId,
      'user_id': userId,
    });

    return {
      'verified': response['verified'] ?? false,
      'username': response['username'] ?? '',
      'message': response['message'] ?? '',
    };
  }

  // Mendapatkan daftar game berdasarkan kategori
  Future<List<Game>> getGamesByCategory(String category) async {
    final response = await HttpHelper.get('games/category/$category');
    List<Game> games = [];

    for (var item in response['data']) {
      games.add(Game.fromJson(item));
    }

    return games;
  }

  // Mendapatkan daftar game populer
  Future<List<Game>> getPopularGames() async {
    final response = await HttpHelper.get('games/popular');
    List<Game> games = [];

    for (var item in response['data']) {
      games.add(Game.fromJson(item));
    }

    return games;
  }

  // Pencarian game
  Future<List<Game>> searchGames(String keyword) async {
    final response = await HttpHelper.get('games/search?keyword=$keyword');
    List<Game> games = [];

    for (var item in response['data']) {
      games.add(Game.fromJson(item));
    }

    return games;
  }
}