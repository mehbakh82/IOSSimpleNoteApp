# SimpleNoteSwift - iOS Note-Taking App

A production-ready SwiftUI-based note-taking application featuring offline-first architecture, JWT authentication, and seamless synchronization with a Django REST API backend.

## Features

### Core Functionality
- **Secure Authentication**: JWT-based login/registration with token refresh
- **Note Management**: Full CRUD operations with real-time updates
- **Advanced Search**: Real-time search with local and server-side filtering
- **Offline-First**: Works seamlessly without internet connection
- **Auto-Sync**: Automatic synchronization when connection is restored
- **Password Security**: Show/hide password toggles on all password fields

### User Experience
- **Modern SwiftUI Interface**: Clean, intuitive design following iOS guidelines
- **Reactive UI**: Real-time updates using Combine framework
- **Form Validation**: Comprehensive input validation with user feedback
- **Error Handling**: Graceful error handling with user-friendly messages
- **Loading States**: Visual feedback during network operations

## Architecture

### MVVM + Services Pattern
- **Models**: Data structures and API contracts
- **Views**: SwiftUI user interface components
- **ViewModels**: Business logic and state management
- **Services**: Core functionality (API, Data, Authentication)

### Project Structure
```
SimpleNoteSwift/
├── Models/
│   └── NoteModel.swift          # Data models and API contracts
├── Services/
│   ├── APIService.swift         # Network layer with Combine
│   ├── TokenManager.swift       # JWT authentication management
│   └── CoreDataService.swift    # Local data persistence
├── ViewModels/
│   ├── AuthViewModel.swift      # Authentication state management
│   └── NotesViewModel.swift     # Notes business logic
├── Views/
│   ├── LoginView.swift          # User authentication
│   ├── RegisterView.swift       # User registration
│   ├── NotesListView.swift      # Main notes interface
│   ├── AddNoteView.swift        # Create note
│   ├── EditNoteView.swift       # Edit note
│   ├── ChangePasswordView.swift # Password management
│   ├── SettingsView.swift       # User settings
│   └── Components/
│       └── OfflineIndicator.swift # Network status
└── SimpleNoteSwift.xcdatamodeld/ # Core Data schema
```

## Technical Implementation

### Offline-First Architecture
- **Core Data**: Local persistence with sync status tracking
- **Automatic Fallback**: Seamless operation without internet
- **Background Sync**: Automatic synchronization when online
- **Conflict Resolution**: Smart handling of data conflicts

### Modern iOS Development
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming and data flow
- **MVVM**: Clean separation of concerns
- **Protocol-Oriented**: Testable and maintainable code

### Security & Authentication
- **JWT Tokens**: Secure authentication with refresh capability
- **Token Storage**: Secure storage using UserDefaults
- **Password Security**: Show/hide toggles on all password fields
- **Input Validation**: Comprehensive form validation

### Performance & UX
- **Reactive UI**: Real-time updates with Combine
- **Search Optimization**: Debounced search with local/server filtering
- **Error Handling**: Graceful error management
- **Loading States**: Visual feedback for all operations

## Comparison with Android Implementation

| Feature | Android (Kotlin) | iOS (Swift) |
|---------|------------------|-------------|
| UI Framework | Jetpack Compose | SwiftUI |
| Architecture | MVVM + Repository | MVVM + Services |
| Database | Room (SQLite) | Core Data |
| Networking | Retrofit | URLSession |
| State Management | StateFlow/Flow | Combine |
| Navigation | Navigation Compose | SwiftUI NavigationView |

## Getting Started

### Prerequisites
- **Xcode 15.0+** with iOS 17.0+ deployment target
- **Django Backend** running on `http://localhost:8000`
- **macOS** for iOS development

### Installation

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd SimpleNoteSwift
   ```

2. **Start the Backend Server**:
   ```bash
   # Ensure Django backend is running
   python manage.py runserver
   # API should be accessible at http://localhost:8000/api/
   ```

3. **Open in Xcode**:
   ```bash
   open SimpleNoteSwift.xcodeproj
   ```

4. **Build and Run**:
   - Select iOS Simulator or connected device
   - Press `⌘+R` to build and run
   - Or use Product → Run in Xcode

### Testing the App

1. **Authentication Flow**:
   - Register a new account
   - Login with credentials
   - Test password change functionality

2. **Note Management**:
   - Create, edit, and delete notes
   - Test search functionality
   - Verify offline operation

3. **Sync Testing**:
   - Create notes while offline
   - Go online and verify sync
   - Test conflict resolution

## Dependencies

### Native iOS Frameworks
- **SwiftUI**: Declarative UI framework
- **Core Data**: Local data persistence
- **Combine**: Reactive programming
- **Foundation**: Core system services

### External Dependencies
- **None**: Pure iOS implementation with no third-party libraries

## API Integration

### Authentication Endpoints
- `POST /auth/token/` - User login
- `POST /auth/register/` - User registration
- `POST /auth/token/refresh/` - Token refresh
- `GET /auth/userinfo/` - User profile
- `POST /auth/change-password/` - Password change

### Notes Management
- `GET /notes/` - List notes with pagination
- `POST /notes/` - Create new note
- `GET /notes/{id}/` - Get specific note
- `PATCH /notes/{id}/` - Update note
- `DELETE /notes/{id}/` - Delete note
- `GET /notes/filter` - Search notes

### Security Features
- **JWT Authentication**: Bearer token in Authorization header
- **Token Refresh**: Automatic token renewal
- **Secure Storage**: UserDefaults for token persistence

## Offline Capabilities

### Local Storage
- **Core Data**: All notes stored locally
- **Sync Status**: Track synchronization state
- **Conflict Resolution**: Handle data conflicts intelligently

### Offline Features
- Create, edit, delete notes
- Search through local notes
- Full app functionality
- Automatic sync when online

## Production Readiness

### Code Quality
- **Clean Architecture**: MVVM + Services pattern
- **Documentation**: Comprehensive code comments
- **Error Handling**: Graceful error management
- **Memory Management**: Proper Combine usage
- **Security**: JWT authentication and validation

### Performance
- **Offline-First**: Works without internet
- **Reactive UI**: Real-time updates
- **Efficient Search**: Debounced and optimized
- **Memory Efficient**: Proper resource management

## Future Enhancements

### Planned Features
- **Push Notifications**: Real-time note updates
- **CloudKit Integration**: Cross-device synchronization
- **Rich Text Editing**: Advanced formatting options
- **Note Sharing**: Collaboration features
- **Dark Mode**: System theme support
- **Widgets**: Quick note access
- **Biometric Auth**: Face ID / Touch ID

### Technical Improvements
- **Keychain Storage**: Enhanced security for tokens
- **Unit Tests**: Comprehensive test coverage
- **CI/CD**: Automated testing and deployment
- **Analytics**: Usage tracking and insights

## License

This project is part of a cross-platform development demonstration showcasing modern iOS development practices with SwiftUI and Combine.

---

**Built with SwiftUI and Combine**
