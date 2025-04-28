import 'package:paydiddy/models/game_package.dart';

class Game {
  final int id;
  final String name;
  final String description;
  final String image;
  final String category;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      category: json['category'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}