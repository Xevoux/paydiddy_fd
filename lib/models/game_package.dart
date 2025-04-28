class GamePackage {
  final int id;
  final int gameId;
  final String name;
  final String description;
  final double price;
  final String denomination;
  final bool isPromo;
  final double? discountPrice;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  GamePackage({
    required this.id,
    required this.gameId,
    required this.name,
    required this.description,
    required this.price,
    required this.denomination,
    required this.isPromo,
    this.discountPrice,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory GamePackage.fromJson(Map<String, dynamic> json) {
    return GamePackage(
      id: json['id'],
      gameId: json['game_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      denomination: json['denomination'],
      isPromo: json['is_promo'] == 1,
      discountPrice: json['discount_price'] != null ? double.parse(json['discount_price'].toString()) : null,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'name': name,
      'description': description,
      'price': price,
      'denomination': denomination,
      'is_promo': isPromo ? 1 : 0,
      'discount_price': discountPrice,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Calculate final price (with discount if applicable)
  double get finalPrice => isPromo && discountPrice != null ? discountPrice! : price;

  // Calculate discount percentage if applicable
  double? get discountPercentage {
    if (isPromo && discountPrice != null && price > 0) {
      return ((price - discountPrice!) / price) * 100;
    }
    return null;
  }

  // Format discount percentage as string
  String? get formattedDiscount {
    final percentage = discountPercentage;
    if (percentage != null) {
      return '${percentage.toStringAsFixed(0)}%';
    }
    return null;
  }
}