import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-key-change-in-production")
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL",
        f"sqlite:///{os.path.join(BASE_DIR, '..', 'marketplace.db')}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_SORT_KEYS = False

    RABBITMQ_HOST = os.environ.get("RABBITMQ_HOST", "rabbitmq")
    RABBITMQ_PORT = int(os.environ.get("RABBITMQ_PORT", 5672))
    RABBITMQ_USER = os.environ.get("RABBITMQ_USER", "guest")
    RABBITMQ_PASS = os.environ.get("RABBITMQ_PASS", "guest")


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
