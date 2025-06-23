#!/bin/bash

# Script om creation date uit Google Photos JSON metadata te halen
# en toe te passen op de bijbehorende foto bestanden

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functie om help te tonen
show_help() {
    echo "Gebruik: $0 [OPTIE]"
    echo ""
    echo "Opties:"
    echo "  -d, --directory DIR    Specifieke directory om te verwerken (standaard: huidige directory)"
    echo "  -n, --dry-run         Toon wat er zou gebeuren zonder daadwerkelijke wijzigingen"
    echo "  -v, --verbose         Uitgebreide output"
    echo "  -h, --help            Toon deze help"
    echo ""
    echo "Dit script zoekt naar JSON metadata bestanden van Google Photos"
    echo "en past de creation date toe op de bijbehorende foto bestanden."
}

# Standaard waarden
DIRECTORY="."
DRY_RUN=false
VERBOSE=false

# Parse command line argumenten
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            DIRECTORY="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Onbekende optie: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Controleer of jq geïnstalleerd is
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is niet geïnstalleerd. Installeer het met:${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS: brew install jq"
    echo "  CentOS/RHEL: sudo yum install jq"
    exit 1
fi

# Controleer of de directory bestaat
if [[ ! -d "$DIRECTORY" ]]; then
    echo -e "${RED}Error: Directory '$DIRECTORY' bestaat niet.${NC}"
    exit 1
fi

echo -e "${GREEN}Google Photos Metadata Date Sync Script${NC}"
echo "Directory: $DIRECTORY"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN MODE - Geen wijzigingen worden doorgevoerd${NC}"
fi
echo ""

# Tellers
processed=0
success=0
errors=0

# Zoek naar foto bestanden (niet JSON)
while IFS= read -r -d '' photo_file; do
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${YELLOW}Verwerken: $photo_file${NC}"
    fi
    
    # Bepaal de bijbehorende JSON metadata naam
    photo_basename=$(basename "$photo_file")
    json_file=""
    
    # Zoek naar bijbehorende JSON bestanden met verschillende extensies
    # Probeer verschillende patronen gebaseerd op foto naam
    possible_json_files=(
        "$DIRECTORY/${photo_basename}.json"
        "$DIRECTORY/${photo_basename}.suppl.json"
        "$DIRECTORY/${photo_basename}.supplemental-metadata.json"
    )
    
    # Zoek ook naar JSON bestanden die beginnen met de foto naam
    while IFS= read -r -d '' candidate_json; do
        candidate_basename=$(basename "$candidate_json")
        if [[ "$candidate_basename" == "${photo_basename}"* ]]; then
            possible_json_files+=("$candidate_json")
        fi
    done < <(find "$DIRECTORY" -name "${photo_basename}*.json" -print0 2>/dev/null)
    
    # Vind het eerste bestaande JSON bestand
    for json_candidate in "${possible_json_files[@]}"; do
        if [[ -f "$json_candidate" ]]; then
            json_file="$json_candidate"
            break
        fi
    done
    
    # Controleer of JSON bestand gevonden is
    if [[ -z "$json_file" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${YELLOW}Geen JSON metadata gevonden voor: $photo_basename${NC}"
        fi
        continue
    fi
    
    # Haal timestamp uit JSON
    timestamp=""
    
    # Probeer eerst photoTakenTime
    timestamp=$(jq -r '.photoTakenTime.timestamp // empty' "$json_file" 2>/dev/null)
    
    # Als photoTakenTime niet bestaat, probeer creationTime
    if [[ -z "$timestamp" ]]; then
        timestamp=$(jq -r '.creationTime.timestamp // empty' "$json_file" 2>/dev/null)
    fi
    
    if [[ -z "$timestamp" || "$timestamp" == "null" ]]; then
        echo -e "${RED}Geen geldige timestamp gevonden in: $json_file${NC}"
        ((errors++))
        continue
    fi
    
    # Converteer timestamp naar datum formaat voor touch
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date_format=$(date -r "$timestamp" "+%Y%m%d%H%M.%S" 2>/dev/null)
    else
        # Linux
        date_format=$(date -d "@$timestamp" "+%Y%m%d%H%M.%S" 2>/dev/null)
    fi
    
    if [[ -z "$date_format" ]]; then
        echo -e "${RED}Kon timestamp niet converteren: $timestamp${NC}"
        ((errors++))
        continue
    fi
    
    # Toon wat er gebeurt
    readable_date=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        readable_date=$(date -r "$timestamp" "+%d-%m-%Y %H:%M:%S" 2>/dev/null)
    else
        readable_date=$(date -d "@$timestamp" "+%d-%m-%Y %H:%M:%S" 2>/dev/null)
    fi
    
    echo -e "${GREEN}✓${NC} $(basename "$photo_file") -> $readable_date"
    
    # Pas datum toe (tenzij dry-run)
    if [[ "$DRY_RUN" == false ]]; then
        if touch -t "$date_format" "$photo_file"; then
            ((success++))
        else
            echo -e "${RED}Fout bij instellen datum voor: $photo_file${NC}"
            ((errors++))
        fi
    else
        ((success++))
    fi
    
    ((processed++))
    
done < <(find "$DIRECTORY" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.heic" \) -print0)

echo ""
echo -e "${GREEN}=== SAMENVATTING ===${NC}"
echo "Verwerkte bestanden: $processed"
echo -e "${GREEN}Succesvol: $success${NC}"
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}Fouten: $errors${NC}"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}Dit was een dry-run. Voer het script opnieuw uit zonder -n om wijzigingen door te voeren.${NC}"
fi
