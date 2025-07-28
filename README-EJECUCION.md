# Guía de Ejecución - Data Engineering with Databricks Cookbook

## 📋 Descripción del Proyecto

Este proyecto es un entorno completo de **Data Engineering** que incluye Apache Spark, Delta Lake, Kafka, y JupyterLab para aprender y practicar técnicas de ingeniería de datos. El entorno está completamente containerizado usando Docker.

## 🏗️ Arquitectura del Sistema

El entorno incluye los siguientes componentes:

- **Apache Spark Cluster**: Cluster distribuido con master y workers
- **JupyterLab**: Entorno de desarrollo con notebooks
- **Kafka**: Para streaming de datos
- **Zookeeper**: Coordinador para Kafka
- **Delta Lake**: Para tablas ACID y time travel

### Componentes Docker:

1. **spark-master**: Nodo maestro del cluster Spark (puerto 8080)
2. **spark-worker-1**: Worker 1 del cluster Spark (puerto 8081)
3. **spark-worker-2**: Worker 2 del cluster Spark (puerto 8082)
4. **jupyterlab**: Entorno de desarrollo (puerto 8888)
5. **kafka**: Broker de mensajería (puerto 9092)
6. **zookeeper**: Coordinador de Kafka (puerto 2181)

## 🚀 Requisitos Previos

### Software Requerido:

| Software | Versión Mínima | Descripción |
|----------|----------------|-------------|
| Docker Engine | 18.02.0+ | Motor de contenedores |
| Docker Compose | 1.25.5+ | Orquestador de contenedores |
| Git | Cualquier versión | Control de versiones |

### Requisitos de Hardware:

- **RAM**: Mínimo 4GB, recomendado 8GB+
- **CPU**: 2 cores mínimo, 4+ recomendado
- **Disco**: 10GB de espacio libre

## 📦 Instalación y Configuración

### Paso 1: Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd Data-Engineering-with-Databricks-Cookbook
```

### Paso 2: Construir las Imágenes Docker

**En Windows (PowerShell):**
```powershell
# Navegar al directorio del proyecto
cd Data-Engineering-with-Databricks-Cookbook

# Ejecutar el script de construcción
./build.sh
```

**En Linux/Mac:**
```bash
# Dar permisos de ejecución al script
chmod +x build.sh

# Ejecutar el script de construcción
./build.sh
```

**Nota**: Si tienes problemas con el script `build.sh`, puedes ejecutar los comandos manualmente:

```bash
# Limpiar contenedores e imágenes existentes
docker system prune -a

# Construir las imágenes en orden
docker build -f docker/base/Dockerfile -t base:latest .
docker build -f docker/spark-base/Dockerfile -t spark-base:3.4.1 .
docker build -f docker/spark-master/Dockerfile -t spark-master:3.4.1 .
docker build -f docker/spark-worker/Dockerfile -t spark-worker:3.4.1 .
docker build -f docker/jupyterlab/Dockerfile -t jupyterlab:4.0.2-spark-3.4.1 .
```

### Paso 3: Iniciar el Entorno

```bash
# Iniciar todos los servicios
docker-compose up -d
```

### Paso 4: Verificar que Todo Funciona

```bash
# Verificar que todos los contenedores están ejecutándose
docker-compose ps
```

Deberías ver algo como:
```
NAME            COMMAND                  SERVICE             STATUS              PORTS
jupyterlab      "jupyter lab --ip=0.…"   jupyterlab          Up                  0.0.0.0:8888->8888/tcp, 0.0.0.0:4040->4040/tcp
kafka           "/opt/bitnami/script…"   kafka               Up                  0.0.0.0:9092->9092/tcp
spark-master    "bin/spark-class org…"   spark-master        Up                  0.0.0.0:7077->7077/tcp, 0.0.0.0:8080->8080/tcp
spark-worker-1  "bin/spark-class org…"   spark-worker-1      Up                  0.0.0.0:8081->8081/tcp
spark-worker-2  "bin/spark-class org…"   spark-worker-2      Up                  0.0.0.0:8082->8081/tcp
zookeeper       "/opt/bitnami/script…"   zookeeper           Up                  0.0.0.0:2181->2181/tcp
```

## 🌐 Acceso a los Servicios

Una vez que el entorno esté ejecutándose, puedes acceder a los siguientes servicios:

### 1. JupyterLab (Entorno Principal)
- **URL**: http://localhost:8888
- **Descripción**: Entorno de desarrollo con notebooks
- **Sin contraseña**: El token está deshabilitado para facilitar el acceso

### 2. Spark Master UI
- **URL**: http://localhost:8080
- **Descripción**: Interfaz web para monitorear el cluster Spark

### 3. Spark Worker UIs
- **Worker 1**: http://localhost:8081
- **Worker 2**: http://localhost:8082
- **Descripción**: Monitoreo de los workers individuales

### 4. Spark Application UI
- **URL**: http://localhost:4040
- **Descripción**: Interfaz para aplicaciones Spark activas

## 📚 Estructura del Proyecto

```
Data-Engineering-with-Databricks-Cookbook/
├── Chapter01/          # Lectura de datos (CSV, JSON, Parquet, XML)
├── Chapter02/          # Transformaciones básicas
├── Chapter03/          # Delta Lake
├── Chapter04/          # Streaming con Kafka
├── Chapter05/          # Streaming avanzado
├── Chapter06/          # Optimización de Spark
├── Chapter07/          # Optimización de Delta
├── Chapter08/          # Databricks Workflows
├── Chapter09/          # Delta Live Tables
├── Chapter10/          # Unity Catalog
├── Chapter11/          # CI/CD y DevOps
├── data/              # Datasets de ejemplo
├── docker/            # Configuración de Docker
├── docker-compose.yml # Orquestación de servicios
└── build.sh          # Script de construcción
```

## 🔧 Configuración de Spark en JupyterLab

Cuando abras JupyterLab, puedes usar el siguiente código para conectarte al cluster Spark:

```python
from pyspark.sql import SparkSession

