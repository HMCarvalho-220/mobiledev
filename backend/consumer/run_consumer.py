import json
import pika
import time

RABBITMQ_URL = "amqps://hdvxqmmy:3LY-FY59v4IhzLJqP8x2dQGlPgd9Teej@jaragua.lmq.cloudamqp.com/hdvxqmmy"


def callback(ch, method, properties, body):
    try:
        data = json.loads(body)

        print("\nEvento recebido:")
        print(json.dumps(data, indent=2))

        ch.basic_ack(
            delivery_tag=method.delivery_tag
        )

    except Exception as e:
        print(f"Erro ao processar mensagem: {e}")

        ch.basic_nack(
            delivery_tag=method.delivery_tag,
            requeue=False
        )


def start_consumer():
    while True:
        try:
            print("Tentando conectar ao RabbitMQ...")

            params = pika.URLParameters(
                RABBITMQ_URL
            )

            connection = pika.BlockingConnection(
                params
            )

            channel = connection.channel()

            filas = [
                "order.created",
                "order.status_updated",
                "product.sold_out"
            ]

            for fila in filas:
                channel.queue_declare(
                    queue=fila,
                    durable=True
                )

                channel.basic_consume(
                    queue=fila,
                    on_message_callback=callback
                )

            print("Consumer conectado!")
            print("Aguardando mensagens...\n")

            channel.start_consuming()

        except Exception as e:
            print(f"Erro de conexão: {e}")
            print("Tentando novamente em 5 segundos...\n")

            time.sleep(5)


if __name__ == "__main__":
    start_consumer()