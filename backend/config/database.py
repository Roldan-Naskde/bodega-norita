# filepath: e:\SENATI\contact-form-app\backend\config\database.py
import mysql.connector
from mysql.connector import Error

def create_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",  # Cambia esto según tu configuración
            user="root",       # Usuario de MySQL
            password="",  # Contraseña de MySQL
            database="bodega_norita_bd"  # Nombre de la base de datos
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error al conectar a la base de datos: {e}")
        return None