from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import router

# Creación de la aplicación FastAPI
app = FastAPI(title="API de Bodega Norita", 
              description="API para gestionar la operaciones Bodega Norita ",
              version="1.0.0")

# Configuración de CORS para permitir solicitudes del frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica los orígenes permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

# Rutas para la API
@app.get("/")
def read_root():
    return {"message": "API de Contactos funcionando correctamente"}


# Ejecutar la aplicación con Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)