# Mac Local Translator Compilation and DMG Creation Guide

This guide explains how to compile the application and create a DMG file for distribution.

## Changes made

Changes were made to the project to make it easier to compile without external dependencies:

1. Removed problematic dependencies from the `Package.swift` file
2. Created stub implementations for:
- Whisper.cpp (speech recognition)
- LibreTranslate (translation)
3. Added a simplified Makefile to make it easier to compile and create the DMG

## 1. Compiling the project

### Requirements

- macOS 12.0 or later
- Xcode 14.0 or later with command line tools installed
- Swift 5.7 or later

### Steps

1. Clone the repository:
```bash
git clone https://github.com/nabz0r/mac-local-translator.git
cd mac-local-translator
```

2. Compiling in debug mode:
```bash
make -f Makefile.simple build
```

3. Release mode compilation:
```bash
make -f Makefile.simple release
```

## 2. Creating the DMG

### Option 1: DMG with placeholder

If you cannot compile the full application, you can create a DMG with a placeholder application:

```bash
make -f Makefile.simple dmg-placeholder
```

This command creates a DMG containing:
- A placeholder application that displays a message when launched
- A symbolic link to the Applications folder

### Option 2: DMG with the real application

If the compilation works correctly, you can create a DMG with the compiled application:

```bash
make -f Makefile.simple dmg
```

This command attempts to compile the application in release mode, then creates a DMG containing:
- The compiled application
- A symbolic link to the Applications folder

If the compilation fails, it automatically falls back to creating a DMG with placeholder.

## 3. DMG structure

After running one of the above commands, you will find the DMG file in the following location:

```
.build/MacLocalTranslator.dmg
```

You can mount this DMG by double-clicking on it, and then install the application by dragging it to the Applications folder.

## 4. Publishing a release

To publish the DMG to a GitHub release:

1. Go to your repository on GitHub
2. Go to the "Releases" section
3. Click "Draft a new release"
4. Create a tag for the release (e.g. v1.0.0)
5. Add a title and description
6. Upload the DMG file
7. Publish the release

## Troubleshooting

### If the build fails

If you encounter errors while building:

1. Make sure you have the correct version of Swift installed:
```bash
swift --version
```

2. Make sure the Xcode command line tools are installed:
```bash
xcode-select --install
```

3. For a quick DMG without compiling, use:
```bash
make -f Makefile.simple dmg-placeholder
```
