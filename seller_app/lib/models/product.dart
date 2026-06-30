// models/product.dart

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String status;
  final int sellerId;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.status,
    required this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:          json['id'] as int,
      title:       json['title'] as String,
      description: json['description'] ?? '',
      price:       (json['price'] as num).toDouble(),
      stock:       json['stock'] as int,
      status:      json['status'] as String,
      sellerId:    json['seller_id'] as int,
    );
  }
}
