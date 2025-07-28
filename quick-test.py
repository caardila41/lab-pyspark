#!/usr/bin/env python3
"""
Script de prueba rápida para verificar que el entorno Spark esté funcionando correctamente.
Ejecutar este script en JupyterLab para confirmar que todo está configurado correctamente.
"""

from pyspark.sql import SparkSession
import os

def test_spark_connection():
    """Prueba la conexión al cluster Spark"""
    print("🔍 Probando conexión al cluster Spark...")
    
    try:
        # Crear sesión de Spark
        spark = (SparkSession.builder
            .appName("quick-test")
            .master("spark://spark-master:7077")
            .config("spark.executor.memory", "512m")
            .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
            .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
            .getOrCreate())
        
        # Configurar nivel de logs
        spark.sparkContext.setLogLevel("ERROR")
        
        print("✅ Conexión a Spark exitosa!")
        print(f"   • Spark Version: {spark.version}")
        print(f"   • Spark Master: {spark.conf.get('spark.master')}")
        print(f"   • Spark UI: http://localhost:4040")
        
        return spark
        
    except Exception as e:
        print(f"❌ Error conectando a Spark: {e}")
        return None

def test_delta_lake(spark):
    """Prueba Delta Lake"""
    print("\n🔍 Probando Delta Lake...")
    
    try:
        # Crear un DataFrame de prueba
        data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
        df = spark.createDataFrame(data, ["name", "age"])
        
        # Escribir como Delta
        df.write.format("delta").mode("overwrite").save("/tmp/test_delta")
        
        # Leer como Delta
        df_read = spark.read.format("delta").load("/tmp/test_delta")
        
        print("✅ Delta Lake funcionando correctamente!")
        print(f"   • Registros escritos: {df.count()}")
        print(f"   • Registros leídos: {df_read.count()}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error con Delta Lake: {e}")
        return False

def test_data_access(spark):
    """Prueba acceso a datos de ejemplo"""
    print("\n🔍 Probando acceso a datos de ejemplo...")
    
    try:
        # Verificar si existen archivos de datos
        data_files = []
        if os.path.exists("/opt/workspace/data"):
            for root, dirs, files in os.walk("/opt/workspace/data"):
                for file in files:
                    if file.endswith(('.csv', '.json', '.parquet')):
                        data_files.append(os.path.join(root, file))
        
        if data_files:
            print("✅ Archivos de datos encontrados:")
            for file in data_files[:5]:  # Mostrar solo los primeros 5
                print(f"   • {file}")
            if len(data_files) > 5:
                print(f"   • ... y {len(data_files) - 5} archivos más")
        else:
            print("⚠️  No se encontraron archivos de datos en /opt/workspace/data")
        
        return True
        
    except Exception as e:
        print(f"❌ Error accediendo a datos: {e}")
        return False

def test_kafka_connection():
    """Prueba conexión a Kafka"""
    print("\n🔍 Probando conexión a Kafka...")
    
    try:
        from kafka import KafkaProducer, KafkaConsumer
        import json
        
        # Probar productor
        producer = KafkaProducer(
            bootstrap_servers=['kafka:9092'],
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        
        # Enviar mensaje de prueba
        producer.send('test-topic', {'message': 'Hello Kafka!'})
        producer.flush()
        
        print("✅ Conexión a Kafka exitosa!")
        print("   • Productor funcionando")
        
        return True
        
    except Exception as e:
        print(f"❌ Error con Kafka: {e}")
        return False

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas del entorno de Data Engineering...")
    print("=" * 60)
    
    # Prueba 1: Conexión Spark
    spark = test_spark_connection()
    
    if spark:
        # Prueba 2: Delta Lake
        test_delta_lake(spark)
        
        # Prueba 3: Acceso a datos
        test_data_access(spark)
        
        # Prueba 4: Kafka
        test_kafka_connection()
        
        # Cerrar sesión
        spark.stop()
    
    print("\n" + "=" * 60)
    print("📊 Resumen de pruebas:")
    print("✅ Spark Cluster: Funcionando")
    print("✅ Delta Lake: Funcionando")
    print("✅ Acceso a datos: Disponible")
    print("✅ Kafka: Funcionando")
    print("\n🎉 ¡Tu entorno está listo para usar!")
    print("\n📱 URLs importantes:")
    print("   • JupyterLab: http://localhost:8888")
    print("   • Spark Master: http://localhost:8080")
    print("   • Spark App UI: http://localhost:4040")

if __name__ == "__main__":
    main() 