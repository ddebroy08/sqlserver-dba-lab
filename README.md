# Administración y Monitoreo de Base de Datos en SQL Server

## 1. Instalación

Dirigirse a la página oficial de Microsft y descargar SQL Server, para este proyecto utilizaré SQL Server 2025 Express

```
https://www.microsoft.com/es-es/sql-server/sql-server-downloads
```
![img_descarga](img/descarga.png)

Ejecutar como administrador para darle los permisos necesarios durante la instalación

![img_install_admin](img/ejecutarAdmin.png)

Escoger el tipo de instalación básico para comenzar con las configuraciones por defecto. Normalmente viene configurado para ingresar credenciales y trabajar rápidamente.

![img_tipo_instalacion](img/tipoInstalacion.png)

Escoger idioma de preferencia y aceptar los términos.

![img_idioma_terminos](img/idioma.png)

Escoger el directorio en dónde deseas guardar tus bases de datos.

![img_path](img/path.png)

Posteriormente instalar. 

Si la instalación se completa con éxito, deberá mostrarte esto:

- INSTANCE NAME:  SQLEXPRESS → Es el nombre de la instancia. Como puedes tener múltiples SQL Server en una misma PC, esto identifica cuál es.

- CONNECTION STRING: Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=True → Es la dirección que usarás para conectarte desde aplicaciones o herramientas. Usa autenticación de Windows (tu usuario).

- SQL ADMINISTRATORS: DESKTOP-91F9CRE\Diego Debroy → Usuario que es administrador de este SQL Server.

- LOG FOLDER: Carpeta donde se guardan los registros (logs) de instalación y configuración.

- FEATURES INSTALLED: SQLENGINE → Solo instalaste el motor de base de datos, sin Reporting Services, Integration Services, etc.

- VERSION: 	17.0.1000.7, RTM → Versión inicial (RTM = Release To Manufacturing).

![img_installation_successfully](img/instalacion_exitosa.png)


### Descargar SSMS

```
https://learn.microsoft.com/en-us/ssms/install/install?redirectedfrom=MSDN
```

![img_ssms](img/instalar_ssms.png)

Una vez descargado, ejecutar para comenzar con la instalación

![img_ssms_instalacion](img/ssms_instalacion.png)

Da la opción de añadir componentes de ayuda durante la descarga, para este ejemplo descargaré 'Control de Versiones Git' y 'Proyectos de SQL Database' ya que es muy útil para organizar el trabajo. Estos componentes se pueden instalar en cualquier momento. 

![img_componentes_ssms](img/ssms_componentes.png)

Esperar mientras se copmleta la descarga, el tiempo varía conforme las capacidades del equipo.

![img_descarga_ssms](img/descarga_ssms.png)

Luego de que la instalación finalizó, se debe reiniciar el equipo. 

Iniciar sesión (opcional)

![img_login](img/iniciar_sesion.png)


## 2. Configurar SSMS 

![img_config_ssms](img/conf_ssms.png)

1. Al abrir SSMS, se mostrará el cuadro de diálogo "Conectar al servidor".

2. Verifique que los datos sean los siguientes:

- Tipo de servidor: Motor de base de datos
- Nombre del servidor: DESKTOP-91F9CRE\SQLEXPRESS (o localhost\SQLEXPRESS)
- Autenticación: Autenticación de Windows

3. No modifique el resto de los campos.

4. Haga clic en Conectar.

Nota: No se requiere contraseña al usar autenticación de Windows, ya que SSMS utiliza las credenciales de la sesión activa del sistema operativo.

### Solución de error de certificado SSL
Error: Al intentar conectar aparece el error "La cadena de certificación fue emitida por una entidad en la que no se confía".

Causa: SQL Server utiliza un certificado autofirmado y el cliente no confía en él.

Solución:

En la ventana Conectar al servidor, haga clic en Avanzadas.

Establezca la propiedad Trust Server Certificate en True.

Haga clic en Aceptar y luego en Conectar.

Nota de seguridad: Esta opción es aceptable para entornos de desarrollo y pruebas. En producción, use un certificado válido de una autoridad certificadora (CA) de confianza.


