from ..repositories import (
    UserRepository,
    ProductRepository,
    OrderRepository
)

from ..messaging.publisher import publish_event


class UserService:
    def __init__(self):
        self.repo = UserRepository()

    def register_user(self, data: dict):
        required = ["name", "email", "role"]

        for field in required:
            if not data.get(field):
                raise ValueError(
                    f"Campo obrigatorio ausente: {field}"
                )

        if data["role"] not in ("buyer", "seller"):
            raise ValueError(
                "Role deve ser 'buyer' ou 'seller'"
            )

        if self.repo.find_by_email(data["email"]):
            raise ValueError("Email ja cadastrado")

        return self.repo.create(
            name=data["name"],
            email=data["email"],
            role=data["role"]
        )

    def get_user(self, user_id: int):
        user = self.repo.find_by_id(user_id)

        if not user:
            raise LookupError(
                f"Usuario {user_id} nao encontrado"
            )

        return user

    def list_users(self):
        return self.repo.find_all()


class ProductService:
    def __init__(self):
        self.repo = ProductRepository()
        self.user_repo = UserRepository()

    def create_product(self, data: dict):
        required = ["title", "price", "seller_id"]

        for field in required:
            if data.get(field) is None:
                raise ValueError(
                    f"Campo obrigatorio ausente: {field}"
                )

        if data["price"] <= 0:
            raise ValueError(
                "Preco deve ser positivo"
            )

        stock = data.get("stock", 1)

        if stock < 0:
            raise ValueError(
                "Estoque nao pode ser negativo"
            )

        seller = self.user_repo.find_by_id(
            data["seller_id"]
        )

        if not seller:
            raise LookupError(
                "Vendedor nao encontrado"
            )

        if seller.role != "seller":
            raise ValueError(
                "Usuario nao e um vendedor"
            )

        return self.repo.create(
            title=data["title"],
            description=data.get("description", ""),
            price=data["price"],
            stock=stock,
            seller_id=data["seller_id"]
        )

    def get_product(self, product_id: int):
        product = self.repo.find_by_id(product_id)

        if not product:
            raise LookupError(
                f"Produto {product_id} nao encontrado"
            )

        return product

    def list_active_products(self):
        return self.repo.find_all_active()

    def list_products_by_seller(self, seller_id: int):
        seller = self.user_repo.find_by_id(
            seller_id
        )

        if not seller:
            raise LookupError(
                "Vendedor nao encontrado"
            )

        return self.repo.find_by_seller(
            seller_id
        )

    def update_product(self, product_id: int, data: dict):
        product = self.get_product(product_id)

        allowed_fields = [
            "title",
            "description",
            "price",
            "stock",
            "status"
        ]

        valid_statuses = {
            "active",
            "sold_out",
            "inactive"
        }

        for field, value in data.items():
            if field not in allowed_fields:
                continue

            if field == "status" and value not in valid_statuses:
                raise ValueError(
                    f"Status invalido: {value}"
                )

            if field == "price" and value <= 0:
                raise ValueError(
                    "Preco deve ser positivo"
                )

            setattr(product, field, value)

        return self.repo.save(product)


class OrderService:
    VALID_TRANSITIONS = {
        "pending": {"confirmed", "cancelled"},
        "confirmed": {"shipped", "cancelled"},
        "shipped": {"delivered"},
        "delivered": set(),
        "cancelled": set()
    }

    def __init__(self):
        self.repo = OrderRepository()
        self.product_repo = ProductRepository()
        self.user_repo = UserRepository()

    def create_order(self, data: dict):
        required = [
            "buyer_id",
            "product_id",
            "quantity"
        ]

        for field in required:
            if data.get(field) is None:
                raise ValueError(
                    f"Campo obrigatorio ausente: {field}"
                )

        quantity = data["quantity"]

        if quantity < 1:
            raise ValueError(
                "Quantidade minima e 1"
            )

        buyer = self.user_repo.find_by_id(
            data["buyer_id"]
        )

        if not buyer:
            raise LookupError(
                "Comprador nao encontrado"
            )

        if buyer.role != "buyer":
            raise ValueError(
                "Usuario nao e um comprador"
            )

        product = self.product_repo.find_by_id(
            data["product_id"]
        )

        if not product:
            raise LookupError(
                "Produto nao encontrado"
            )

        if product.status != "active":
            raise ValueError(
                "Produto nao disponivel para compra"
            )

        if product.stock < quantity:
            raise ValueError(
                f"Estoque insuficiente. Disponivel: {product.stock}"
            )

        order = self.repo.create(
            buyer_id=buyer.id,
            product_id=product.id,
            quantity=quantity,
            unit_price=product.price
        )

        self.product_repo.update_stock(
            product,
            quantity
        )

        publish_event(
            "order.created",
            {
                "event": "order.created",
                "data": {
                    "order_id": order.id,
                    "buyer_id": buyer.id,
                    "product_id": product.id,
                    "quantity": quantity,
                    "status": order.status
                }
            }
        )

        updated_product = self.product_repo.find_by_id(
            product.id
        )

        if updated_product.stock == 0:
            publish_event(
                "product.sold_out",
                {
                    "event": "product.sold_out",
                    "data": {
                        "product_id": updated_product.id,
                        "title": updated_product.title
                    }
                }
            )

        return order

    def get_order(self, order_id: int):
        order = self.repo.find_by_id(order_id)

        if not order:
            raise LookupError(
                f"Pedido {order_id} nao encontrado"
            )

        return order

    def list_orders_by_buyer(self, buyer_id: int):
        buyer = self.user_repo.find_by_id(
            buyer_id
        )

        if not buyer:
            raise LookupError(
                "Comprador nao encontrado"
            )

        return self.repo.find_by_buyer(
            buyer_id
        )

    def update_order_status(
        self,
        order_id: int,
        new_status: str
    ):
        order = self.get_order(order_id)

        allowed = self.VALID_TRANSITIONS.get(
            order.status,
            set()
        )

        if new_status not in allowed:
            raise ValueError(
                f"Transicao invalida: "
                f"'{order.status}' -> '{new_status}'. "
                f"Permitido: {list(allowed) or 'nenhum'}"
            )

        previous_status = order.status

        updated_order = self.repo.update_status(
            order,
            new_status
        )

        publish_event(
            "order.status_updated",
            {
                "event": "order.status_updated",
                "data": {
                    "order_id": order.id,
                    "previous_status": previous_status,
                    "new_status": new_status
                }
            }
        )

        return updated_order

    def list_all_orders(self):
        return self.repo.find_all()