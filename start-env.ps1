# Script de inicio rápido para Data Engineering with Databricks Cookbook
# Ejecutar como administrador en PowerShell

Write-Host "🚀 Iniciando entorno de Data Engineering..." -ForegroundColor Green

# Verificar si Docker está ejecutándose
try {
    docker version | Out-Null
    Write-Host "✅ Docker está ejecutándose" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está ejecutándose. Por favor, inicia Docker Desktop" -ForegroundColor Red
    exit 1
}

# Verificar si estamos en el directorio correcto
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "❌ No se encontró docker-compose.yml. Asegúrate de estar en el directorio correcto." -ForegroundColor Red
    exit 1
}

# Construir las imágenes si no existen
Write-Host "🔨 Verificando imágenes Docker..." -ForegroundColor Yellow
$images = docker images --format "table {{.Repository}}:{{.Tag}}"
if ($images -notlike "*jupyterlab:4.0.2-spark-3.4.1*") {
    Write-Host "📦 Construyendo imágenes Docker (esto puede tomar varios minutos)..." -ForegroundColor Yellow
    if (Test-Path "build.sh") {
        bash build.sh
    } else {
        Write-Host "⚠️  Script build.sh no encontrado. Construyendo manualmente..." -ForegroundColor Yellow
        docker build -f docker/base/Dockerfile -t base:latest .
        docker build -f docker/spark-base/Dockerfile -t spark-base:3.4.1 .
        docker build -f docker/spark-master/Dockerfile -t spark-master:3.4.1 .
        docker build -f docker/spark-worker/Dockerfile -t spark-worker:3.4.1 .
        docker build -f docker/jupyterlab/Dockerfile -t jupyterlab:4.0.2-spark-3.4.1 .
    }
} else {
    Write-Host "✅ Imágenes Docker ya existen" -ForegroundColor Green
}

# Detener contenedores existentes si los hay
Write-Host "🛑 Deteniendo contenedores existentes..." -ForegroundColor Yellow
docker-compose down

# Iniciar el entorno
Write-Host "🚀 Iniciando servicios..." -ForegroundColor Yellow
docker-compose up -d

# Esperar un momento para que los servicios se inicien
Write-Host "⏳ Esperando que los servicios se inicien..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar estado de los servicios
Write-Host "🔍 Verificando estado de los servicios..." -ForegroundColor Yellow
docker-compose ps

# Mostrar URLs de acceso
Write-Host ""
Write-Host "🎉 ¡Entorno iniciado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 URLs de acceso:" -ForegroundColor Cyan
Write-Host "   • JupyterLab: http://localhost:8888" -ForegroundColor White
Write-Host "   • Spark Master UI: http://localhost:8080" -ForegroundColor White
Write-Host "   • Spark Worker 1: http://localhost:8081" -ForegroundColor White
Write-Host "   • Spark Worker 2: http://localhost:8082" -ForegroundColor White
Write-Host "   • Spark App UI: http://localhost:4040" -ForegroundColor White
Write-Host ""
Write-Host "💡 Para detener el entorno, ejecuta: docker-compose down" -ForegroundColor Yellow
Write-Host "💡 Para ver logs: docker-compose logs -f" -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 ¡Disfruta aprendiendo Data Engineering!" -ForegroundColor Green 