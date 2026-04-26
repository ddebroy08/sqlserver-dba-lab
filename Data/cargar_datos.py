import pypyodbc as odbc
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker('es_ES')

DRIVER_NAME = 'ODBC Driver 17 for SQL Server'
SERVER_NAME = r'DESKTOP-91F9CRE\SQLEXPRESS'
DATABASE_NAME = 'nexoshop'

connection_string = f"""
    DRIVER={{{DRIVER_NAME}}};
    SERVER={SERVER_NAME};
    DATABASE={DATABASE_NAME};
    Trusted_Connection=yes;
"""

# -----------------------------
# CONEXIÓN
# -----------------------------
def get_connection():
    return odbc.connect(connection_string)

# -----------------------------
# FECHAS ALEATORIAS
# -----------------------------
def random_date():
    start = datetime(2015, 11, 1)
    end = datetime(2026, 1, 1)

    delta = end - start
    random_days = random.randint(0, delta.days)

    return start + timedelta(days=random_days)

# -----------------------------
# SUCURSALES
# -----------------------------
def seed_sucursales(n):
    conn = get_connection()
    cursor = conn.cursor()

    ids = []

    for i in range(1, n + 1):
        cursor.execute("""
            INSERT INTO sucursal (id_sucursal, nombre, direccion, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
        """, (
            i,
            fake.company(),
            fake.address(),
            random_date(),
            None
        ))
        ids.append(i)

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Sucursales insertadas: {n}")
    return ids

# -----------------------------
# CLIENTES
# -----------------------------
def seed_clientes(n):
    conn = get_connection()
    cursor = conn.cursor()

    ids = []

    for i in range(1, n + 1):
        cursor.execute("""
            INSERT INTO cliente (id_cliente, nombre, apellido, correo, cui, nit, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            i,
            fake.first_name(),
            fake.last_name(),
            fake.email(),
            str(fake.random_number(digits=13)),
            str(fake.random_number(digits=8)),
            random_date(),
            None
        ))
        ids.append(i)

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Clientes insertados: {n}")
    return ids

# -----------------------------
# USUARIOS
# -----------------------------
def seed_usuarios(n, sucursales):
    conn = get_connection()
    cursor = conn.cursor()

    ids = []

    for i in range(1, n + 1):
        cursor.execute("""
            INSERT INTO usuario (id_usuario, id_sucursal, nombre, apellido, correo, cui, nit, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            i,
            random.choice(sucursales),
            fake.first_name(),
            fake.last_name(),
            fake.email(),
            str(fake.random_number(digits=13)),
            str(fake.random_number(digits=8)),
            random_date(),
            None
        ))
        ids.append(i)

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Usuarios insertados: {n}")
    return ids

# -----------------------------
# PRODUCTOS
# -----------------------------
def seed_productos(n, sucursales):
    conn = get_connection()
    cursor = conn.cursor()

    ids = []

    categorias = {
        "Electronics": ["Laptop", "Mouse", "Keyboard", "Monitor", "Headphones"],
        "Home": ["Chair", "Table", "Lamp", "Sofa", "Desk"],
        "Clothing": ["Shirt", "Pants", "Jacket", "Shoes"],
        "Food": ["Milk", "Bread", "Cheese", "Juice"]
    }

    adjetivos = ["Pro", "Ultra", "Max", "Lite", "Smart", "Advanced", "Portable"]

    for i in range(1, n + 1):
        categoria = random.choice(list(categorias.keys()))
        base = random.choice(categorias[categoria])

        nombre = f"{random.choice(adjetivos)} {base}"
        descripcion = fake.text(max_nb_chars=120)

        cursor.execute("""
            INSERT INTO producto (
                id_producto, id_sucursal, nombre, descripcion, categoria, fecha_caducida, created_at, updated_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            i,
            random.choice(sucursales),
            nombre,
            descripcion,
            categoria,
            fake.date_this_year(),
            random_date(),
            None
        ))

        ids.append(i)

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Productos insertados: {n}")
    return ids

# -----------------------------
# VENTAS
# -----------------------------
def seed_ventas(n, usuarios, sucursales):
    conn = get_connection()
    cursor = conn.cursor()

    ids = []

    for i in range(1, n + 1):
        cursor.execute("""
            INSERT INTO venta (id_venta, id_usuario, id_sucursal, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
        """, (
            i,
            random.choice(usuarios),
            random.choice(sucursales),
            random_date(),
            None
        ))
        ids.append(i)

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Ventas insertadas: {n}")
    return ids

# -----------------------------
# DETALLE VENTA
# -----------------------------
def seed_detalle_venta(n, ventas, productos):
    conn = get_connection()
    cursor = conn.cursor()

    for i in range(1, n + 1):
        cursor.execute("""
            INSERT INTO detalle_venta (
                id_detalle, id_venta, id_producto, cantidad, precio, created_at, updated_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            i,
            random.choice(ventas),
            random.choice(productos),
            random.randint(1, 5),
            round(random.uniform(5, 500), 2),
            random_date(),
            None
        ))

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Detalle venta insertado: {n}")

# -----------------------------
# EJECUCIÓN FINAL
# -----------------------------
sucursales = seed_sucursales(5)
clientes = seed_clientes(1000)
usuarios = seed_usuarios(100, sucursales)
productos = seed_productos(1000, sucursales)
ventas = seed_ventas(100000, usuarios, sucursales)
seed_detalle_venta(500000, ventas, productos)