-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS bodega_norita_bd;

-- Usar la base de datos
USE bodega_norita_bd;

-- Crear la tabla productos
CREATE TABLE IF NOT EXISTS productos (
    idproducto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(100),
    empresa VARCHAR(100),
    unidad_medida VARCHAR(50)
);

-- Crear la tabla productos_stock
CREATE TABLE IF NOT EXISTS productos_stock (
    idproducto INT NOT NULL,
    cantidad_ingreso INT NOT NULL,
    cantidad_disponible INT NOT NULL,
    PRIMARY KEY (idproducto),
    FOREIGN KEY (idproducto) REFERENCES productos(idproducto) ON DELETE CASCADE
);

--Crear la tabla unidades_medida
CREATE TABLE IF NO EXISTS unidades_medida (
  `idunidad` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$

CREATE PROCEDURE eliminar_producto(
    IN p_idproducto INT
)
BEGIN
    -- Iniciar una transacción
    START TRANSACTION;

    -- Eliminar el producto de la tabla productos_stock
    DELETE FROM productos_stock WHERE idproducto = p_idproducto;

    -- Eliminar el producto de la tabla productos
    DELETE FROM productos WHERE idproducto = p_idproducto;

    -- Confirmar la transacción
    COMMIT;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE actualizar_producto(
    IN p_idproducto INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10, 2),
    IN p_cantidad_ingreso INT,
    IN p_categoria VARCHAR(100),
    IN p_empresa VARCHAR(100),
    IN p_unidad_medida INT(50)
)
BEGIN
    -- Declarar una variable para calcular la cantidad disponible
    DECLARE cantidad_disponible_actual INT;

    -- Obtener la cantidad disponible actual del producto
    SELECT cantidad_disponible INTO cantidad_disponible_actual
    FROM productos_stock
    WHERE idproducto = p_idproducto;

    -- Actualizar la tabla productos
    UPDATE productos
    SET 
        nombre = p_nombre,
        descripcion = p_descripcion,
        precio = p_precio,
        categoria = p_categoria,
        empresa = p_empresa,
        unidad_medida = p_unidad_medida
    WHERE idproducto = p_idproducto;

    -- Actualizar la tabla productos_stock
    UPDATE productos_stock
    SET 
        cantidad_ingreso = p_cantidad_ingreso,
        cantidad_disponible = cantidad_disponible_actual + (p_cantidad_ingreso - cantidad_ingreso)
    WHERE idproducto = p_idproducto;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE filtrar_productos(
    IN p_search VARCHAR(255)
)
BEGIN
    IF p_search IS NOT NULL AND p_search != '' THEN
        SELECT 
            p.idproducto,
            p.nombre,
            p.descripcion,
            p.precio,
            p.categoria,
            p.empresa,
            p.unidad_medida,
            ps.cantidad_ingreso,
            ps.cantidad_disponible
        FROM productos p
        LEFT JOIN productos_stock ps ON p.idproducto = ps.idproducto
        WHERE p.nombre LIKE CONCAT('%', p_search, '%')
           OR p.descripcion LIKE CONCAT('%', p_search, '%');
    ELSE
        SELECT 
            p.idproducto,
            p.nombre,
            p.descripcion,
            p.precio,
            p.categoria,
            p.empresa,
            p.unidad_medida,
            ps.cantidad_ingreso,
            ps.cantidad_disponible
        FROM productos p
        LEFT JOIN productos_stock ps ON p.idproducto = ps.idproducto;
    END IF;
END$$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `listar_productos`()
BEGIN
    SELECT 
        p.idproducto,
        p.nombre,
        p.descripcion,
        p.precio,
        p.categoria,
        p.empresa,
        p.unidad_medida,
        ps.cantidad_ingreso,
        ps.cantidad_disponible
    FROM 
        productos p
    LEFT JOIN 
        productos_stock ps
    ON 
        p.idproducto = ps.idproducto;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `registrar_producto`(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10, 2),
    IN p_cantidad_ingreso INT,
    IN p_categoria VARCHAR(100),
    IN p_empresa VARCHAR(100),
    IN p_unidad_medida INT(50)
)
BEGIN
    DECLARE last_id INT;

    -- Iniciar una transacción
    START TRANSACTION;

    -- Insertar el producto en la tabla productos
    INSERT INTO productos (nombre, descripcion, precio, categoria, empresa, unidad_medida)
    VALUES (p_nombre, p_descripcion, p_precio, p_categoria, p_empresa, p_unidad_medida);

    -- Obtener el último id generado
    SET last_id = LAST_INSERT_ID();

    -- Insertar el stock inicial en la tabla productos_stock
    INSERT INTO productos_stock (idproducto, cantidad_ingreso, cantidad_disponible)
    VALUES (last_id, p_cantidad_ingreso, p_cantidad_ingreso);

    -- Confirmar la transacción
    COMMIT;
END$$
DELIMITER ;

-- INSERTAR DATOS A LA TABLA UNIDADES_MEDIDA
INSERT INTO `unidades_medida` (`idunidad`, `nombre`, `descripcion`) VALUES
(1, 'Unidad', 'Unidad individual'),
(2, 'Caja', 'Caja con múltiples unidades'),
(3, 'Pieza', 'Pieza única'),
(4, 'Paquete', 'Paquete sellado'),
(5, 'Litro', 'Unidad de volumen'),
(6, 'Kilogramo', 'Unidad de peso');

-- Llamar al procedimiento almacenado para registrar productos con nueva información
CALL registrar_producto('Producto 1', 'Descripción del Producto 1', 10.50, 100, 'Electrónica', 'Empresa X', 'Unidad');
CALL registrar_producto('Producto 2', 'Descripción del Producto 2', 20.00, 200, 'Hogar', 'Empresa Y', 'Caja');
CALL registrar_producto('Producto 3', 'Descripción del Producto 3', 15.75, 150, 'Ropa', 'Empresa Z', 'Pieza');
CALL registrar_producto('Producto 4', 'Descripción del Producto 4', 30.99, 50, 'Alimentos', 'Empresa W', 'Paquete');
CALL registrar_producto('Producto 5', 'Descripción del Producto 5', 25.00, 75, 'Juguetes', 'Empresa V', 'Unidad');