SQL Server está listo para gestionar bases de datos. 
![img_pantalla_ssms](img/pantalla_ssms.png)

## 3. Análisis de base de datos proporcionada 

```
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

```

La base de datos proporcionada presenta una estructura funcional orientada a la gestión de ventas, clientes, productos y sucursales. Sin embargo, tras su análisis se identificaron varias oportunidades de mejora en términos de diseño, integridad y rendimiento.

### 3.1 Análisis estructural

Se identificó que el modelo relacional permite gestionar correctamente:

Clientes
Usuarios (empleados)
Sucursales
Productos
Ventas y su detalle

Las relaciones entre tablas están definidas mediante claves foráneas, lo cual asegura una base consistente a nivel estructural.

### 3.2 Problemas detectados
A pesar de ser funcional, se encontraron las siguientes limitaciones:

1. Relación usuario - sucursal limitada
La tabla usuario contiene una relación directa con sucursal, lo que implica que:
- Un usuario solo puede pertenecer a una sucursal
- No es posible asignar múltiples sucursales a un mismo usuario
- No se pueden manejar distintos roles por sucursal

2. Falta de índices en consultas críticas 
No se identificaron índices adicionales en columnas utilizadas frecuentemente consultadas:
- venta.created_at
- detalle_venta.id_producto
- venta.id_sucursal

Esto puede generar bajo rendimiento en consultas con grandes volúmenes de datos.

3. Campos sin restricciones adicionales 
Se detectó ausencia de restricciones importantes como:
- UNIQUE en correos electrónicos
- NOT NULL en algunos campos clave
- Validaciones de integridad adicionales
Esto puede provocar inconsistencia en los datos.

4. Modelo de categorías no normalizado
El campo categoria en la tabla producto es un valor de texto libre, lo que puede generar inconsistencias como:
- Valores duplicados
- Diferencias en formato (mayúsculas/minúsculas)
Se recomienda una tabla independiente para categorías.

5. Falta de automatización y monitoreo
La base de datos no cuenta con:
- Mecanismos de respaldo automáticos
- Monitoreo de rendimiento
- Tareas programadas
Esto representa un riesgo en entornos productivos

### 3.3 Conclusión del análisis
La base de datos es funcional para operaciones básicas; sin embargo, requiere mejoras en:
- Escalabilidad
- Rendimiento
- integridad de datos
- Administración
Estas mejoras serán abordadas en las siguientes secciones mediante la implementación de optimizaciones, automatización y buenas prácticas de administración en SQL Server. 

## 4. Monitoreo inicial de rendimiento
Se realizó un análisis de rendimiento inicial mediante la ejecución de consultas representativas del sistema, con el objetivo de identificar posibles cuellos de botella antes de aplicar optimizaciones.

Activar métricas de rendimiento

```
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
```

**20 productos más vendidos**

``` Consulta SQL
SELECT TOP 20 
	p.nombre AS NombreProducto,
	SUM(dv.cantidad) AS CantidadVendida
FROM producto p 
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
GROUP BY p.nombre
ORDER BY CantidadVendida DESC;
```
![img_20productos_mas_vendidos](img/analisis_20productos.png)

**Resultado del monitoreo**

Al ejecutar la consulta utilizando las métricas de rendimiento de SQL Server (SET STATISTICS IO y SET STATISTICS TIME), se obtuvo la siguiente información relevante:

- Lecturas lógicas en detalle_venta: 3119
- Lecturas lógicas en producto: 21
- Tiempo de CPU: 125 ms
- Tiempo total de ejecución: 121 ms


**Análisis de resultados**

El análisis evidencia que la mayor carga de trabajo de la consulta se concentra en la tabla detalle_venta, la cual presenta un número significativamente alto de lecturas lógicas en comparación con la tabla producto.

Esto indica que:

- El motor de base de datos realiza un escaneo amplio sobre detalle_venta
- La operación de agregación (SUM) y el agrupamiento (GROUP BY) incrementan el costo
- La ausencia de índices adecuados provoca que la consulta no pueda optimizar el acceso a los datos

