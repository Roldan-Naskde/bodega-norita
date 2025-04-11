from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
from config.database import create_connection

router = APIRouter()

# Modelo para registrar un producto
class Producto(BaseModel):
    nombre: str
    descripcion: str
    precio: float
    cantidad_ingreso: int


# Modelo para editar un producto
class ProductoEditar(BaseModel):
    nombre: str
    descripcion: str
    precio: float
    cantidad_ingreso: int

@router.get("/productos/{idproducto}")
def obtener_producto(idproducto: int):
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM productos WHERE idproducto = %s", (idproducto,))
        producto = cursor.fetchone()
        if not producto:
            raise HTTPException(status_code=404, detail="Producto no encontrado")
        return producto
    except Exception as e:
        print(f"Error al obtener producto: {e}")
        raise HTTPException(status_code=500, detail="Error al obtener el producto")
    finally:
        connection.close()
    
@router.get("/productos/")
def listar_productos(search: str = None):
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor(dictionary=True)
        if search:
            # Llamar al procedimiento almacenado con el término de búsqueda
            cursor.callproc("filtrar_productos", [search])
        else:
            # Llamar al procedimiento almacenado sin término de búsqueda
            cursor.callproc("filtrar_productos", [None])

        # Obtener los resultados del procedimiento almacenado
        for result in cursor.stored_results():
            productos = result.fetchall()
        return productos
    except Exception as e:
        print(f"Error al listar productos: {e}")
        raise HTTPException(status_code=500, detail="Error al listar los productos")
    finally:
        connection.close()

# Ruta para registrar un producto
@router.post("/productos/")
def registrar_producto(producto: Producto):
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor()
        cursor.callproc("registrar_producto", [
            producto.nombre,
            producto.descripcion,
            producto.precio,
            producto.cantidad_ingreso
        ])
        connection.commit()
        return {"message": "Producto registrado correctamente"}
    except Exception as e:
        print(f"Error al registrar producto: {e}")
        raise HTTPException(status_code=500, detail="Error al registrar el producto")
    finally:
        connection.close()

# Ruta para listar los productos
@router.get("/productos/", response_model=List[Dict[str, Any]])
def listar_productos():
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("listar_productos")
        for result in cursor.stored_results():
            productos = result.fetchall()
        return productos
    except Exception as e:
        print(f"Error al listar productos: {e}")
        raise HTTPException(status_code=500, detail="Error al listar los productos")
    finally:
        connection.close()

# Ruta para eliminar un producto
@router.delete("/productos/{idproducto}")
def eliminar_producto(idproducto: int):
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor()
        cursor.callproc("eliminar_producto", [idproducto])
        connection.commit()
        return {"message": "Producto eliminado correctamente"}
    except Exception as e:
        print(f"Error al eliminar producto: {e}")
        raise HTTPException(status_code=500, detail="Error al eliminar el producto")
    finally:
        connection.close()

# Ruta para editar un producto
@router.put("/productos/{idproducto}")
def editar_producto(idproducto: int, producto: ProductoEditar):
    connection = create_connection()
    if not connection:
        raise HTTPException(status_code=500, detail="Error al conectar a la base de datos")
    try:
        cursor = connection.cursor()
        cursor.callproc("actualizar_producto", [
            idproducto,
            producto.nombre,
            producto.descripcion,
            producto.precio,
            producto.cantidad_ingreso
        ])
        connection.commit()
        return {"message": "Producto actualizado correctamente"}
    except Exception as e:
        print(f"Error al editar producto: {e}")
        raise HTTPException(status_code=500, detail="Error al editar el producto")
    finally:
        connection.close()