#!/bin/bash

# Script para renombrar carpetas del formato "dd de mes de yyyy" a "yyyymmdd"

# Función para convertir mes en español a número
get_month_number() {
  case "$1" in
  "enero") echo "01" ;;
  "febrero") echo "02" ;;
  "marzo") echo "03" ;;
  "abril") echo "04" ;;
  "mayo") echo "05" ;;
  "junio") echo "06" ;;
  "julio") echo "07" ;;
  "agosto") echo "08" ;;
  "septiembre") echo "09" ;;
  "octubre") echo "10" ;;
  "noviembre") echo "11" ;;
  "diciembre") echo "12" ;;
  *) echo "00" ;;
  esac
}

# Función para formatear el día con ceros a la izquierda
format_day() {
  printf "%02d" "$1"
}

# Contador de carpetas procesadas
count=0
errors=0

echo "Iniciando proceso de renombrado de carpetas..."
echo "============================================="

# Procesar todas las carpetas que coincidan con el patrón
for dir in */; do
  # Remover la barra final
  dir_name="${dir%/}"

  # Verificar si el directorio coincide con el patrón esperado
  if [[ "$dir_name" =~ ^([0-9]{1,2})\ de\ ([a-z]+)\ de\ ([0-9]{4})$ ]]; then
    day="${BASH_REMATCH[1]}"
    month_name="${BASH_REMATCH[2]}"
    year="${BASH_REMATCH[3]}"

    # Convertir mes a número
    month_num=$(get_month_number "$month_name")

    if [ "$month_num" = "00" ]; then
      echo "❌ Error: Mes no reconocido '$month_name' en '$dir_name'"
      ((errors++))
      continue
    fi

    # Formatear día con ceros a la izquierda
    day_formatted=$(format_day "$day")

    # Crear nuevo nombre
    new_name="${year}${month_num}${day_formatted}"

    # Verificar si el directorio destino ya existe
    if [ -d "$new_name" ]; then
      echo "⚠️  Advertencia: El directorio '$new_name' ya existe. Saltando '$dir_name'"
      continue
    fi

    # Renombrar el directorio
    if mv "$dir_name" "$new_name"; then
      echo "✅ '$dir_name' → '$new_name'"
      ((count++))
    else
      echo "❌ Error al renombrar '$dir_name'"
      ((errors++))
    fi
  else
    echo "⏭️  Saltando '$dir_name' (no coincide con el patrón)"
  fi
done

echo "============================================="
echo "Proceso completado:"
echo "📁 Carpetas renombradas: $count"
if [ $errors -gt 0 ]; then
  echo "❌ Errores encontrados: $errors"
else
  echo "✅ Sin errores"
fi