# Crear sesión de Spark
spark = (SparkSession.builder
    .appName("mi-aplicacion")
    .master("spark://spark-master:7077")
    .config("spark.executor.memory", "512m")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .getOrCreate())

# Configurar nivel de logs
spark.sparkContext.setLogLevel("ERROR")

# Verificar conexión
print(f"Spark Version: {spark.version}")
print(f"Spark Master: {spark.conf.get('spark.master')}")
```

## 📊 Datasets Incluidos

El proyecto incluye varios datasets de ejemplo en la carpeta `data/`:

- **Credit Card**: Datos de tarjetas de crédito para análisis de fraude
- **Netflix Titles**: Catálogo de títulos de Netflix
- **Nobel Prizes**: Datos de premios Nobel
- **Partitioned Recipes**: Datos de recetas particionados por fecha

## 🛠️ Comandos Útiles

### Gestión del Entorno

```bash
# Iniciar todos los servicios
docker-compose up -d

# Detener todos los servicios
docker-compose down

# Ver logs de un servicio específico
docker-compose logs jupyterlab
docker-compose logs spark-master

# Reiniciar un servicio específico
docker-compose restart jupyterlab

# Ver estado de todos los servicios
docker-compose ps
```

### Limpieza y Mantenimiento

```bash
# Limpiar contenedores e imágenes
docker system prune -a

# Eliminar volumen de datos compartidos
docker volume rm distributed-file-system

# Reconstruir imágenes desde cero
./build.sh
```

### Troubleshooting

```bash
# Ver logs detallados
docker-compose logs -f

# Acceder a un contenedor específico
docker exec -it jupyterlab bash
docker exec -it spark-master bash

# Verificar conectividad entre servicios
docker exec -it jupyterlab ping spark-master
```

## 🚨 Solución de Problemas Comunes

### 1. Puerto 8888 ya está en uso
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - 8889:8888  # Cambiar 8888 por 8889
```

### 2. Error de memoria insuficiente
```bash
# Aumentar memoria en docker-compose.yml
environment:
  - SPARK_WORKER_MEMORY=1g  # Cambiar 512m por 1g
```

### 3. JupyterLab no se conecta a Spark
- Verificar que spark-master esté ejecutándose: `docker-compose ps`
- Revisar logs: `docker-compose logs spark-master`
- Asegurarse de usar la URL correcta: `spark://spark-master:7077`

### 4. Problemas de permisos en Windows
```powershell
# Ejecutar PowerShell como administrador
# O configurar Docker Desktop para compartir el drive
```

## 📖 Próximos Pasos

1. **Explorar Chapter01**: Comienza con los notebooks de lectura de datos
2. **Practicar con datasets**: Usa los datos incluidos en la carpeta `data/`
3. **Experimentar con streaming**: Prueba los ejemplos de Kafka en Chapter04
4. **Optimizar performance**: Aprende técnicas de optimización en Chapter06-07

## 🔗 Recursos Adicionales

- [Documentación de Apache Spark](https://spark.apache.org/docs/latest/)
- [Delta Lake Documentation](https://docs.delta.io/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker-compose logs`
2. Verifica que Docker tenga suficientes recursos asignados
3. Asegúrate de que los puertos no estén ocupados por otras aplicaciones
4. Revisa la documentación oficial de cada componente

---

**¡Disfruta aprendiendo Data Engineering con este entorno completo!** 🚀 