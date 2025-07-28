# 🚀 Guía de Inicio Rápido - Data Engineering

## ⚡ Ejecución Rápida (5 minutos)

### Paso 1: Verificar Requisitos
- ✅ Docker Desktop instalado y ejecutándose
- ✅ 4GB+ RAM disponible
- ✅ 10GB+ espacio en disco

### Paso 2: Iniciar el Entorno

**Windows (PowerShell como administrador):**
```powershell
cd Data-Engineering-with-Databricks-Cookbook
.\start-env.ps1
```

**Linux/Mac:**
```bash
cd Data-Engineering-with-Databricks-Cookbook
chmod +x start-env.sh
./start-env.sh
```

### Paso 3: Acceder a JupyterLab
1. Abre tu navegador
2. Ve a: **http://localhost:8888**
3. ¡Listo! Ya puedes empezar a programar

## 📱 URLs de Acceso

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **JupyterLab** | http://localhost:8888 | Entorno principal de desarrollo |
| **Spark Master** | http://localhost:8080 | Monitoreo del cluster Spark |
| **Spark Worker 1** | http://localhost:8081 | Worker individual |
| **Spark Worker 2** | http://localhost:8082 | Worker individual |
| **Spark App UI** | http://localhost:4040 | Aplicaciones activas |

## 🔧 Configuración Inicial en JupyterLab

Copia y pega este código en tu primer notebook:

```python
from pyspark.sql import SparkSession

# Crear sesión de Spark
spark = (SparkSession.builder
    .appName("mi-primer-app")
    .master("spark://spark-master:7077")
    .config("spark.executor.memory", "512m")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .getOrCreate())

# Configurar logs
spark.sparkContext.setLogLevel("ERROR")

# Verificar conexión
print(f"✅ Spark Version: {spark.version}")
print(f"✅ Spark Master: {spark.conf.get('spark.master')}")
```

## 📚 Primeros Pasos

1. **Explorar Chapter01**: Aprende a leer diferentes tipos de datos
2. **Probar datasets**: Usa los datos en la carpeta `data/`
3. **Ejecutar quick-test.py**: Verifica que todo funciona correctamente

## 🛠️ Comandos Útiles

```bash
# Iniciar entorno
docker-compose up -d

# Detener entorno
docker-compose down

# Ver logs
docker-compose logs -f

# Ver estado
docker-compose ps

# Reiniciar JupyterLab
docker-compose restart jupyterlab
```

## 🚨 Problemas Comunes

### Puerto 8888 ocupado
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - 8889:8888  # Usar puerto 8889
```

### Error de memoria
```bash
# Aumentar memoria en docker-compose.yml
environment:
  - SPARK_WORKER_MEMORY=1g
```

### JupyterLab no carga
```bash
# Verificar logs
docker-compose logs jupyterlab

# Reiniciar servicio
docker-compose restart jupyterlab
```

## 📖 Próximos Pasos

1. **Chapter01**: Lectura de datos (CSV, JSON, Parquet, XML)
2. **Chapter02**: Transformaciones básicas
3. **Chapter03**: Delta Lake
4. **Chapter04**: Streaming con Kafka

## 🆘 ¿Necesitas Ayuda?

1. Revisa los logs: `docker-compose logs`
2. Verifica que Docker tenga suficientes recursos
3. Asegúrate de que los puertos no estén ocupados
4. Consulta el README-EJECUCION.md completo

---

**¡Disfruta aprendiendo Data Engineering!** 🚀 