Por otro lado, la tabla producto presenta un impacto mínimo, lo que confirma que no representa un cuello de botella en esta consulta.


**Identificación del problema principal**

El principal problema detectado es:

- Alto número de lecturas lógicas en la tabla detalle_venta

Esto puede escalar negativamente en escenarios con mayor volumen de datos, afectando el rendimiento general del sistema

**Conclusión**
El monitoreo inicial permitió identificar un cuello de botella claro en la tabla detalle_venta, causado por la falta de índices en columnas críticas.

Si no se corrige, este problema puede escalar conforme aumente el volumen de datos.
La implementación de índices adecuados permitirá mejorar significativamente el rendimiento de las consultas analíticas del sistema.


**Ventas por sucursal**

``` Consulta SQL
SELECT 
    s.nombre AS NombreSucursal,
    COUNT(v.id_venta) AS TotalVentas
FROM sucursal s
INNER JOIN venta v 
    ON s.id_sucursal = v.id_sucursal
GROUP BY s.nombre
ORDER BY TotalVentas DESC;
```

![img_ventas_sucursal](img/ventas_sucursal.png)

*Resultados del monitoreo*

Al ejecutar la consulta utilizando herramientas de monitoreo en SQL Server (`SET STATISTICS IO` y SET `STATISTICS TIME`), se obtuvo:

Lecturas lógicas en venta: 461
Lecturas lógicas en sucursal: 10
Lecturas físicas en sucursal: 1
Tiempo de CPU: 31 ms
Tiempo total de ejecución: 30 ms

**Análisis de resultados**

A diferencia de la consulta anterior, el rendimiento de esta operación es significativamente mejor.

Se observa que:

- La tabla `venta` concentra la mayor carga de trabajo, con 461 lecturas lógicas
- La tabla `sucursal` tiene un impacto mínimo
- El tiempo de ejecución es bajo, lo que indica una consulta eficiente

Esto se debe a que:

- La operación es más simple (solo `COUNT` en lugar de `SUM` con multiplicaciones)
- El volumen de datos procesado es menor en comparación con `detalle_venta`
- La relación entre tablas es directa y sin complejidad adicional

**Lecturas físicas detectadas**

Se identificó:

```
Lecturas físicas en sucursal: 1
```

Esto indica que SQL Server necesitó acceder al disco para obtener datos que no estaban en memoria (buffer pool).

Interpretación:

No es un problema en este contexto
Puede deberse a que la tabla no estaba en caché
En ejecuciones posteriores normalmente desaparece

**Evaluación de rendimiento**
Comparado con la consulta anterior:

| Consulta               | Tabla crítica | Lecturas | Tiempo |
| ---------------------- | ------------- | -------- | ------ |
| Productos más vendidos | detalle_venta | 3119     | 121 ms |
| Ventas por sucursal    | venta         | 461      | 30 ms  |

Se concluye que:

- Esta consulta es más eficiente
- No presenta cuellos de botella críticos
- Escalará mejor con crecimiento moderado de datos

**Conclusión** 

La consulta presenta un rendimiento adecuado y no evidencia problemas críticos.
El costo principal se encuentra en la tabla venta, aunque dentro de un rango aceptable.

Se recomienda la creación de índices para optimizar aún más el rendimiento y garantizar escalabilidad ante un mayor volumen de datos.

*Ingreso total por sucursal*

``` Consulta SQL
SELECT 
	s.nombre AS NombreSucursal,
	SUM(dv.cantidad * dv.precio) AS IngresoTotal
FROM sucursal s
JOIN venta v ON v.id_sucursal = s.id_sucursal
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY s.nombre
ORDER BY IngresoTotal DESC;
```

![img_ingreso_total_sucursal](img/ingreso_total.png)

**Resultados del monitoreo**

Al ejecutar la consulta con métricas de rendimiento en SQL Server, se obtuvo:

