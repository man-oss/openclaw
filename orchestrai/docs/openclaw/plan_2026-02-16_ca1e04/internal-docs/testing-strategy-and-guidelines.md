# Testing Strategy and Guidelines

## Overview

OpenClaw uses **Vitest** as its primary testing framework for unit, integration, and end-to-end testing. The testing strategy emphasizes comprehensive coverage across multiple test types, with special consideration for live API testing, Docker-based integration tests, and platform-specific testing.

## Testing Framework and Configuration

### Vitest Setup

The project uses three separate Vitest configurations for different test types:

- **`vitest.unit.config.ts`**: Unit and integration tests
- **`vitest.e2e.config.ts`**: End-to-end tests
- **`vitest.live.config.ts`**: Live API tests requiring real credentials

### Test Directory Structure

```
test/
├── fixtures/          # Test data and mock files
├── helpers/           # Shared test utilities
├── mocks/            # Mock implementations
├── setup.ts          # Test environment setup
├── global-setup.ts   # Global test configuration
├── test-env.ts       # Environment variable management
├── *.e2e.test.ts     # End-to-end tests
└── *.auto.e2e.test.ts # Auto-run E2E tests
```

### Global Test Setup

**File: `test/global-setup.ts`**

```typescript
export default async function setup() {
  // Global test initialization
}
```

**File: `test/setup.ts`** (6,262 bytes)

This file contains per-test setup logic including:
- Test environment initialization
- Mock setup and teardown
- Shared test utilities

**File: `test/test-env.ts`** (5,634 bytes)

Manages test environment variables and configuration, ensuring consistent test execution across different environments.

## Test Execution Commands

### Basic Test Commands

```bash
# Run all unit tests
pnpm test

# Run fast unit tests only
pnpm test:fast

# Run with coverage
pnpm test:coverage

# Run E2E tests
pnpm test:e2e

# Run live API tests (requires credentials)
pnpm test:live

# Watch mode for development
pnpm test:watch
```

### Comprehensive Test Suite

```bash
# Run all tests including E2E and live tests
pnpm test:all

# Equivalent to:
pnpm lint && pnpm build && pnpm test && pnpm test:e2e && pnpm test:live && pnpm test:docker:all
```

### Docker-Based Integration Tests

OpenClaw includes extensive Docker-based integration tests:

```bash
# Run all Docker tests
pnpm test:docker:all

# Individual Docker test suites
pnpm test:docker:live-models       # Test live model integrations
pnpm test:docker:live-gateway      # Test gateway with live models
pnpm test:docker:onboard           # Test onboarding flow
pnpm test:docker:gateway-network   # Test gateway networking
pnpm test:docker:qr                # Test QR code import
pnpm test:docker:doctor-switch     # Test doctor and switching
pnpm test:docker:plugins           # Test plugin system
pnpm test:docker:cleanup           # Cleanup Docker resources
```

### Installation Testing

```bash
# Test installation script (smoke test)
pnpm test:install:smoke

# Full E2E installation test
pnpm test:install:e2e

# Provider-specific installation tests
pnpm test:install:e2e:anthropic
pnpm test:install:e2e:openai
```

### Platform-Specific Tests

```bash
# Android tests
pnpm android:test

# UI tests
pnpm test:ui
```

## Test Types and Patterns

### Unit Tests

Unit tests are located alongside source files or in the `test/` directory. They run quickly and don't require external dependencies.

**Naming Convention**: `*.test.ts` or `*.spec.ts`

**Location**: Co-located with source or in `test/` directory

**Execution**: `pnpm test:fast`

### Integration Tests

Integration tests verify component interactions and are typically located in the `test/` directory.

**Execution**: Included in `pnpm test`

### End-to-End Tests

E2E tests verify complete workflows and system behavior.

**Naming Convention**: `*.e2e.test.ts`

