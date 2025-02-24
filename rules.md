# Private Home AI Assistant Development Rules

## 1. Code Standards

### Swift/iOS
- Use SwiftUI for all new view components
- Follow MVVM architecture pattern
- Minimum iOS target: iOS 15.0
- Use async/await for asynchronous operations
- Implement proper memory management
- Use Swift Package Manager for dependencies

### Security
- No API keys in code
- Use Keychain for sensitive data storage
- Implement certificate pinning
- Regular security audit logging
- Encrypt all local storage
- Implement jailbreak detection

### Testing
- Minimum 80% code coverage
- Unit tests for all business logic
- UI tests for critical paths
- Performance testing requirements
- Network condition testing

### Privacy
- No analytics in release builds
- Local-only data processing
- Camera access only when needed
- Clear user data deletion process
- Regular privacy audit checks

## 2. Development Process

### Git Workflow
- Feature branches from develop
- Pull request required for merge
- Code review by minimum 2 developers
- No direct commits to main
- Semantic versioning

### Commit Standards
- feat(component): add new component
- fix(api): fix api error
- docs(readme): update readme
- refactor(utils): refactor utils
- style(tailwind): add new tailwind class
- test(unit): add unit test
- chore(deps): update dependencies

### Documentation
- API documentation required
- README updates with changes
- Code comments for complex logic
- Architecture decision records
- Security documentation

### Performance Requirements
- App launch < 3 seconds
- Chat response < 2 seconds
- Camera feed latency < 1 second
- Memory usage < 200MB
- Battery impact < 10% per hour

## 3. UI/UX Standards

### Design System
- Follow Apple HIG
- Support Dark/Light mode
- Dynamic type support
- Minimum tap target: 44x44pt
- Consistent spacing system

### Accessibility
- VoiceOver support required
- Dynamic text sizing
- Color contrast compliance
- Haptic feedback support
- Accessibility labels

## 4. Error Handling
- User-friendly error messages
- Graceful degradation
- Offline mode support
- Recovery procedures
- Error logging and tracking

## 5. Release Process
- TestFlight beta testing
- Staged rollout
- Release notes required
- Backup procedures
- Rollback plan 