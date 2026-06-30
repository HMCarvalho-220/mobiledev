class Order {
  final int id;
  final int buyerId;
  final String? buyerName;
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
    this.buyerName,
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
      buyerName:    json['buyer_name'] as String?,
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

  String get statusLabel {
    const Map<String, String> labels = {
      'pending':   'Aguardando confirmação',
      'confirmed': 'Confirmado',
      'shipped':   'Despachado',
      'delivered': 'Entregue',
      'cancelled': 'Cancelado',
    };
    return labels[status] ?? status;
  }

  List<String> get nextStatuses {
    const Map<String, List<String>> transitions = {
      'pending':   ['confirmed', 'cancelled'],
      'confirmed': ['shipped', 'cancelled'],
      'shipped':   ['delivered'],
      'delivered': [],
      'cancelled': [],
    };
    return transitions[status] ?? <String>[];
  }

  String labelFor(String status) {
    const Map<String, String> labels = {
      'confirmed': 'Confirmar pedido',
      'shipped':   'Marcar como despachado',
      'delivered': 'Marcar como entregue',
      'cancelled': 'Cancelar pedido',
    };
    return labels[status] ?? status;
  }
}