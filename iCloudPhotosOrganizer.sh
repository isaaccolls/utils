#!/bin/bash

# Script para organizar fotos de iCloud por fecha de captura
# Organiza archivos desde /home/isaac/Downloads/iCloud Photos
# hacia /home/isaac/Downloads/NewPhotos/yyyymmdd/

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directorios
SOURCE_DIR="/home/isaac/Downloads/iCloud Photos"
DEST_DIR="/home/isaac/Downloads/NewPhotos"

echo -e "${BLUE}🚀 iCloud Photos Organizer${NC}"
echo "=================================================="

# Verificar si exiftool está instalado
if ! command -v exiftool &> /dev/null; then
    echo -e "${RED}❌ Error: exiftool no está instalado${NC}"
    echo -e "${YELLOW}Instalando exiftool...${NC}"
    sudo apt-get update
    sudo apt-get install -y libimage-exiftool-perl
    
    if ! command -v exiftool &> /dev/null; then
        echo -e "${RED}❌ Error: No se pudo instalar exiftool${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ exiftool instalado correctamente${NC}"
fi

# Verificar si el directorio fuente existe
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Error: Directorio fuente no encontrado: $SOURCE_DIR${NC}"
    exit 1
fi

# Crear directorio destino si no existe
mkdir -p "$DEST_DIR"

echo -e "${BLUE}📁 Procesando archivos desde: $SOURCE_DIR${NC}"
echo -e "${BLUE}📁 Destino: $DEST_DIR${NC}"
echo "=================================================="

# Contadores
total_files=0
processed_files=0
failed_files=0

# Función para obtener fecha de captura
get_capture_date() {
    local file="$1"
    local date_str=""
    
    # Intentar extraer diferentes campos de fecha según el tipo de archivo
    case "${file,,}" in
        *.jpg|*.jpeg|*.png|*.tiff|*.tif)
            # Para imágenes, intentar DateTimeOriginal primero, luego CreateDate
            date_str=$(exiftool -DateTimeOriginal -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreateDate -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            fi
            ;;
        *.heic)
            # Para HEIC, intentar DateTimeOriginal o CreationDate
            date_str=$(exiftool -DateTimeOriginal -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreationDate -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            fi
            ;;
        *.mov|*.mp4|*.avi|*.mkv)
            # Para videos, intentar CreationDate o MediaCreateDate
            date_str=$(exiftool -CreationDate -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -MediaCreateDate -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            fi
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreateDate -d "%Y%m%d" -S -s "$file" 2>/dev/null)
            fi
            ;;
    esac
    
    echo "$date_str"
}

# Función para mostrar fecha de captura legible
get_readable_date() {
    local file="$1"
    local date_str=""
    
    case "${file,,}" in
        *.jpg|*.jpeg|*.png|*.tiff|*.tif)
            date_str=$(exiftool -DateTimeOriginal -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreateDate -S -s "$file" 2>/dev/null)
            fi
            ;;
        *.heic)
            date_str=$(exiftool -DateTimeOriginal -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreationDate -S -s "$file" 2>/dev/null)
            fi
            ;;
        *.mov|*.mp4|*.avi|*.mkv)
            date_str=$(exiftool -CreationDate -S -s "$file" 2>/dev/null)
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -MediaCreateDate -S -s "$file" 2>/dev/null)
            fi
            if [ -z "$date_str" ]; then
                date_str=$(exiftool -CreateDate -S -s "$file" 2>/dev/null)
            fi
            ;;
    esac
    
    echo "$date_str"
}

# Procesar cada archivo en el directorio fuente
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    total_files=$((total_files + 1))
    
    echo -e "\n${YELLOW}📷 Procesando: $filename${NC}"
    
    # Obtener fecha de captura
    capture_date=$(get_capture_date "$file")
    readable_date=$(get_readable_date "$file")
    
    if [ -n "$capture_date" ] && [ "$capture_date" != "" ]; then
        echo -e "   ${GREEN}📅 Created On: $readable_date${NC}"
        
        # Crear directorio destino basado en la fecha
        date_dir="$DEST_DIR/$capture_date"
        mkdir -p "$date_dir"
        
        # Copiar archivo al directorio correspondiente
        if cp "$file" "$date_dir/"; then
            echo -e "   ${GREEN}✅ Copiado a: $date_dir/${NC}"
            processed_files=$((processed_files + 1))
        else
            echo -e "   ${RED}❌ Error al copiar archivo${NC}"
            failed_files=$((failed_files + 1))
        fi
    else
        echo -e "   ${RED}❌ No se pudo extraer fecha de captura${NC}"
        # Mover a carpeta "unknown" para archivos sin fecha
        unknown_dir="$DEST_DIR/unknown"
        mkdir -p "$unknown_dir"
        if cp "$file" "$unknown_dir/"; then
            echo -e "   ${YELLOW}📁 Copiado a carpeta 'unknown'${NC}"
        fi
        failed_files=$((failed_files + 1))
    fi
done < <(find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.mov" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.tiff" -o -iname "*.tif" \) -print0)

echo -e "\n=================================================="
echo -e "${BLUE}📊 Resumen de procesamiento:${NC}"
echo -e "${GREEN}✅ Archivos procesados exitosamente: $processed_files${NC}"
echo -e "${RED}❌ Archivos con errores: $failed_files${NC}"
echo -e "${BLUE}📁 Archivos organizados en: $DEST_DIR${NC}"
echo -e "${GREEN}🎉 ¡Proceso completado!${NC}"