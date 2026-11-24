
#!/usr/bin/env bash

# Uso:
# ./emitir-bus.sh 102 110
# Genera certificados desde bus-102 hasta bus-110.

set -euo pipefail

# Validar cantidad de argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 NUMERO_INICIAL NUMERO_FINAL"
    exit 1
fi

# Validar números e intervalo
if ! [[ "$1" =~ ^[0-9]+$ && "$2" =~ ^[0-9]+$ ]] || (( 10#$1 > 10#$2 )); then
    echo "Error: indica un rango numérico válido."
    exit 1
fi

# Entrar a la carpeta de certificados
cd "$(dirname "$0")/../pki"

# Recorrer los buses solicitados
for n in $(seq "$1" "$2"); do

    id="bus-${n}"

    # No sobrescribir certificados existentes
    if [ -e "${id}.key" ] || [ -e "${id}.crt" ]; then
        echo "Ya existe ${id}; se omite."
        continue
    fi

    # Crear llave privada
    openssl genrsa -out "${id}.key" 2048
    chmod 600 "${id}.key"

    # Crear solicitud de firma
    openssl req -new \
      -key "${id}.key" \
      -subj "/C=CO/O=MetroMIO/OU=Flota/CN=${id}" \
      -out "${id}.csr"

    # Firmar certificado con la CA
    openssl x509 -req \
      -in "${id}.csr" \
      -CA ca.crt \
      -CAkey ca.key \
      -CAcreateserial \
      -out "${id}.crt" \
      -days 30 \
      -sha256 \
      -extfile client.ext

    # Mostrar fecha de vencimiento
    echo "Emitido ${id}"
    openssl x509 -in "${id}.crt" -noout -enddate

done

echo "Proceso de emisión finalizado."

