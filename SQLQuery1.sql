CREATE DATABASE nexoshop;
GO

USE nexoshop;
GO

CREATE TABLE cliente(
	id_cliente INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	correo VARCHAR(50),
	cui VARCHAR(50),
	nit VARCHAR(50),
	created_at DATETIME2,
	updated_at DATETIME2
);

SELECT * FROM cliente;

CREATE TABLE sucursal(
	id_sucursal INT PRIMARY KEY,
	nombre VARCHAR(75) NOT NULL,
	direccion VARCHAR(250),
	estado VARCHAR(10) CHECK(estado IN ('ACTIVO', 'INACTIVO')),
	created_at DATETIME2,
	updated_at DATETIME2
);

CREATE TABLE usuario (
	id_usuario INT PRIMARY KEY,
	id_sucursal INT NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	correo VARCHAR(50) NOT NULL,
	cui VARCHAR(50) NOT NULL,
	nit VARCHAR(50) NOT NULL,
	created_at DATETIME2,
	updated_at DATETIME2,
	FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);


CREATE TABLE producto(
	id_producto INT PRIMARY KEY,
	id_sucursal INT NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	descripcion VARCHAR(250),
	categoria VARCHAR(75),
	fecha_caducida DATETIME2,
	created_at DATETIME2,
	updated_at DATETIME2,
	FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);

CREATE TABLE venta(
	id_venta INT PRIMARY KEY,
	id_usuario INT NOT NULL,
	id_sucursal INT,
	created_at DATETIME2,
	updated_at DATETIME2,
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
	FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);

