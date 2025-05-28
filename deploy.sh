#!/bin/bash

echo "🚀 Iniciando despliegue de infraestructura con Terraform..."

# Verificar si Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform no está instalado. Por favor, instálalo antes de continuar."
    exit 1
fi

# Moverse al directorio donde está main.tf
cd infra || {
    echo "❌ No se encontró el directorio 'infra'."
    exit 1
}

# Inicializar Terraform
echo "🔧 Inicializando Terraform..."
terraform init

# Validar configuración
echo "✅ Validando archivos..."
terraform validate

# Planificar cambios
echo "📋 Planificando cambios..."
terraform plan -out=tfplan

# Aplicar cambios
echo "⚙️ Aplicando infraestructura..."
terraform apply tfplan

echo "✅ Despliegue completado."
