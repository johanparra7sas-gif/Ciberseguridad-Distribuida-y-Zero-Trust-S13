
#!/usr/bin/env bash

# Taller Sesión 13 - Día 6
# Matriz de conectividad AgroSugar

probar() {
    local origen="$1"
    local destino="$2"
    local puerto="$3"

    if kubectl -n agrosugar exec "$origen" -- \
        nc -z -w 3 "$destino" "$puerto" \
        >/dev/null 2>&1
    then
        echo "$origen -> $destino:$puerto PERMITIDO"
    else
        echo "$origen -> $destino:$puerto BLOQUEADO"
    fi
}

echo "================================"
echo " MATRIZ DE CONECTIVIDAD AGROSUGAR"
echo "================================"

probar sensor-hidratacion-01 mqtt-broker 1883

probar sensor-hidratacion-01 db-transaccional 5432

probar intruso mqtt-broker 1883

probar intruso db-transaccional 5432

echo "================================"
