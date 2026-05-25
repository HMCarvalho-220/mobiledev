import os

BASE_DIR = os.path.abspath(
    os.path.dirname(__file__)
)


class Config:
    SECRET_KEY = os.environ.get(
        "SECRET_KEY",
        "dev-secret-key-change-in-production"
    )

    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL",
        f"sqlite:///{os.path.join(BASE_DIR, '..', 'marketplace.db')}"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_SORT_KEYS = False

    RABBITMQ_URL = os.environ.get(
        "RABBITMQ_URL",
        "amqps://hdvxqmmy:3LY-FY59v4IhzLJqP8x2dQGlPgd9Teej@jaragua.lmq.cloudamqp.com/hdvxqmmy"
    )


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"