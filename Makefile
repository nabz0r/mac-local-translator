# Makefile pour Mac Local Translator

# Variables
PRODUCT_NAME = MacLocalTranslator
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DEBUG_DIR = $(BUILD_DIR)/debug
RESOURCES_DIR = resources
SWIFT = swift

# Cibles principales
.PHONY: all clean build test run package

all: build

# Construit le projet
build:
	@echo "Construction de $(PRODUCT_NAME)..."
	$(SWIFT) build

# Construction en mode release
release:
	@echo "Construction de $(PRODUCT_NAME) en mode release..."
	$(SWIFT) build -c release --disable-sandbox

# Exécute les tests
test:
	@echo "Exécution des tests..."
	$(SWIFT) test

# Exécute l'application
run: build
	@echo "Lancement de $(PRODUCT_NAME)..."
	$(SWIFT) run

# Nettoie les fichiers de construction
clean:
	@echo "Nettoyage des fichiers de construction..."
	$(SWIFT) package clean
	 rm -rf $(BUILD_DIR)

# Prépare un package DMG
package: release
	@echo "Création du package DMG..."
	@mkdir -p $(BUILD_DIR)/dmg
	@cp -R $(RELEASE_DIR)/$(PRODUCT_NAME) $(BUILD_DIR)/dmg/
	@cp -R $(RESOURCES_DIR)/models $(BUILD_DIR)/dmg/
	@echo "Le DMG peut maintenant être créé avec Disk Utility ou hdiutil"

# Crée un nouveau tag Git (usage: make tag version=X.Y.Z)
tag:
	@[ "$(version)" ] || ( echo "Spécifiez une version avec 'make tag version=X.Y.Z'"; exit 1 )
	@echo "Création du tag v$(version)..."
	@git tag -a v$(version) -m "Version $(version)"
	@echo "Pour pousser le tag au dépôt distant, exécutez: git push origin v$(version)"

# Télécharge les modèles nécessaires
download-models:
	@echo "Téléchargement des modèles..."
	@chmod +x scripts/download_models.sh
	@./scripts/download_models.sh

# Exécute l'analyse de code
lint:
	@echo "Analyse du code avec SwiftLint..."
	@command -v swiftlint >/dev/null 2>&1 || { echo "SwiftLint n'est pas installé. Installez-le via 'brew install swiftlint'."; exit 1; }
	swiftlint

# Génère la documentation
docs:
	@echo "Génération de la documentation..."
	@command -v jazzy >/dev/null 2>&1 || { echo "Jazzy n'est pas installé. Installez-le via 'gem install jazzy'."; exit 1; }
	jazzy

# Affiche l'aide
help:
	@echo "Cibles disponibles:"
	@echo "  all         - Construit l'application"
	@echo "  build       - Construit l'application en mode debug"
	@echo "  release     - Construit l'application en mode release"
	@echo "  test        - Exécute les tests unitaires"
	@echo "  run         - Exécute l'application"
	@echo "  clean       - Nettoie les fichiers de construction"
	@echo "  package     - Prépare un package DMG"
	@echo "  tag         - Crée un nouveau tag Git (usage: make tag version=X.Y.Z)"
	@echo "  download-models - Télécharge les modèles nécessaires"
	@echo "  lint        - Exécute l'analyse de code avec SwiftLint"
	@echo "  docs        - Génère la documentation avec Jazzy"
	@echo "  help        - Affiche cette aide"
