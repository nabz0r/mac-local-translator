#!/bin/bash

# Script pour télécharger les modèles de base pour Mac Local Translator
#
# Ce script télécharge les modèles de reconnaissance vocale et de traduction
# nécessaires au fonctionnement de l'application.

# Couleurs pour les messages
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Répertoire des modèles
MODELS_DIR="$HOME/Library/Application Support/MacLocalTranslator/models"

# URLs des modèles (dans une version réelle, ces URL seraient valides)
MODEL_URLS=(
    "https://example.com/models/whisper-medium-1.0.bin"
    "https://example.com/models/libre-translate-en-fr-1.0.bin"
    "https://example.com/models/libre-translate-fr-en-1.0.bin"
    "https://example.com/models/libre-translate-en-es-1.0.bin"
    "https://example.com/models/libre-translate-es-en-1.0.bin"
)

# Noms des fichiers correspondants
MODEL_NAMES=(
    "whisper-medium-1.0.bin"
    "libre-translate-en-fr-1.0.bin"
    "libre-translate-fr-en-1.0.bin"
    "libre-translate-en-es-1.0.bin"
    "libre-translate-es-en-1.0.bin"
)

# Tailles des modèles (en Mo) pour l'affichage de la progression
MODEL_SIZES=(
    1500
    450
    450
    450
    450
)

# Crée le répertoire des modèles s'il n'existe pas
mkdir -p "$MODELS_DIR"

echo -e "${GREEN}=== Téléchargement des modèles de Mac Local Translator ===${NC}\n"
echo -e "Les modèles seront téléchargés dans: ${YELLOW}$MODELS_DIR${NC}\n"

# Fonction pour vérifier si un modèle existe déjà
model_exists() {
    local model_path="$MODELS_DIR/$1"
    if [ -f "$model_path" ]; then
        echo -e "${YELLOW}Le modèle $1 existe déjà.${NC}"
        return 0
    else
        return 1
    fi
}

# Fonction pour simuler un téléchargement (dans une version réelle, utiliserait curl ou wget)
simulate_download() {
    local url=$1
    local output=$2
    local size=$3
    
    echo -e "\nSimulation du téléchargement de: ${YELLOW}$output${NC} (${size} Mo)"
    echo -e "URL: $url"
    
    # Crée un fichier vide
    touch "$output"
    
    # Simule la progression du téléchargement
    for i in {1..10}; do
        echo -ne "[";
        for j in $(seq 1 $i); do echo -ne "#"; done
        for j in $(seq $i 9); do echo -ne " "; done
        echo -ne "] $((i*10))%\r"
        sleep 0.5
    done
    
    echo -e "\n${GREEN}Téléchargement terminé: $output${NC}"
    
    # Dans une version réelle, on utiliserait:
    # curl -L "$url" -o "$output" --progress-bar
    # ou
    # wget "$url" -O "$output" --show-progress
}

# Télécharge chaque modèle
for i in "${!MODEL_URLS[@]}"; do
    model_name=${MODEL_NAMES[$i]}
    model_path="$MODELS_DIR/$model_name"
    
    if ! model_exists "$model_name"; then
        simulate_download "${MODEL_URLS[$i]}" "$model_path" "${MODEL_SIZES[$i]}"
    fi
done

echo -e "\n${GREEN}=== Téléchargement des modèles terminé ===${NC}"

# Liste les modèles disponibles
echo -e "\n${YELLOW}Modèles disponibles:${NC}"
ls -lh "$MODELS_DIR" | grep -v '^total' | awk '{print $9, "(" $5 ")"}'

echo -e "\n${GREEN}Vous pouvez maintenant lancer MacLocalTranslator.${NC}"
