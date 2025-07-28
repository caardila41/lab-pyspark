#!/bin/bash

# Script de inicio rápido para Data Engineering with Databricks Cookbook
# Ejecutar en terminal

echo "🚀 Iniciando entorno de Data Engineering..."

# Verificar si Docker está ejecutándose
if ! docker version > /dev/null 2>&1; then
    echo "❌ Docker no está ejecutándose. Por favor, inicia Docker Desktop"
    exit 1
fi
echo "✅ Docker está ejecutándose"

# Verificar si estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ No se encontró docker-compose.yml. Asegúrate de estar en el directorio correcto."
    exit 1
fi

# Construir las imágenes si no existen
echo "🔨 Verificando imágenes Docker..."
if ! docker images | grep -q "jupyterlab:4.0.2-spark-3.4.1"; then
    echo "📦 Construyendo imágenes Docker (esto puede tomar varios minutos)..."
    if [ -f "build.sh" ]; then
        chmod +x build.sh
        ./build.sh
    else
        echo "⚠️  Script build.sh no encontrado. Construyendo manualmente..."
        docker build -f docker/base/Dockerfile -t base:latest .
        docker build -f docker/spark-base/Dockerfile -t spark-base:3.4.1 .
        docker build -f docker/spark-master/Dockerfile -t spark-master:3.4.1 .
        docker build -f docker/spark-worker/Dockerfile -t spark-worker:3.4.1 .
        docker build -f docker/jupyterlab/Dockerfile -t jupyterlab:4.0.2-spark-3.4.1 .
    fi
else
    echo "✅ Imágenes Docker ya existen"
fi

# Detener contenedores existentes si los hay
echo "🛑 Deteniendo contenedores existentes..."
docker-compose down

# Iniciar el entorno
echo "🚀 Iniciando servicios..."
docker-compose up -d

# Esperar un momento para que los servicios se inicien
echo "⏳ Esperando que los servicios se inicien..."
sleep 30

# Verificar estado de los servicios
echo "🔍 Verificando estado de los servicios..."
docker-compose ps

# Mostrar URLs de acceso
echo ""
echo "🎉 ¡Entorno iniciado exitosamente!"
echo ""
echo "📱 URLs de acceso:"
echo "   • JupyterLab: http://localhost:8888"
echo "   • Spark Master UI: http://localhost:8080"
echo "   • Spark Worker 1: http://localhost:8081"
echo "   • Spark Worker 2: http://localhost:8082"
echo "   • Spark App UI: http://localhost:4040"
echo ""
echo "💡 Para detener el entorno, ejecuta: docker-compose down"
echo "💡 Para ver logs: docker-compose logs -f"
echo ""
echo "📚 ¡Disfruta aprendiendo Data Engineering!" 