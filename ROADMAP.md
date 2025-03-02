# Mac Local Translator Roadmap

This document presents the long-term vision and development goals for Mac Local Translator. This is a living document that will be updated as the project progresses.

## Version 1.0.0 (Base)

### Main features

- [x] Basic user interface with SwiftUI
- [x] Audio recording from microphone
- [x] Voice activity and silence detection
- [x] Basic integration of Whisper.cpp for speech recognition
- [x] Basic integration of LibreTranslate for translation
- [x] Speech synthesis via AVSpeechSynthesizer
- [x] Display conversations with original and translated text
- [x] Selection of source and target languages
- [x] Basic settings for configuring preferences

### Technical improvements

- [x] Modular and extensible architecture
- [x] Template management (upload, selection, etc.)
- [x] Continuous integration configuration
- [x] Basic unit tests
- [x] Code and architecture documentation

## Version 1.1.0 (Optimizations)

### Features to implement

- [ ] Support for more languages ​​(at least 8-10 major languages)
- [ ] Semi-continuous translation mode (partial translation while the user is speaking)
- [ ] Improved UI with more visual indicators
- [ ] Customizable themes (light/dark/system)
- [ ] Export conversations to text and audio

### Technical optimizations

- [ ] Model quantization to reduce memory footprint
- [ ] GPU acceleration for speech recognition and translation
- [ ] Optimization of data streams to reduce latency
- [ ] Caching of frequent translation results
- [ ] Performance tests and benchmarks

## Version 1.2.0 (Advanced)

### Features to implement

- [ ] Conversation mode (automatic speaker detection)
- [ ] Support for regional accents and dialects
- [ ] Spelling and grammar correction before translation
- [ ] Automatic language detection
- [ ] Custom glossaries for specific domains
- [ ] Integration with macOS dictionary system

### Technical improvements

- [ ] Dynamic template update without restarting the application
- [ ] Plugin system for third-party extensions
- [ ] Settings synchronization via iCloud
- [ ] Full test coverage (>80%)

## Version 2.0.0 (Professional)

### Features to be implemented

- [ ] Support for conferences with multiple participants
- [ ] Speaker recognition and distinction
- [ ] Integration with video conferencing services
- [ ] Companion iOS application for mobile use
- [ ] Full offline mode with all built-in templates
- [ ] Support for document translation (PDF, Word, etc.)
- [ ] Improved accessibility for visually and hearing impaired users

### Technical innovations

- [ ] Migration to more advanced translation models (CPU/GPU optimized transformer models)
- [ ] API for integration with other applications
- [ ] Continuous learning system to improve translations
- [ ] Extensible development system for community plugins

## Future ideas to explore

- Integration of visual translation (text in images)
- Support for real-time translation of audio streams (radio, podcasts, etc.)
- Simultaneous interpretation mode for live events
- User learning of specific vocabulary
- Integration with subtitling services for videos
- Pedagogical mode for language learning

## Contribute to the roadmap

This roadmap is open to suggestions and contributions. If you have ideas to improve Mac Local Translator or would like to contribute to any of the features listed, please open an issue on GitHub to discuss it.

Priorities may change based on user needs and technical constraints. Specific release dates are not set to allow for flexible and quality development.