**Example Tests**:
- `test/gateway.multi.e2e.test.ts` (11,797 bytes) - Multi-gateway functionality
- `test/git-hooks-pre-commit.e2e.test.ts` (2,137 bytes) - Git hooks integration
- `test/provider-timeout.e2e.test.ts` (10,202 bytes) - Provider timeout handling

**Auto-run E2E Tests**: `*.auto.e2e.test.ts`
- `test/media-understanding.auto.e2e.test.ts` (5,242 bytes) - Media processing tests

**Execution**: `pnpm test:e2e`

### Live API Tests

Live tests interact with real AI provider APIs and require valid credentials.

**Environment Variable**: `OPENCLAW_LIVE_TEST=1` or `CLAWDBOT_LIVE_TEST=1`

**Execution**: `pnpm test:live`

**Configuration**: Tests check for required API keys and skip gracefully if unavailable

## Test Utilities and Helpers

### Test Helpers Directory

**Location**: `test/helpers/`

Contains shared utilities for:
- Test data generation
- Common assertions
- Test environment setup
- Mock helpers

### Test Fixtures

**Location**: `test/fixtures/`

Contains static test data including:
- Sample API responses
- Test configuration files
- Mock data for integration tests

### Test Mocks

**Location**: `test/mocks/`

Contains mock implementations for:
- External API clients
- Platform-specific functionality
- File system operations
- Network requests

## Testing Best Practices

### 1. Test Isolation

Each test should be independent and not rely on execution order:

```typescript
// Use beforeEach for setup
beforeEach(async () => {
  // Reset state
  // Initialize test data
});

// Use afterEach for cleanup
afterEach(async () => {
  // Clean up resources
  // Reset mocks
});
```

### 2. Environment Variables

Use `test/test-env.ts` for managing test-specific environment variables:

- Tests should work with and without external credentials
- Skip tests gracefully when credentials are unavailable
- Use environment-specific configurations

### 3. Mock External Dependencies

- Mock external API calls in unit tests
- Use real APIs only in live tests
- Provide fixture data for predictable test results

### 4. Parallel Test Execution

**File**: `scripts/test-parallel.mjs`

OpenClaw supports parallel test execution with:

```bash
# Run tests in parallel
pnpm test

# Serial execution (for debugging)
OPENCLAW_TEST_PROFILE=serial pnpm test

# Control fork count
OPENCLAW_TEST_VM_FORKS=0 pnpm test:macmini
```

### 5. Coverage Requirements

Generate coverage reports to ensure adequate test coverage:

```bash
pnpm test:coverage
```

Coverage reports are generated using `@vitest/coverage-v8`.

## Quality Gates

### Pre-commit Hooks

**Location**: `git-hooks/`

**Test**: `test/git-hooks-pre-commit.e2e.test.ts`

Pre-commit hooks run:
- Code formatting checks (`pnpm format:check`)
- Type checking (`pnpm tsgo`)
- Linting (`pnpm lint`)

**Setup**:
```bash
pnpm prepare
# Sets git hooks path: git config core.hooksPath git-hooks
```

### CI/CD Checks

The `check` script runs all quality gates:

```bash
pnpm check
# Runs: format:check, tsgo, lint
```

For documentation:
```bash
pnpm check:docs
# Runs: format:docs:check, lint:docs, docs:check-links
```

### Lines of Code Check

**Script**: `scripts/check-ts-max-loc.ts`

```bash
pnpm check:loc
# Enforces max 500 lines per TypeScript file
```

## Special Test Configurations

### Test Profiles

OpenClaw supports different test execution profiles:

- **`default`**: Standard parallel execution
- **`serial`**: Sequential test execution for debugging
- **`dev`**: Development mode with hot reloading

**Usage**:
```bash
OPENCLAW_TEST_PROFILE=serial pnpm test
```

### Provider-Specific Testing

Tests can target specific AI providers:

```bash
# Test with Anthropic models
OPENCLAW_E2E_MODELS=anthropic pnpm test:install:e2e:anthropic

# Test with OpenAI models
OPENCLAW_E2E_MODELS=openai pnpm test:install:e2e:openai
```

