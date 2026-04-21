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

