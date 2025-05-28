# aws-autodeploy-app

Este repositorio contiene la configuración de Terraform para desplegar la infraestructura del proyecto final de Telemática.

## 📦 Requisitos

- [Terraform](https://developer.hashicorp.com/terraform)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Credenciales configuradas con `aws configure` (ver sección siguiente)

## 🔐 Configurar Credenciales de AWS

Antes de ejecutar el script asegúrate de haber configurado las credenciales de AWS en tu entorno local:

```bash
aws configure
```

## 🔑 Modificar archivo main.tf

Modifica la línea 8 del archivo `main.tf` donde dice `public_key = file("ssh_public_key")`:

```terraform
public_key = file("ruta/a/tu/ssh_public_key")
```

## ⚙️ Brindar permisos de ejecución

```bash
chmod +x deploy.sh
chmod +x destroy.sh
```

## 🏗️ Levantar la infraestructura

```bash
./deploy.sh
```

## 🧨 Destruir la infraestructura

```bash
./destroy.sh
```
