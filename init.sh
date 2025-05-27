#!/bin/bash

# init.sh

echo "Selecciona la herramienta a usar:"
echo "1) Docker"
echo "2) Podman"
read -p "Ingresa el número (1 o 2): " choice

case $choice in
    1)
        if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
            echo "Usando Docker..."
            COMPOSE_CMD="docker-compose"
        else
            echo "Error: Docker o docker-compose no están instalados."
            exit 1
        fi
        ;;
    2)
        if command -v podman &> /dev/null && command -v podman-compose &> /dev/null; then
            echo "Usando Podman..."
            COMPOSE_CMD="podman-compose"
        else
            echo "Error: Podman o podman-compose no están instalados."
            exit 1
        fi
        ;;
    *)
        echo "Error: Selección inválida. Por favor, elige 1 (Docker) o 2 (Podman)."
        exit 1
        ;;
esac

# Ejecutar el comando compose
$COMPOSE_CMD up -d --build

# Mostrar estado de los contenedores
if [ "$COMPOSE_CMD" = "docker-compose" ]; then
    docker ps
else
    podman ps
fi
