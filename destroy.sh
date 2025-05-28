#!/bin/bash

echo "🔄 Destruyendo la infraestructura con Terraform..."

cd infra || { echo "❌ No se encontró la carpeta infra/"; exit 1; }

terraform destroy -auto-approve

echo "✅ Infraestructura destruida."