CREATE TABLE detalle_venta(
	id_detalle INT PRIMARY KEY,
	id_venta INT NOT NULL,
	id_producto INT NOT NULL,
	cantidad INT NOT NULL,
	precio DECIMAL(10,2),
	created_at DATETIME2,
	updated_at DATETIME2,
	FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
	FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- 20 PRODUCTOS MÁS VENDIDOS
SELECT TOP 20 
	p.nombre AS NombreProducto,
	SUM(dv.cantidad) AS CantidadVendida
FROM producto p 
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
GROUP BY p.nombre
ORDER BY CantidadVendida DESC;

-- Ventas por sucursal
SELECT 
    s.nombre AS NombreSucursal,
    COUNT(v.id_venta) AS TotalVentas
FROM sucursal s
INNER JOIN venta v 
    ON s.id_sucursal = v.id_sucursal
GROUP BY s.nombre
ORDER BY TotalVentas DESC;

-- INGRESO TOTAL POR SUCURSAL
SELECT 
	s.nombre AS NombreSucursal,
	SUM(dv.cantidad * dv.precio) AS IngresoTotal
FROM sucursal s
JOIN venta v ON v.id_sucursal = s.id_sucursal
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY s.nombre
ORDER BY IngresoTotal DESC;

-- USUARIO MÁS EFICIENTE 
SELECT TOP 1
	u.nombre, 
	SUM(dv.cantidad * dv.precio) AS TotalVentasCerradas
FROM usuario u
JOIN venta v ON u.id_usuario = v.id_usuario
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY u.nombre
ORDER BY TotalVentasCerradas DESC;

-- USUARIO MÁS EFICIENTE POR SUCURSAL
WITH ranking AS (
    SELECT 
        s.nombre AS sucursal,
        u.nombre AS usuario,
        SUM(dv.cantidad * dv.precio) AS total_ventas,
        ROW_NUMBER() OVER (
            PARTITION BY s.id_sucursal
            ORDER BY SUM(dv.cantidad * dv.precio) DESC
        ) AS rn
    FROM usuario u
    INNER JOIN sucursal s 
        ON u.id_sucursal = s.id_sucursal
    INNER JOIN venta v 
        ON u.id_usuario = v.id_usuario
    INNER JOIN detalle_venta dv 
        ON v.id_venta = dv.id_venta
    GROUP BY s.id_sucursal, s.nombre, u.nombre
)
SELECT 
    sucursal,
    usuario,
    total_ventas
FROM ranking
WHERE rn = 1;


-- Ventas en rango de fechas
SELECT TOP 10
	p.categoria,
	SUM(dv.precio * dv.cantidad) AS TotalVendido
FROM producto p 
JOIN detalle_venta dv ON dv.id_producto = p.id_producto
JOIN venta v ON v.id_venta = dv.id_venta
WHERE v.created_at BETWEEN '2016-01-01' AND '2025-05-15'
GROUP BY p.categoria
ORDER BY TotalVendido DESC;

-- Clientes activos en cierto rango de fecha
--WITH ranking AS (
--	SELECT 
--		CONCAT(c.nombre, ' ',c.apellido) AS NombreCliente,




SELECT @@SERVERNAME;


DELETE FROM detalle_venta;
DELETE FROM venta;
DELETE FROM producto;
DELETE FROM usuario;
DELETE FROM cliente;
DELETE FROM sucursal;

ALTER TABLE cliente DROP CONSTRAINT DF__cliente__created__4AB81AF0;
ALTER TABLE sucursal DROP CONSTRAINT DF__sucursal__create__4E88ABD4;
ALTER TABLE usuario DROP CONSTRAINT DF__usuario__created__5165187F;
ALTER TABLE producto DROP CONSTRAINT DF__producto__create__5535A963;
ALTER TABLE venta DROP CONSTRAINT DF__venta__created_a__59063A47;
ALTER TABLE detalle_venta DROP CONSTRAINT DF__detalle_v__creat__5DCAEF64;

ALTER TABLE cliente ALTER COLUMN created_at DATETIME2 NOT NULL;
ALTER TABLE sucursal ALTER COLUMN created_at DATETIME2 NOT NULL;
ALTER TABLE usuario ALTER COLUMN created_at DATETIME2 NOT NULL;
ALTER TABLE producto ALTER COLUMN created_at DATETIME2 NOT NULL;
ALTER TABLE venta ALTER COLUMN created_at DATETIME2 NOT NULL;
ALTER TABLE detalle_venta ALTER COLUMN created_at DATETIME2 NOT NULL;


-- Backup
BACKUP DATABASE nexoshop
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak'
WITH FORMAT,
NAME = 'Backup completo Nexoshop';

-- Verificar que exista el archivo .bak
EXEC master.dbo.xp_fileexist 
'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak';

-- Restauración del backup
RESTORE DATABASE nexoshop_test
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak'
WITH 
    MOVE 'nexoshop' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Data\nexoshop_test.mdf',
    MOVE 'nexoshop_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Data\nexoshop_test.ldf',
    REPLACE;

-- Comprobación 1 - Ver bases de datos
SELECT name
FROM sys.databases;

-- Comprobación 2 - Ver tablas dentro de la nueva DB
USE nexoshop_test;
GO

SELECT * FROM sys.tables;

-- Comprobación 3: 
USE nexoshop_test;
GO

SELECT TOP 10 * FROM producto;

-- Comprobación 4: 
RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak';


-- ÍNDICES

-- TABLA detalle_venta
CREATE NONCLUSTERED INDEX idx_detalle_venta_producto
ON detalle_venta(id_producto);

CREATE NONCLUSTERED INDEX idx_detalle_venta_venta
ON detalle_venta(id_venta);

-- TABLA venta
CREATE NONCLUSTERED INDEX idx_venta_sucursal
ON venta(id_sucursal);

CREATE NONCLUSTERED INDEX idx_venta_usuario
ON venta(id_usuario);

CREATE NONCLUSTERED INDEX idx_venta_fecha
ON venta(created_at);


-- TABLA usuario
CREATE UNIQUE INDEX idx_usuario_email
ON usuario(correo);

-- TABLA producto
CREATE NONCLUSTERED INDEX idx_producto_categoria
ON producto(categoria);


CREATE NONCLUSTERED INDEX idx_detalle_venta_full
ON detalle_venta(id_venta, id_producto)
INCLUDE (cantidad, precio);

-- Consuta para confirmar índices creados
EXEC sp_helpindex 'detalle_venta';
EXEC sp_helpindex 'venta';
EXEC sp_helpindex 'usuario0';

-- Limpieza caché
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;





-- Multi-Sucursal


-- Validar datos críticos antes de migrar
IF EXISTS (
    SELECT 1 FROM producto WHERE id_sucursal IS NULL
)
    THROW 50001, 'Hay productos sin sucursal', 1;

IF EXISTS (
    SELECT 1 FROM usuario WHERE id_sucursal IS NULL
)
    THROW 50002, 'Hay usuarios sin sucursal', 1;



-- Tabla con los roles permitidos
PRINT 'Creando roles...';
CREATE TABLE rol(
	id_rol INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30) CHECK(nombre IN('ADMIN','DUENO','TRABAJADOR')) NOT NULL,
	created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	updated_at DATETIME2
);

-- Crear tabla de relación
PRINT 'Creando usuario_sucursal';
CREATE TABLE usuario_sucursal(
	id_usuario INT NOT NULL,
	id_sucursal INT NOT NULL,
	id_rol INT NOT NULL,
	created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	updated_at DATETIME2,
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
	FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
	FOREIGN KEY (id_rol) REFERENCES rol(id_rol),
	PRIMARY KEY(id_usuario, id_sucursal)
);

-- Par que cumpla la condición multi-sucursal
-- Los productos no deben estar ligados únicamente a una sucursal
PRINT 'Creando inventario';
CREATE TABLE inventario(
	id_producto INT NOT NULL,
	id_sucursal INT NOT NULL,
	stock INT CHECK (stock >= 0),
	precio_compra DECIMAL(10,2) CHECK (precio_compra >= 0),
	estado VARCHAR(15) NOT NULL CHECK(estado IN('ACTIVO', 'INACTIVO')),
	created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	updated_at DATETIME2,
	FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
	FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
	PRIMARY KEY (id_producto, id_sucursal)
);

-- índices
CREATE NONCLUSTERED INDEX idx_usuario_sucursal_rol
ON usuario_sucursal(id_usuario, id_rol);

CREATE NONCLUSTERED INDEX idx_inventario
ON inventario(id_sucursal, id_producto)
INCLUDE (stock, precio_compra, estado);


SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRANSACTION;


		-- INSERTAR DATOS EN ROL
		IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre='ADMIN')
			INSERT INTO rol (nombre)
			VALUES ('ADMIN');
		IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre='DUENO')
			INSERT INTO rol (nombre)
			VALUES ('DUENO');
		IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre='TRABAJADOR')
			INSERT INTO rol (nombre)
			VALUES ('TRABAJADOR');


		-- INSERTAR DATOS ANTES DE ELIMINAR COLUMNAS DE TABLAS 
		INSERT INTO usuario_sucursal(id_usuario, id_sucursal, id_rol)
		SELECT 
			id_usuario,
			id_sucursal, 
			1 --TODOS ADMIN PORQUE SOLO LOS DUEÑOS MANEJABAN SU NEGOCIO ANTES DE SOLICITAR CAMBIOS, SE DEBERÁN CREAR NUEVOS USUARIOS
		FROM usuario
		WHERE id_sucursal IS NOT NULL
		AND NOT EXISTS (
			SELECT 1
			FROM usuario_sucursal us
			WHERE us.id_usuario = usuario.id_usuario
				AND us.id_sucursal = usuario.id_sucursal
				AND us.id_rol = 1
		);


		-- INSERTAR DATOS EN INVENTARIO, EXCEPTO stock -> los datos stock los cargaran luego los empleados
		INSERT INTO inventario(id_producto, id_sucursal, precio_compra, estado)
		SELECT 
			p.id_producto, 
			p.id_sucursal,
			NULL,
			'ACTIVO'
		FROM producto p
		WHERE NOT EXISTS(
			SELECT 1 
			FROM inventario i 
			WHERE i.id_producto = p.id_producto
				AND i.id_sucursal = p.id_sucursal
		);

		PRINT 'Validando migración...';

		IF EXISTS (
			SELECT 1 
			FROM usuario u
			LEFT JOIN usuario_sucursal us ON u.id_usuario = us.id_usuario
			WHERE us.id_usuario IS NULL
		)
			THROW 50001, 'Usuarios sin migrar a usuario_sucursal', 1;

		IF EXISTS (
			SELECT 1 
			FROM producto p
			LEFT JOIN inventario i ON p.id_producto = i.id_producto
			WHERE i.id_producto IS NULL
		)
			THROW 50002, 'Productos sin inventario', 1;

	COMMIT;
