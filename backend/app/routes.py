from flask import Blueprint
from .controllers import (
    register_user, get_user, list_users,
    create_product, get_product, list_products, update_product,
    create_order, get_order, list_orders, update_order_status
)

api = Blueprint("api", __name__, url_prefix="/api/v1")

# Users
api.add_url_rule("/users", view_func=register_user, methods=["POST"])
api.add_url_rule("/users", view_func=list_users, methods=["GET"])
api.add_url_rule("/users/<int:user_id>", view_func=get_user, methods=["GET"])

# Products
api.add_url_rule("/products", view_func=create_product, methods=["POST"])
api.add_url_rule("/products", view_func=list_products, methods=["GET"])
api.add_url_rule("/products/<int:product_id>", view_func=get_product, methods=["GET"])
api.add_url_rule("/products/<int:product_id>", view_func=update_product, methods=["PATCH"])

# Orders
api.add_url_rule("/orders", view_func=create_order, methods=["POST"])
api.add_url_rule("/orders", view_func=list_orders, methods=["GET"])
api.add_url_rule("/orders/<int:order_id>", view_func=get_order, methods=["GET"])
api.add_url_rule("/orders/<int:order_id>/status", view_func=update_order_status, methods=["PATCH"])


def register_routes(app):
    app.register_blueprint(api)

    @app.route("/health")
    def health():
        from flask import jsonify
        return jsonify({"status": "ok", "service": "Marketplace API v1"}), 200
