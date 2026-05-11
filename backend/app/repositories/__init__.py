from ..database import db
from ..models import User, Product, Order


class UserRepository:
    def create(self, name: str, email: str, role: str) -> User:
        user = User(name=name, email=email, role=role)
        db.session.add(user)
        db.session.commit()
        return user

    def find_by_id(self, user_id: int):
        return db.session.get(User, user_id)

    def find_by_email(self, email: str):
        return User.query.filter_by(email=email).first()

    def find_all(self):
        return User.query.all()


class ProductRepository:
    def create(self, title: str, description: str, price: float,
               stock: int, seller_id: int) -> Product:
        product = Product(
            title=title,
            description=description,
            price=price,
            stock=stock,
            seller_id=seller_id
        )
        db.session.add(product)
        db.session.commit()
        return product

    def find_by_id(self, product_id: int):
        return db.session.get(Product, product_id)

    def find_all_active(self):
        return Product.query.filter_by(status="active").all()

    def find_by_seller(self, seller_id: int):
        return Product.query.filter_by(seller_id=seller_id).all()

    def update_stock(self, product: Product, quantity: int):
        product.stock -= quantity
        if product.stock <= 0:
            product.stock = 0
            product.status = "sold_out"
        db.session.commit()
        return product

    def update_status(self, product: Product, status: str):
        product.status = status
        db.session.commit()
        return product

    def save(self, product: Product):
        db.session.commit()
        return product


class OrderRepository:
    def create(self, buyer_id: int, product_id: int,
               quantity: int, unit_price: float) -> Order:
        order = Order(
            buyer_id=buyer_id,
            product_id=product_id,
            quantity=quantity,
            unit_price=unit_price,
            total_price=unit_price * quantity
        )
        db.session.add(order)
        db.session.commit()
        return order

    def find_by_id(self, order_id: int):
        return db.session.get(Order, order_id)

    def find_by_buyer(self, buyer_id: int):
        return Order.query.filter_by(buyer_id=buyer_id).all()

    def find_by_product(self, product_id: int):
        return Order.query.filter_by(product_id=product_id).all()

    def update_status(self, order: Order, status: str):
        order.status = status
        db.session.commit()
        return order

    def find_all(self):
        return Order.query.all()
