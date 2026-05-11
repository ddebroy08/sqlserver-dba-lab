CREATE DATABASE nexoshop;
GO

USE nexoshop;
GO

-- =========================
-- TABLA CLIENTE
-- =========================
CREATE TABLE cliente(
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(50),
    cui VARCHAR(50),
    nit VARCHAR(50),
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2
);

-- =========================
-- TABLA SUCURSAL
-- =========================
CREATE TABLE sucursal(
    id_sucursal INT PRIMARY KEY,
    nombre VARCHAR(75) NOT NULL,
    direccion VARCHAR(250),
    estado VARCHAR(10) CHECK(estado IN ('ACTIVO', 'INACTIVO')),
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2
);

-- =========================
-- TABLA ROL
-- =========================
CREATE TABLE rol(
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL 
        CHECK(nombre IN('ADMIN','DUENO','TRABAJADOR')),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2
);

-- =========================
-- TABLA USUARIO
-- =========================
CREATE TABLE usuario(
    id_usuario INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    cui VARCHAR(50) NOT NULL,
    nit VARCHAR(50) NOT NULL,
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2
);

-- =========================
-- TABLA USUARIO_SUCURSAL
-- =========================
CREATE TABLE usuario_sucursal(
    id_usuario INT NOT NULL,
    id_sucursal INT NOT NULL,
    id_rol INT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2,

    PRIMARY KEY(id_usuario, id_sucursal),

    FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal),

    FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol)
);

-- =========================
-- TABLA PRODUCTO
-- =========================
CREATE TABLE producto(
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(250),
    categoria VARCHAR(75),
    fecha_caducida DATETIME2,
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2
);

-- =========================
-- TABLA INVENTARIO
-- =========================
CREATE TABLE inventario(
    id_producto INT NOT NULL,
    id_sucursal INT NOT NULL,
    stock INT CHECK(stock >= 0),
    precio_compra DECIMAL(10,2) CHECK(precio_compra >= 0),
    estado VARCHAR(15) NOT NULL 
        CHECK(estado IN('ACTIVO', 'INACTIVO')),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2,

    PRIMARY KEY(id_producto, id_sucursal),

    FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
);

-- =========================
-- TABLA VENTA
-- =========================
CREATE TABLE venta(
    id_venta INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_sucursal INT NOT NULL,
    id_cliente INT,
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2,

    FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal),

    FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
);

-- =========================
-- TABLA DETALLE_VENTA
-- =========================
CREATE TABLE detalle_venta(
    id_detalle INT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio DECIMAL(10,2),
    created_at DATETIME2 NOT NULL,
    updated_at DATETIME2,

    FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta),

    FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto)
);