END TRY
BEGIN CATCH
	ROLLBACK;
	PRINT ERROR_MESSAGE();
END CATCH;

-- VALIDACIONES
SELECT COUNT(*) FROM usuario_sucursal;
SELECT COUNT(*) FROM inventario;

-- ELIMINACIÓN DE COLUMNAS
PRINT 'Identificar el nombre de las FK';

SELECT name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('usuario');

SELECT name 
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('producto');

ALTER TABLE usuario DROP CONSTRAINT FK__usuario__id_sucu__52593CB8;
ALTER TABLE producto DROP CONSTRAINT FK__producto__id_suc__5629CD9C;


PRINT 'Eliminando columnas antiguas...';

ALTER TABLE usuario DROP COLUMN id_sucursal;

ALTER TABLE producto DROP COLUMN id_sucursal;

-- AGREGAR COLUMNA ID_CLIENTE
-- A PARTIR DE AHORA SE LLEVARÁ CONTROL DE QUÉ CLIENTES COMPRAN (no hay datos en ventas existentes)
PRINT 'Agregando clientes a ventas';

ALTER TABLE venta ADD id_cliente INT;

IF EXISTS( SELECT 1 FROM venta WHERE id_cliente IS NULL)
	PRINT 'INFO: Existen ventas históricas sin clientes asociados';

