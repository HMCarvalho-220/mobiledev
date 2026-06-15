from flask import Flask
from .config import Config
from .database import db
from .routes import register_routes
from flask_cors import CORS


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    CORS(app)

    db.init_app(app)

    with app.app_context():
        db.create_all()

    register_routes(app)

    return app
