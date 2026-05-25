import json
import pika
from flask import current_app


def publish_event(queue, payload):
    try:
        params = pika.URLParameters(
            current_app.config["RABBITMQ_URL"]
        )

        connection = pika.BlockingConnection(params)

        channel = connection.channel()

        channel.queue_declare(
            queue=queue,
            durable=True
        )

        channel.basic_publish(
            exchange='',
            routing_key=queue,
            body=json.dumps(payload),
            properties=pika.BasicProperties(
                delivery_mode=2
            )
        )

        connection.close()

        print(f"Evento enviado: {queue}")

    except Exception as e:
        print(f"Erro RabbitMQ: {e}")