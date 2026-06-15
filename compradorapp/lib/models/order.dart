// models/order.dart
//
// Espelho da tabela 'orders' do backend.

class Order {
  final int id;
  final int buyerId;
  final int productId;
  final String productTitle;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.productTitle,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id:           json['id'] as int,
      buyerId:      json['buyer_id'] as int,
      productId:    json['product_id'] as int,
      productTitle: json['product_title'] ?? 'Produto',
      quantity:     json['quantity'] as int,
      unitPrice:    (json['unit_price'] as num).toDouble(),
      totalPrice:   (json['total_price'] as num).toDouble(),
      status:       json['status'] as String,
      createdAt:    DateTime.parse(json['created_at'] as String),
      updatedAt:    DateTime.parse(json['updated_at'] as String),
    );
  }

  // Label e cor para exibir o status na UI
  String get statusLabel {
    const labels = {
      'pending':   'Aguardando confirmação',
      'confirmed': 'Confirmado',
      'shipped':   'Despachado',
      'delivered': 'Entregue',
      'cancelled': 'Cancelado',
    };
    return labels[status] ?? status;
  }

  // Retorna uma cópia do pedido com status atualizado
  // (usado pelo polling quando detecta mudança)
  Order copyWith({String? status, DateTime? updatedAt}) {
    return Order(
      id:           id,
      buyerId:      buyerId,
      productId:    productId,
      productTitle: productTitle,
      quantity:     quantity,
      unitPrice:    unitPrice,
      totalPrice:   totalPrice,
      status:       status ?? this.status,
      createdAt:    createdAt,
      updatedAt:    updatedAt ?? this.updatedAt,
    );
  }
}