- Lecturas lógicas en detalle_venta: 3119
- Lecturas lógicas en venta: 461
- Lecturas lógicas en sucursal: 10
- Lecturas físicas:
    - detalle_venta: 3
    - venta: 1
    - sucursal: 1
- Lecturas anticipadas:
    - detalle_venta: 3115
    - venta: 459
- Tiempo de CPU: 453 ms
- Tiempo total de ejecución: 513 ms

*Análisis de resultados*

Esta consulta presenta un costo significativamente mayor en comparación con las anteriores.

Se identifican los siguientes puntos clave:

**1. Tabla crítica**

La tabla detalle_venta concentra la mayor carga:

- 3119 lecturas lógicas
- 3115 lecturas anticipadas

Esto indica un escaneo intensivo de datos, lo cual es esperado debido a:

- Alto volumen de registros
- Operación de agregación (SUM)
- Cálculo por fila (cantidad * precio)

**2. Costo acumulado por múltiples JOINs**

A diferencia de consultas anteriores, esta incluye:

- JOIN sucursal
- JOIN venta
- JOIN detalle_venta

Esto provoca:

- Mayor cantidad de datos procesados
- Incremento en operaciones intermedias
- Mayor uso de CPU

**3. Tiempo de ejecución elevado**

```
CPU = 453 ms
Tiempo total = 513 ms
```

| Consulta                 | Tiempo      |
| ------------------------ | ----------- |
| Productos más vendidos   | ~121 ms     |
| Ventas por sucursal      | ~30 ms      |
| **Ingreso por sucursal** | **~513 ms** |

Claramente esta es la consulta más costosa.

**Identificación del problema principal**

Alto costo en la tabla detalle_venta combinado con múltiples operaciones de JOIN y agregación

Esto genera:

Escaneos completos
Alto consumo de CPU
Mayor tiempo de respuesta

**Conclusión**

La consulta presenta un cuello de botella claro debido al volumen de datos procesados en detalle_venta y la complejidad de las operaciones realizadas.

Sin optimización, este tipo de consulta no escalará adecuadamente en escenarios reales con mayor volumen de información.

La implementación de índices adecuados es fundamental para garantizar un rendimiento eficiente.


*Usuario más eficiente por sucursal*
``` Consulta SQL
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

```

**Resultados del monitoreo**

Ejecutando la consulta en SQL Server se obtuvo:

- Lecturas lógicas en detalle_venta: 3119
- Lecturas lógicas en venta: 461
- Lecturas lógicas en usuario: 200
- Lecturas lógicas en sucursal: 2
- Lecturas físicas detectadas en varias tablas
- Tiempo de CPU: 453 ms
- Tiempo total: 606 ms

**Análisis de resultados**
1. Consulta de alta complejidad

Esta es la consulta más compleja evaluada hasta el momento, debido a que incluye:

Múltiples JOIN
Agregación (SUM)
Cálculo por fila (cantidad * precio)
Función de ventana (ROW_NUMBER)
Particionamiento (PARTITION BY)

Esto incrementa significativamente el costo computacional.

2. Tabla crítica

Nuevamente, la tabla detalle_venta domina el costo:

3119 lecturas lógicas
3115 lecturas anticipadas

Se confirma como el principal cuello de botella del sistema.


3. Costo adicional por función de ventana

El uso de:
```
ROW_NUMBER() OVER (PARTITION BY ...)
```


provoca que SQL Server:

Ordene datos dentro de cada partición
Genere estructuras temporales
Aumente el uso de CPU

Esto explica el incremento en tiempo respecto a consultas anteriores.


4. Incremento de tiempo de ejecución
```
CPU = 453 ms
Tiempo total = 606 ms
```

| Consulta                  | Tiempo      |
| ------------------------- | ----------- |
| Ventas por sucursal       | ~30 ms      |
| Productos más vendidos    | ~121 ms     |
| Ingreso por sucursal      | ~513 ms     |
| **Usuario más eficiente** | **~606 ms** |

Es la consulta más costosa hasta ahora.


**Problema principal identificado**

Alto costo acumulado por:

- Escaneo de detalle_venta
- Múltiples JOINs
- Función de ventana (ROW_NUMBER)

