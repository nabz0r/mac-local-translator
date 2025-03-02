# Guide de compilation et création du DMG pour Mac Local Translator

Ce guide explique comment compiler l'application et créer un fichier DMG pour la distribution.

## Modifications apportées

Des modifications ont été apportées au projet pour faciliter la compilation sans dépendances externes :

1. Les dépendances problématiques ont été retirées du fichier `Package.swift`
2. Des implémentations de substitution (stubs) ont été créées pour :
   - Whisper.cpp (reconnaissance vocale)
   - LibreTranslate (traduction)
3. Un Makefile simplifié a été ajouté pour faciliter la compilation et la création du DMG

## 1. Compilation du projet

### Prérequis

- macOS 12.0 ou supérieur
- Xcode 14.0 ou supérieur avec les outils en ligne de commande installés
- Swift 5.7 ou supérieur

### Étapes

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/nabz0r/mac-local-translator.git
   cd mac-local-translator
   ```

2. Compilation en mode debug :
   ```bash
   make -f Makefile.simple build
   ```

3. Compilation en mode release :
   ```bash
   make -f Makefile.simple release
   ```

## 2. Création du DMG

### Option 1 : DMG avec placeholder

Si vous ne pouvez pas compiler l'application complète, vous pouvez créer un DMG avec une application placeholder :

```bash
make -f Makefile.simple dmg-placeholder
```

Cette commande crée un DMG contenant :
- Une application placeholder qui affiche un message lorsqu'elle est lancée
- Un lien symbolique vers le dossier Applications

### Option 2 : DMG avec l'application réelle

Si la compilation fonctionne correctement, vous pouvez créer un DMG avec l'application compilée :

```bash
make -f Makefile.simple dmg
```

Cette commande tente de compiler l'application en mode release, puis crée un DMG contenant :
- L'application compilée
- Un lien symbolique vers le dossier Applications

Si la compilation échoue, elle revient automatiquement à la création d'un DMG avec placeholder.

## 3. Structure du DMG

Après avoir exécuté l'une des commandes ci-dessus, vous trouverez le fichier DMG à l'emplacement suivant :

```
.build/MacLocalTranslator.dmg
```

Vous pouvez monter ce DMG en double-cliquant dessus, puis installer l'application en la faisant glisser vers le dossier Applications.

## 4. Publication d'une release

Pour publier le DMG dans une release GitHub :

1. Accédez à votre dépôt sur GitHub
2. Allez dans la section "Releases"
3. Cliquez sur "Draft a new release"
4. Créez un tag pour la version (ex: v1.0.0)
5. Ajoutez un titre et une description
6. Téléversez le fichier DMG
7. Publiez la release

## Dépannage

### Si la compilation échoue

Si vous rencontrez des erreurs lors de la compilation :

1. Vérifiez que vous avez la bonne version de Swift installée :
   ```bash
   swift --version
   ```

2. Assurez-vous que les outils en ligne de commande Xcode sont installés :
   ```bash
   xcode-select --install
   ```

3. Pour un DMG rapide sans compilation, utilisez :
   ```bash
   make -f Makefile.simple dmg-placeholder
   ```