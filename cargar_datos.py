import pandas as pd
from sqlalchemy import create_engine

# Configuración de conexión a PostgreSQL
usuario = 'postgres'
contrasena = 'lari98'
host = 'localhost'  # o el IP del servidor
puerto = '5432'
basedatos = 'postgres'
tabla_destino = 'retail_aux1'

# Crear conexión
engine = create_engine(f'postgresql+psycopg2://{usuario}:{contrasena}@{host}:{puerto}/{basedatos}')

# Ruta del Excel
ruta_excel = 'retail_carga.xlsx'

# 📥 Leer todas las hojas
xlsx = pd.read_excel(ruta_excel, sheet_name=None)

# 🔁 Procesar cada hoja
for nombre_hoja, df in xlsx.items():
    print(f"\n📄 Procesando hoja: {nombre_hoja}")

    # Mostrar columnas originales
    print(f"Columnas originales: {df.columns.tolist()}")

    # Renombrar columnas para que coincidan con PostgreSQL
    df.columns = [
        'date','customer_id','product_id','quantity'
    ]


    # Insertar en la base de datos
    try:
        df.to_sql(tabla_destino, engine, schema='public', if_exists='append', index=False)
        print(f"✅ Hoja '{nombre_hoja}' insertada correctamente.")
    except Exception as e:
        print(f"❌ Error al insertar hoja '{nombre_hoja}': {e}")