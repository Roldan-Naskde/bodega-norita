# Sistema de Gestión de Bodega Norita

Esta aplicación permite gestionar los productos de la bodega Norita, con funcionalidades para registrar, visualizar, editar, buscar y eliminar productos.

## Características

- Registro de productos con datos completos (nombre, descripción, precio, cantidad ingresada).
- Visualización de productos con búsqueda dinámica.
- Edición de productos existentes.
- Eliminación de productos.
- Interfaz responsiva y amigable con Bootstrap 5.
- API RESTful desarrollada con FastAPI.
- Conexión a base de datos MySQL para almacenamiento de datos.

## Estructura del proyecto

```
bodega-norita-app/
│
├── backend/
│   ├── config/
│   │   └── database.py          # Configuración de la conexión a la base de datos
│   ├── routes.py                # Rutas de la API para la gestión de productos
│   ├── main.py                  # Archivo principal para iniciar el backend
│   └── requirements.txt         # Dependencias del proyecto
│
├── frontend/
│   └── index.html               # Interfaz de usuario
│
├── base-de-datos.sql            # Script SQL para la creación de la base de datos y procedimientos almacenados
│
└── README.md                    # Este archivo
```

## Configuración de la base de datos

El archivo `base-de-datos.sql` contiene el script necesario para configurar la base de datos MySQL utilizada por la aplicación. Este script incluye:

### Tablas

1. **`productos`**: Almacena información básica de los productos, como nombre, descripción y precio.
   ```sql
   CREATE TABLE IF NOT EXISTS productos (
       idproducto INT AUTO_INCREMENT PRIMARY KEY,
       nombre VARCHAR(100) NOT NULL,
       descripcion TEXT,
       precio DECIMAL(10, 2) NOT NULL
   );
   ```

2. **`productos_stock`**: Almacena información sobre el stock de los productos, como la cantidad ingresada y la cantidad disponible.
   ```sql
   CREATE TABLE IF NOT EXISTS productos_stock (
       idproducto INT NOT NULL,
       cantidad_ingreso INT NOT NULL,
       cantidad_disponible INT NOT NULL,
       PRIMARY KEY (idproducto),
       FOREIGN KEY (idproducto) REFERENCES productos(idproducto) ON DELETE CASCADE
   );
   ```

### Procedimientos almacenados

1. **`registrar_producto`**: Inserta un nuevo producto en la tabla `productos` y su stock inicial en la tabla `productos_stock`.
   ```sql
   CREATE PROCEDURE registrar_producto(
       IN p_nombre VARCHAR(100),
       IN p_descripcion TEXT,
       IN p_precio DECIMAL(10, 2),
       IN p_cantidad_ingreso INT
   )
   ```

2. **`listar_productos`**: Lista todos los productos junto con su información de stock.
   ```sql
   CREATE PROCEDURE listar_productos()
   ```

3. **`filtrar_productos`**: Filtra los productos por nombre o descripción.
   ```sql
   CREATE PROCEDURE filtrar_productos(
       IN p_search VARCHAR(255)
   )
   ```

4. **`eliminar_producto`**: Elimina un producto y su información de stock.
   ```sql
   CREATE PROCEDURE eliminar_producto(
       IN p_idproducto INT
   )
   ```

5. **`actualizar_producto`**: Actualiza la información de un producto y ajusta su stock.
   ```sql
   CREATE PROCEDURE actualizar_producto(
       IN p_idproducto INT,
       IN p_nombre VARCHAR(100),
       IN p_descripcion TEXT,
       IN p_precio DECIMAL(10, 2),
       IN p_cantidad_ingreso INT
   )
   ```

### Ejemplo de uso

El script incluye ejemplos de cómo llamar al procedimiento `registrar_producto` para insertar productos iniciales:
```sql
CALL registrar_producto('Producto 1', 'Descripción del Producto 1', 10.50, 100);
CALL registrar_producto('Producto 2', 'Descripción del Producto 2', 20.00, 200);
```

### Configuración inicial

1. Ejecuta el archivo `base-de-datos.sql` en tu servidor MySQL para crear la base de datos, las tablas y los procedimientos almacenados.
   ```bash
   mysql -u root -p < base-de-datos.sql
   ```

2. Asegúrate de que los datos de conexión en `backend/config/database.py` coincidan con tu configuración de MySQL.

## Instalación y ejecución

### Backend

1. **Instalar dependencias**:
   Asegúrate de tener un entorno virtual activo y ejecuta:
   ```bash
   pip install -r backend/requirements.txt
   ```

2. **Iniciar el servidor**:
   Ejecuta el siguiente comando para iniciar el servidor:
   ```bash
   uvicorn backend.main:app --reload
   ```

   El servidor estará disponible en `http://127.0.0.1:8000`.

### Frontend

1. Abre el archivo `frontend/index.html` en tu navegador.
2. Asegúrate de que el backend esté corriendo para que las funcionalidades estén disponibles.

## Documentación de la API

La API está documentada automáticamente gracias a FastAPI. Puedes acceder a la documentación en:

- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`

### Endpoints principales

| Método | Ruta                     | Descripción                                   |
|--------|--------------------------|-----------------------------------------------|
| GET    | `/productos/`            | Listar todos los productos o buscar por término. |
| GET    | `/productos/{idproducto}`| Obtener un producto específico.              |
| POST   | `/productos/`            | Registrar un nuevo producto.                 |
| PUT    | `/productos/{idproducto}`| Editar un producto existente.                |
| DELETE | `/productos/{idproducto}`| Eliminar un producto.                        |

## Contribuir

Las contribuciones son bienvenidas. Por favor, siéntete libre de mejorar esta aplicación y enviar pull requests.

## Licencia

Este proyecto está bajo la licencia MIT.