### Force Test Execution

**Script**: `scripts/test-force.ts`

```bash
pnpm test:force
# Force tests to run even if checks fail
```

## Testing Workflow for Contributors

### 1. Before Committing

```bash
# Run fast tests
pnpm test:fast

# Run full checks
pnpm check

# Ensure build succeeds
pnpm build
```

### 2. Before Creating PR

```bash
# Run comprehensive test suite
pnpm test:all

# Check documentation
pnpm check:docs

# Verify protocol compatibility
pnpm protocol:check
```

### 3. Testing New Features

```bash
# Write unit tests first
# Place in test/ or co-located with source

# Run in watch mode during development
pnpm test:watch

# Add E2E tests for user-facing features
# Name with *.e2e.test.ts

# Test with live APIs if applicable
pnpm test:live
```

### 4. Testing Bug Fixes

1. Write a failing test that reproduces the bug
2. Fix the bug
3. Verify the test passes
4. Add regression test if needed

## Debugging Tests

### Running Individual Tests

```bash
# Run specific test file
vitest run test/gateway.multi.e2e.test.ts

# Run with filter
vitest run --grep "specific test name"
```

### Debugging in Watch Mode

```bash
pnpm test:watch
# Interactive mode with filtering and re-run on changes
```

### Verbose Output

Tests use structured logging. Check console output for detailed error messages and stack traces.

## Test Dependencies

### Core Testing Dependencies

**From `package.json` devDependencies**:

```json
{
  "vitest": "^4.0.18",
  "@vitest/coverage-v8": "^4.0.18"
}
```

### Runtime Dependencies for Testing

```json
{
  "ollama": "^0.6.3"  // For local LLM testing
}
```

## Platform-Specific Testing

### Android Testing

```bash
# Run Android unit tests
pnpm android:test

# Full Android build and test
cd apps/android && ./gradlew :app:testDebugUnitTest
```

### iOS Testing

```bash
# Build and test iOS
pnpm ios:build

# iOS tests run through Xcode
```

### macOS Testing

```bash
# Package and test macOS app
pnpm mac:package
```

## Continuous Integration

### Release Checks

**Script**: `scripts/release-check.ts`

```bash
pnpm release:check
# Verifies all tests pass before release
```

### Protocol Validation

```bash
pnpm protocol:check
# Ensures protocol definitions are in sync
```

## Test Maintenance

### Updating Test Fixtures

1. Update fixtures in `test/fixtures/` when APIs change
2. Regenerate mock data with updated schemas
3. Update related test assertions

### Cleaning Up Test Resources

```bash
# Clean up Docker test resources
pnpm test:docker:cleanup
```

### Managing Test Data

- Keep fixtures minimal and focused
- Use factories for generating test data
- Version control all test fixtures
- Document any external dependencies

## Common Test Patterns

### Testing Gateway Functionality

See `test/gateway.multi.e2e.test.ts` for patterns on:
- Testing multi-gateway scenarios
- Handling async operations
- Validating message flows

### Testing Provider Timeouts

See `test/provider-timeout.e2e.test.ts` for:
- Timeout handling patterns
- Error recovery testing
- Fallback behavior validation

### Testing Media Understanding

See `test/media-understanding.auto.e2e.test.ts` for:
- Media processing workflows
- Multi-modal input handling
- Format conversion testing

## Summary

OpenClaw's testing strategy emphasizes:

1. **Comprehensive Coverage**: Unit, integration, E2E, and live API tests
2. **Fast Feedback**: Quick unit tests for rapid development
3. **Real-World Validation**: Docker-based and live API testing
4. **Quality Gates**: Pre-commit hooks and CI checks
5. **Developer Experience**: Watch mode, parallel execution, and clear test organization

Contributors should write tests for all new features, ensure existing tests pass before committing, and use the appropriate test type for the functionality being tested.