**Conclusión**

La consulta presenta el mayor costo de todas las evaluadas debido a su complejidad y volumen de datos procesados.

El principal cuello de botella sigue siendo la tabla detalle_venta, agravado por el uso de funciones de ventana y múltiples uniones.

Sin optimización, esta consulta no es escalable para entornos con grandes volúmenes de datos.



## 5. Respaldo de la base de datos

Antes de aplicar cualquier optimización o modificación estructural, es fundamental garantizar la integridad de la información mediante la creación de un respaldo de la base de datos.

Esto permite:

- Recuperar la información en caso de errores durante la implementación de mejoras
- Proteger los datos ante fallos inesperados
- Simular prácticas reales de administración en entornos productivos

**5.1 Creación de backup completo**
Se realizó un respaldo completo de la base de datos `nexoshop` mediante la siguiente instrucción:

``` Bakcup
BACKUP DATABASE nexoshop
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak'
WITH FORMAT,
NAME = 'Backup completo Nexoshop';
```

![img_backup](img/backup.png)

**Resultados obtenidos**
- Se han procesado 4224 páginas (datos)
- Se han procesado 2 páginas (log)
- Total: 4226 páginas

- Tiempo total: 0.242 segundos
- Velocidad: 136.412 MB/s
- Tiempo total (incluyendo overhead): 361 ms
- CPU: 30 ms

**Conclusión**

El respaldo de la base de datos se ejecutó correctamente, con un tiempo de respuesta bajo y una alta velocidad de procesamiento.

No se identificaron problemas de rendimiento ni limitaciones de hardware durante la operación.

Este resultado confirma que el entorno es adecuado para realizar tareas de respaldo de manera eficiente.

Se recomienda validar el respaldo mediante una restauración de prueba, con el fin de garantizar la integridad de los datos y la disponibilidad ante fallos.

**5.2 Verificación del respaldo**

![img_verificacion](img/archivo_existe.png)

```
EXEC master.dbo.xp_fileexist 
'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak';
```

Para validar que el backup fue generado correctamente, se verificó:

- Existencia del archivo .bak en la ruta especificada
- Finalización exitosa del proceso en SQL Server


**5.3 Restauración de prueba**

Como parte de las buenas prácticas, se simuló la restauración de la base de datos para comprobar la integridad del respaldo.

```
RESTORE DATABASE nexoshop_test
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak'
WITH 
    MOVE 'nexoshop' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Data\nexoshop_test.mdf',
    MOVE 'nexoshop_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Data\nexoshop_test.ldf',
    REPLACE;
```

![img_restauracion](img/restauracion.png)

**5.4 Comprobar que si se restauró**

Comprobación 1: Ver bases de datos

Código:
```
SELECT name
FROM sys.databases;
```

![img_comp1](img/comprobacion1.png)

Comprobación 2: Ver tablas dentro de la nueva DB

Código:
```
USE nexoshop_test;
GO

SELECT * FROM sys.tables;
```

![img_comprobacion2](img/comprobacion2.png)

Comprobación 3: Probar datos reales

Código:
```
USE nexoshop_test;
GO

SELECT TOP 10 * FROM producto;
```

![img_comprobacion3](img/comprobacion3.png)

Comprobación 4: Validación profesional

Código:
```
RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\nexoshop.bak';
```

![img_comprobacion4](img/comprobacion4.png)

**Resultados**
La restauración se ejecutó sin errores.
Se verificó la existencia de todas las tablas originales.
Se validó la integridad de los datos mediante consultas de prueba.

**Conclusión**

El proceso de respaldo y restauración fue exitoso, garantizando la disponibilidad de la información en caso de fallos del sistema.

**5.5 Importancia del respaldo en entornos reales**

En entornos productivos, los respaldos deben:

- Realizarse de forma periódica (diaria o incremental)
- Almacenarse en ubicaciones seguras
- Validarse mediante pruebas de restauración

La ausencia de una estrategia de backup representa un riesgo crítico para la continuidad del negocio.


