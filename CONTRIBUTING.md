# Contributing to Mac Local Translator

Thank you for your interest in contributing to Mac Local Translator! This document provides guidelines for contributing to the project and ensuring an efficient collaborative development process.

## Contributing Process

### Reporting Bugs

If you have identified a bug or issue:

1. Check that the bug has not already been reported in GitHub issues.

2. Use the bug report template to create a new issue.

3. Include detailed reproduction steps and, if possible, screenshots.

4. Mention your environment (OS, macOS version, etc.).

### Suggesting Improvements

To propose new features or improvements:

1. Open an issue using the feature request template.

2. Clearly describe the feature, its use case, and how it fits into the project.

3. If possible, indicate the components that will need to be changed.

### Submitting changes

To contribute code:

1. Fork the repository and create a branch from `main`.
2. Name your branch descriptively (e.g. `feature/new-translation-engine` or `fix/audio-recording-issue`).
3. Follow the coding conventions listed below.
4. Make sure your tests cover your changes.
5. Create a Pull Request with a clear description of your changes.

## Coding conventions

### Code style

- Follow Apple's [Swift style guide](https://swift.org/documentation/api-design-guidelines/).
- Use 4 spaces for indentation (no tabs).
- Limit lines to 100 characters when reasonable.
- Organize your code with MARK marks to improve readability.

### Documentation

- Document all public methods and properties with Xcode-compatible comments (///).
- Explain the "why" rather than the "what" in your comments.
- Update user documentation as needed.

### Testing

- Write unit tests for new features.
- Maintain test coverage at an acceptable level.
- Run tests before submitting a PR.

## Project Architecture

Mac Local Translator follows a modular architecture with the following main components:

- **Models**: Contains data structures and business logic.
- **Views**: Implements the user interface with SwiftUI.
- **Services**: Handles specific features (audio, speech recognition, translation).
- **Coordinator**: Orchestrates interactions between services.
- **Utils**: Provides reusable utilities and extensions.

When implementing new features, respect this separation of responsibilities.

## Development environment setup

### Prerequisites

- macOS 12.0 or newer
- Xcode 14.0 or newer
- Swift 5.7 or newer

### Recommended tools

- [SwiftLint](https://github.com/realm/SwiftLint) to analyze the code
- [Jazzy](https://github.com/realm/jazzy) to generate the documentation

### Initial setup

1. Clone the repository: `git clone https://github.com/nabz0r/mac-local-translator.git`
2. Run `make download-models` to download the required models
3. Open the project in Xcode or use `swift build` to compile

## Release process

The project follows semantic versioning (MAJOR.MINOR.PATCH):

- MAJOR: changes incompatible with previous versions
- MINOR: Backward compatible feature additions
- PATCH: Backward compatible bug fixes

Continuous integration is configured to automatically build and test Pull Requests and tags. Builds are automatically published when a new tag is created.

## Communication

- Use GitHub issues for technical discussions.
- Maintain a respectful and professional tone in all communications.
- For longer discussions, consider using GitHub discussions.

## License

By contributing to this project, you agree that your contributions are licensed under the same license as the project (MIT).

Thank you for contributing to Mac Local Translator!
