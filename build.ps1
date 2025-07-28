# Build Apache Spark Standalone Cluster Docker Images
# PowerShell version of build.sh

# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------

$BUILD_DATE = Get-Date -Format "yyyy-MM-dd"
$SPARK_VERSION = "3.4.1"
$HADOOP_VERSION = "3"
$DELTA_SPARK_VERSION = "2.4.0"
$DELTALAKE_VERSION = "0.10.0"
$JUPYTERLAB_VERSION = "4.0.2"
$PANDAS_VERSION = "2.0.1"
$DELTA_PACKAGE_VERSION = "delta-core_2.12:2.4.0"
$SPARK_VERSION_MAJOR = $SPARK_VERSION.Substring(0,1)
$SPARK_XML_PACKAGE_VERSION = "spark-xml_2.12:0.16.0"
$SPARKSQL_MAGIC_VERSION = "0.0.3"
$KAFKA_PYTHON_VERSION = "2.0.2"

# ----------------------------------------------------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------------------------------------------------

function Clean-Containers {
    Write-Host "Cleaning containers..." -ForegroundColor Yellow
    
    # Stop and remove jupyterlab container
    $container = docker ps -a --filter "name=jupyterlab" --format "{{.ID}}"
    if ($container) {
        docker stop $container
        docker rm $container
    }
    
    # Stop and remove spark-worker containers
    $workers = docker ps -a --filter "name=spark-worker" --format "{{.ID}}"
    foreach ($worker in $workers) {
        docker stop $worker
        docker rm $worker
    }
    
    # Stop and remove spark-master container
    $container = docker ps -a --filter "name=spark-master" --format "{{.ID}}"
    if ($container) {
        docker stop $container
        docker rm $container
    }
    
    # Stop and remove spark-base container
    $container = docker ps -a --filter "name=spark-base" --format "{{.ID}}"
    if ($container) {
        docker stop $container
        docker rm $container
    }
    
    # Stop and remove base container
    $container = docker ps -a --filter "name=base" --format "{{.ID}}"
    if ($container) {
        docker stop $container
        docker rm $container
    }
}

function Clean-Images {
    Write-Host "Cleaning images..." -ForegroundColor Yellow
    
    # Remove jupyterlab image
    $image = docker images --filter "reference=jupyterlab" --format "{{.ID}}"
    if ($image) {
        docker rmi -f $image
    }
    
    # Remove spark-worker image
    $image = docker images --filter "reference=spark-worker" --format "{{.ID}}"
    if ($image) {
        docker rmi -f $image
    }
    
    # Remove spark-master image
    $image = docker images --filter "reference=spark-master" --format "{{.ID}}"
    if ($image) {
        docker rmi -f $image
    }
    
    # Remove spark-base image
    $image = docker images --filter "reference=spark-base" --format "{{.ID}}"
    if ($image) {
        docker rmi -f $image
    }
    
    # Remove base image
    $image = docker images --filter "reference=base" --format "{{.ID}}"
    if ($image) {
        docker rmi -f $image
    }
}

function Clean-Volume {
    Write-Host "Cleaning volume..." -ForegroundColor Yellow
    docker volume rm "distributed-file-system" -ErrorAction SilentlyContinue
}

function Build-Images {
    Write-Host "Building images..." -ForegroundColor Green
    
    # Build base image
    Write-Host "Building base image..." -ForegroundColor Cyan
    docker build `
        --build-arg build_date="$BUILD_DATE" `
        --build-arg delta_spark_version="$DELTA_SPARK_VERSION" `
        --build-arg deltalake_version="$DELTALAKE_VERSION" `
        --build-arg pandas_version="$PANDAS_VERSION" `
        -f docker/base/Dockerfile `
        -t base:latest .
    
    # Build spark-base image
    Write-Host "Building spark-base image..." -ForegroundColor Cyan
    docker build `
        --build-arg build_date="$BUILD_DATE" `
        --build-arg spark_version="$SPARK_VERSION" `
        --build-arg hadoop_version="$HADOOP_VERSION" `
        --build-arg delta_package_version="$DELTA_PACKAGE_VERSION" `
        --build-arg spark_xml_package_version="$SPARK_XML_PACKAGE_VERSION" `
        -f docker/spark-base/Dockerfile `
        -t spark-base:$SPARK_VERSION .
    
    # Build spark-master image
    Write-Host "Building spark-master image..." -ForegroundColor Cyan
    docker build `
        --build-arg build_date="$BUILD_DATE" `
        --build-arg spark_version="$SPARK_VERSION" `
        -f docker/spark-master/Dockerfile `
        -t spark-master:$SPARK_VERSION .
    
    # Build spark-worker image
    Write-Host "Building spark-worker image..." -ForegroundColor Cyan
    docker build `
        --build-arg build_date="$BUILD_DATE" `
        --build-arg spark_version="$SPARK_VERSION" `
        -f docker/spark-worker/Dockerfile `
        -t spark-worker:$SPARK_VERSION .
    
    # Build jupyterlab image
    Write-Host "Building jupyterlab image..." -ForegroundColor Cyan
    docker build `
        --build-arg build_date="$BUILD_DATE" `
        --build-arg spark_version="$SPARK_VERSION" `
        --build-arg jupyterlab_version="$JUPYTERLAB_VERSION" `
        --build-arg sparksql_magic_version="$SPARKSQL_MAGIC_VERSION" `
        --build-arg kafka_python_version="$KAFKA_PYTHON_VERSION" `
        -f docker/jupyterlab/Dockerfile `
        -t jupyterlab:$JUPYTERLAB_VERSION-spark-$SPARK_VERSION .
}

# ----------------------------------------------------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------------------------------------------------

Write-Host "🚀 Starting Docker image build process..." -ForegroundColor Green
Write-Host "Build Date: $BUILD_DATE" -ForegroundColor Yellow
Write-Host "Spark Version: $SPARK_VERSION" -ForegroundColor Yellow
Write-Host "Delta Spark Version: $DELTA_SPARK_VERSION" -ForegroundColor Yellow

try {
    Clean-Containers
    Clean-Images
    Clean-Volume
    Build-Images
    
    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Built images:" -ForegroundColor Cyan
    docker images --filter "reference=base" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    docker images --filter "reference=spark-base" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    docker images --filter "reference=spark-master" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    docker images --filter "reference=spark-worker" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    docker images --filter "reference=jupyterlab" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    Write-Host ""
    Write-Host "🎉 Ready to start the environment with: docker-compose up -d" -ForegroundColor Green
}
catch {
    Write-Host "❌ Build failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 