ALTER TABLE venta
ADD CONSTRAINT FK_cliente_venta
FOREIGN KEY (id_cliente)
REFERENCES cliente(id_cliente);

PRINT 'VALIDACIONES FINALES....';
IF (SELECT COUNT(*) FROM usuario_sucursal) = 0
	THROW 50003, 'Falló migración usuario_sucursal', 1;

IF (SELECT COUNT(*) FROM inventario) = 0
	THROW 50004, 'Falló migración inventario', 1;


-- SEGURIDAD
USE nexoshop;
GO

-- 1. Crear logins
CREATE LOGIN admin_nexoshop
WITH PASSWORD = 'Admin123*';

CREATE LOGIN empleado_nexoshop
WITH PASSWORD = 'Empleado123*';
GO

-- 2. Crear usuarios
CREATE USER admin_nexoshop FOR LOGIN admin_nexoshop;
CREATE USER empleado_nexoshop FOR LOGIN empleado_nexoshop;
GO

-- 3. Crear roles
CREATE ROLE rol_admin;
CREATE ROLE rol_empleado;
GO

-- 4. Permisos

-- ADMIN
GRANT SELECT, INSERT, UPDATE, DELETE
ON dbo.venta
TO rol_admin;

-- EMPLEADO
GRANT SELECT, INSERT
ON dbo.venta
TO rol_empleado;

DENY DELETE
ON dbo.venta
TO rol_empleado;
GO

-- 5. Agregar miembros
ALTER ROLE rol_admin
ADD MEMBER admin_nexoshop;

ALTER ROLE rol_empleado
ADD MEMBER empleado_nexoshop;
GO

-- 6. Validar permisos
EXECUTE AS USER = 'empleado_nexoshop';

SELECT TOP 5 * FROM venta;

REVERT;
GO


EXECUTE AS USER = 'empleado_nexoshop';

DELETE FROM venta WHERE id_usuario = 80;
REVERT;
GO


EXEC sp_spaceused;
EXEC sp_MSforeachtable 'EXEC sp_spaceused ''?''';



SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS PromedioCPU,
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS PromedioTiempo,
    SUBSTRING(qt.text,
        qs.statement_start_offset / 2,
        (CASE
            WHEN qs.statement_end_offset = -1
                THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset) / 2
    ) AS Consulta
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY PromedioCPU DESC;