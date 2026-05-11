from flask import request, jsonify
from ..services import UserService, ProductService, OrderService

user_service = UserService()
product_service = ProductService()
order_service = OrderService()



def register_user():
    data = request.get_json(silent=True) or {}
    try:
        user = user_service.register_user(data)
        return jsonify({"status": "success", "data": user.to_dict()}), 201
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": "Erro interno"}), 500


def get_user(user_id):
    try:
        user = user_service.get_user(user_id)
        return jsonify({"status": "success", "data": user.to_dict()}), 200
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def list_users():
    users = user_service.list_users()
    return jsonify({"status": "success", "data": [u.to_dict() for u in users]}), 200


def create_product():
    data = request.get_json(silent=True) or {}
    try:
        product = product_service.create_product(data)
        return jsonify({"status": "success", "data": product.to_dict()}), 201
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def get_product(product_id):
    try:
        product = product_service.get_product(product_id)
        return jsonify({"status": "success", "data": product.to_dict()}), 200
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def list_products():
    seller_id = request.args.get("seller_id", type=int)
    try:
        if seller_id:
            products = product_service.list_products_by_seller(seller_id)
        else:
            products = product_service.list_active_products()
        return jsonify({"status": "success", "data": [p.to_dict() for p in products]}), 200
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def update_product(product_id):
    data = request.get_json(silent=True) or {}
    try:
        product = product_service.update_product(product_id, data)
        return jsonify({"status": "success", "data": product.to_dict()}), 200
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404



def create_order():
    data = request.get_json(silent=True) or {}
    try:
        order = order_service.create_order(data)
        return jsonify({"status": "success", "data": order.to_dict()}), 201
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def get_order(order_id):
    try:
        order = order_service.get_order(order_id)
        return jsonify({"status": "success", "data": order.to_dict()}), 200
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def list_orders():
    buyer_id = request.args.get("buyer_id", type=int)
    try:
        if buyer_id:
            orders = order_service.list_orders_by_buyer(buyer_id)
        else:
            orders = order_service.list_all_orders()
        return jsonify({"status": "success", "data": [o.to_dict() for o in orders]}), 200
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404


def update_order_status(order_id):
    data = request.get_json(silent=True) or {}
    new_status = data.get("status")
    if not new_status:
        return jsonify({"status": "error", "message": "Campo 'status' obrigatorio"}), 400
    try:
        order = order_service.update_order_status(order_id, new_status)
        return jsonify({"status": "success", "data": order.to_dict()}), 200
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except LookupError as e:
        return jsonify({"status": "error", "message": str(e)}), 404
