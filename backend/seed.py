from app import create_app
from app.database import db
from app.models import User, Product

app = create_app()

with app.app_context():
    db.drop_all()
    
    db.create_all()

    buyer = User(
        name="Comprador Teste",
        email="comprador@email.com",
        role="buyer"
    )
    
    seller = User(
        name="Vendedor Teste",
        email="vendedor@email.com",
        role="seller"
    )
    
    db.session.add(buyer)
    db.session.add(seller)
    db.session.commit()

    products = [
        Product(
            title="Teclado Mecânico",
            description="Teclado mecânico switch blue",
            price=250.00,
            stock=3,
            seller_id=seller.id
        ),
        Product(
            title="Mouse Gamer",
            description="Mouse 10000 DPI RGB",
            price=120.50,
            stock=5,
            seller_id=seller.id
        ),
        Product(
            title="Monitor 24 Polegadas",
            description="Monitor IPS Full HD 75Hz",
            price=850.00,
            stock=4,
            seller_id=seller.id
        ),
        Product(
            title="Headset Bluetooth",
            description="Headset com cancelamento de ruído",
            price=340.00,
            stock=7,
            seller_id=seller.id
        )
    ]

    db.session.add_all(products)
    db.session.commit()

    print("Banco de dados recriado e populado com sucesso!")
    print(f"ID do Comprador: {buyer.id}")
    print(f"ID do Vendedor: {seller.id}")