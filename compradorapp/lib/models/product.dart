

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String status;
  final int sellerId;
  final String sellerName;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.status,
    required this.sellerId,
    required this.sellerName,
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
      sellerName:  json['seller_name'] ?? 'Desconhecido',
    );
  }

  bool get isAvailable => status == 'active' && stock > 0;
}
