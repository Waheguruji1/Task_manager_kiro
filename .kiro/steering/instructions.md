---
inclusion: always
---

# Development Instructions

## Code Quality & Error Handling

### Error Fixing Priority
1. **Fix all errors in application code** (`lib/` directory) - this is the default behavior
2. **Maintain data integrity** in database operations and state management
3. **Ensure proper error boundaries** with user-friendly feedback
4. **Leave test file errors unfixed** unless they break the build process

### Code Analysis Approach
- **Analyze existing code first** - if functionally correct, proceed with minimal changes
- **Don't over-engineer** solutions or add unnecessary complexity
- **Focus on working software** over perfect abstractions
- **Prioritize user experience** and app responsiveness

## Testing Strategy

### Minimal Testing Approach
- **Create tests ONLY when absolutely necessary** for core functionality
- **Prioritize task completion** over comprehensive test coverage
- **Focus on critical business logic**: database operations, complex algorithms, integration points
- **Skip tests for**: simple UI widgets, CRUD operations, configuration files, self-evident utilities

### Test File Handling
- **DO NOT fix errors in test files** unless specifically requested
- **Ignore test failures** if main application code works correctly
- **Leave test files as-is** even with warnings or errors

## Development Workflow

### Task Execution Flow
1. **Understand requirements** and analyze existing codebase
2. **If code appears functional**, proceed with minimal necessary changes
3. **Implement features efficiently** without unnecessary testing overhead
4. **Fix application errors** but ignore test file issues
5. **Verify functionality** through manual testing when possible

### Code Style Guidelines
- **Follow existing patterns** in the codebase
- **Use snake_case** for file names and variables
- **Maintain consistent import organization**: Flutter/Dart, third-party, local
- **Keep widgets stateless** when possible
- **Use Riverpod providers** for state management and dependency injection

## Architecture Patterns

### State Management
- **Use StateNotifiers** for complex state with multiple operations
- **Use simple providers** for dependency injection and basic state
- **Centralize providers** in `lib/providers/providers.dart`
- **Handle async operations** with FutureProviders

### Service Layer
- **Abstract business logic** into services
- **Use singleton pattern** for stateful services
- **Wrap database operations** in service methods
- **Handle errors at service level** and transform for UI consumption

### UI Components
- **Create reusable widgets** in `lib/widgets/`
- **Use ConsumerWidget** for Riverpod integration
- **Follow Material Design 3** principles with custom dark theme
- **Implement responsive design** using utility functions

## Performance & UX Focus

- **Optimize for smooth interactions** over extensive testing
- **Prioritize working features** over perfect test coverage
- **Ensure app responsiveness** and quick load times
- **Focus on user-facing functionality** and visual feedback

## Documentation Standards

- **Document service interfaces** and critical methods
- **Keep documentation concise** and focused on essential information
- **Update README** only when adding significant features

## Summary

Deliver working software efficiently by focusing on application code quality, minimal necessary testing, and user experience optimization. Fix errors in `lib/` directory, ignore test file issues, and prioritize functional completeness over comprehensive testing.