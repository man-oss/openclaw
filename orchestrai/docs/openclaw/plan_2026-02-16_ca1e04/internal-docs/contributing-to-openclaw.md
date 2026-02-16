# Contributing to OpenClaw

This guide provides comprehensive information for developers contributing to the OpenClaw project, including contribution workflow, coding standards, commit conventions, and code review processes.

## Table of Contents

- [Getting Started](#getting-started)
- [Contribution Workflow](#contribution-workflow)
- [Coding Standards](#coding-standards)
- [Commit Message Conventions](#commit-message-conventions)
- [Pull Request Process](#pull-request-process)
- [Code Review Expectations](#code-review-expectations)
- [Issue Reporting](#issue-reporting)
- [Development Setup](#development-setup)
- [Quality Gates](#quality-gates)

## Getting Started

### Prerequisites

- **Node.js**: Version 22.12.0 or higher (as specified in `package.json` engines)
- **Package Manager**: pnpm 10.23.0 (specified in `packageManager` field)
- **Git**: For version control and git hooks

### Initial Setup

1. **Fork and Clone**: Fork the repository and clone it locally
2. **Install Dependencies**: Run `pnpm install`
3. **Git Hooks**: Git hooks are automatically configured via the `prepare` script:
   ```bash
   git config core.hooksPath git-hooks
   ```

The prepare script in `package.json` automatically sets up git hooks:
```json
"prepare": "command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git config core.hooksPath git-hooks || exit 0"
```

## Contribution Workflow

### 1. Create a Branch

Create a feature or fix branch from `main`:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Changes

Follow the coding standards and make your changes with appropriate tests.

### 3. Run Quality Checks

Before committing, run the full quality check suite:
```bash
pnpm check
```

This command runs:
- **Format Check**: `pnpm format:check` (oxfmt)
- **Type Check**: `pnpm tsgo`
- **Linting**: `pnpm lint`

### 4. Commit Changes

The project uses git hooks to enforce quality gates. The pre-commit hook (`git-hooks/pre-commit`) automatically runs:

```bash
#!/bin/sh
# Pre-commit hook for OpenClaw
# Runs formatting, linting, and type checking

echo "Running pre-commit checks..."

# Check formatting
if ! pnpm format:check; then
    echo "❌ Format check failed. Run 'pnpm format' to fix."
    exit 1
fi

# Run linter
if ! pnpm lint; then
    echo "❌ Linting failed. Fix errors or run 'pnpm lint:fix'."
    exit 1
fi

# Type check
if ! pnpm tsgo; then
    echo "❌ Type checking failed. Fix type errors."
    exit 1
fi

echo "✅ Pre-commit checks passed"
```

**Note**: The git hook is located at `git-hooks/pre-commit` and enforces code quality before commits are created.

### 5. Push Changes

```bash
git push origin your-branch-name
```

### 6. Open a Pull Request

Create a pull request using the provided template at `.github/pull_request_template.md`.

## Coding Standards

### Code Formatting

The project uses **oxfmt** for code formatting:

- **Format Code**: `pnpm format` or `pnpm format:all` (includes Swift)
- **Check Formatting**: `pnpm format:check`
- **Format Documentation**: `pnpm format:docs`

Configuration is managed through oxfmt's default settings.

### Linting

The project uses **oxlint** with type-aware linting:

- **Lint Code**: `pnpm lint`
- **Lint All**: `pnpm lint:all` (includes Swift via swiftlint)
- **Auto-fix**: `pnpm lint:fix`
- **Lint Documentation**: `pnpm lint:docs`

Linting configuration in `package.json`:
```json
"lint": "oxlint --type-aware",
"lint:fix": "oxlint --type-aware --fix && pnpm format"
```

### TypeScript Standards

- **Type Safety**: The project uses strict TypeScript with type-aware linting
- **File Length**: Maximum 500 lines per TypeScript file (enforced by `pnpm check:loc`)
- **Exports**: Proper module exports defined in `package.json`:
  ```json
  "exports": {
    ".": "./dist/index.js",
    "./plugin-sdk": {
      "types": "./dist/plugin-sdk/index.d.ts",
      "default": "./dist/plugin-sdk/index.js"
    },
    "./plugin-sdk/account-id": {
      "types": "./dist/plugin-sdk/account-id.d.ts",
      "default": "./dist/plugin-sdk/account-id.js"
    },
    "./cli-entry": "./openclaw.mjs"
  }
  ```

### Documentation Standards

Documentation files must be formatted using oxfmt:

```bash
# Format documentation
pnpm format:docs

# Check documentation formatting
pnpm format:docs:check

# Lint documentation (markdownlint)
pnpm lint:docs

# Fix documentation linting
pnpm lint:docs:fix

# Check documentation links
pnpm docs:check-links
```

Documentation linting uses markdownlint-cli2 for consistency.

### Platform-Specific Standards

#### Swift (iOS/macOS)

Swift code follows swiftformat and swiftlint rules:

```json
"format:swift": "swiftformat --lint --config .swiftformat apps/macos/Sources apps/ios/Sources apps/shared/OpenClawKit/Sources",
"lint:swift": "swiftlint lint --config .swiftlint.yml && (cd apps/ios && swiftlint lint --config .swiftlint.yml)"
```

Configuration files:
- `.swiftformat` - Swift formatting rules
- `.swiftlint.yml` - Swift linting rules

## Commit Message Conventions

While not explicitly documented in configuration files, following these best practices is recommended:

### Format

```
<type>: <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting)
- **refactor**: Code refactoring
- **test**: Test additions or changes
- **chore**: Build process or auxiliary tool changes
- **perf**: Performance improvements

### Guidelines

- **Subject**: Brief description (50 characters or less)
- **Body**: Detailed explanation of what and why (optional)
- **Footer**: Reference issues (e.g., "Closes #123")

## Pull Request Process

### PR Template

All pull requests must use the template at `.github/pull_request_template.md`:

```markdown
## Description
<!-- Provide a clear and concise description of your changes -->

## Type of Change
<!-- Mark relevant items with an 'x' -->
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Dependency update

## Testing
<!-- Describe the tests you ran and how to reproduce them -->

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)
<!-- Add screenshots to help explain your changes -->

## Related Issues
<!-- Link any related issues here (e.g., Closes #123) -->
```

### Automated Labeling

The project uses automated PR labeling via `.github/labeler.yml` (7017 bytes of configuration). Labels are automatically applied based on file paths changed in the PR.

### CI/CD Workflows

Pull requests trigger automated workflows located in `.github/workflows/`:
- Build validation
- Test execution
- Linting and formatting checks
- Type checking

## Code Review Expectations

### Reviewer Responsibilities

- **Timely Review**: Review PRs within a reasonable timeframe
- **Constructive Feedback**: Provide clear, actionable feedback
- **Code Quality**: Verify adherence to coding standards
- **Test Coverage**: Ensure appropriate test coverage
- **Documentation**: Verify documentation updates

### Author Responsibilities

- **Self-Review**: Review your own code before requesting review
- **Tests**: Include comprehensive tests
- **Documentation**: Update relevant documentation
- **Respond Promptly**: Address review comments in a timely manner
- **Clean History**: Keep commit history clean and logical

### Review Checklist

- [ ] Code follows project style guidelines (enforced by git hooks)
- [ ] Changes are well-tested
- [ ] Documentation is updated
- [ ] No breaking changes (or properly documented if necessary)
- [ ] Performance implications considered
- [ ] Security implications reviewed
- [ ] Error handling is appropriate

## Issue Reporting

### Issue Templates

The project provides issue templates in `.github/ISSUE_TEMPLATE/`. Use the appropriate template when reporting issues or requesting features.

### Bug Reports

When reporting bugs, include:

- **Environment**: OS, Node.js version, OpenClaw version
- **Steps to Reproduce**: Clear, numbered steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Logs**: Relevant error messages or logs
- **Screenshots**: If applicable

### Feature Requests

When requesting features, include:

- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other solutions considered
- **Additional Context**: Any other relevant information

## Development Setup

### Environment Configuration

1. **Create Environment File**: Copy and configure environment variables
2. **Install Dependencies**: Run `pnpm install`
3. **Build Project**: Run `pnpm build`

### Build Process

The build process (`pnpm build`) includes:

```json
"build": "pnpm canvas:a2ui:bundle && tsdown && pnpm build:plugin-sdk:dts && node --import tsx scripts/write-plugin-sdk-entry-dts.ts && node --import tsx scripts/canvas-a2ui-copy.ts && node --import tsx scripts/copy-hook-metadata.ts && node --import tsx scripts/write-build-info.ts && node --import tsx scripts/write-cli-compat.ts"
```

Steps:
1. Bundle canvas UI components
2. Compile TypeScript with tsdown
3. Generate plugin SDK type definitions
4. Write plugin SDK entry types
5. Copy canvas UI assets
6. Copy hook metadata
7. Write build information
8. Write CLI compatibility data

### Development Commands

```bash
# Development mode
pnpm dev

# Watch mode with auto-rebuild
pnpm gateway:watch

# TUI development mode
pnpm tui:dev

# Run tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run end-to-end tests
pnpm test:e2e

# Run live tests (requires live services)
pnpm test:live

# Coverage report
pnpm test:coverage
```

### Platform-Specific Development

#### Android

```bash
# Assemble debug APK
pnpm android:assemble

# Install debug APK
pnpm android:install

# Build, install, and run
pnpm android:run

# Run tests
pnpm android:test
```

#### iOS

```bash
# Generate Xcode project
pnpm ios:gen

# Open in Xcode
pnpm ios:open

# Build
pnpm ios:build

# Build and run in simulator
pnpm ios:run
```

#### macOS

```bash
# Package macOS app
pnpm mac:package

# Restart macOS app
pnpm mac:restart

# Open macOS app
pnpm mac:open
```

## Quality Gates

### Pre-Commit Hooks

Located at `git-hooks/pre-commit`, the hook enforces:

1. **Formatting Check**: `pnpm format:check`
2. **Linting**: `pnpm lint`
3. **Type Checking**: `pnpm tsgo`

All checks must pass before commits are allowed.

### Comprehensive Checks

Run the full check suite:

```bash
# Basic checks (formatting, types, linting)
pnpm check

# Check documentation
pnpm check:docs

# Check line count limits
pnpm check:loc
```

### Test Requirements

#### Unit Tests

- Run with `pnpm test` or `pnpm test:fast`
- Located throughout the codebase
- Use Vitest framework (config: `vitest.unit.config.ts`)

#### End-to-End Tests

- Run with `pnpm test:e2e`
- Use Vitest framework (config: `vitest.e2e.config.ts`)
- Test complete workflows

#### Live Tests

- Run with `pnpm test:live`
- Require live services and authentication
- Use Vitest framework (config: `vitest.live.config.ts`)

#### Docker Tests

Comprehensive Docker-based test suite:

```bash
# Run all Docker tests
pnpm test:docker:all

# Individual Docker test suites
pnpm test:docker:live-models
pnpm test:docker:live-gateway
pnpm test:docker:onboard
pnpm test:docker:gateway-network
pnpm test:docker:qr
pnpm test:docker:doctor-switch
pnpm test:docker:plugins

# Cleanup Docker test artifacts
pnpm test:docker:cleanup
```

### Protocol Validation

The project maintains protocol schemas that must stay in sync:

```bash
# Check protocol is up to date
pnpm protocol:check

# Generate protocol schema
pnpm protocol:gen

# Generate Swift protocol models
pnpm protocol:gen:swift
```

Protocol files:
- `dist/protocol.schema.json` - JSON schema
- `apps/macos/Sources/OpenClawProtocol/GatewayModels.swift` - Swift models

### Release Checks

Before releases, run:

```bash
pnpm release:check
```

This validates version consistency and release readiness.

### Plugin Management

Sync plugin versions across the project:

```bash
pnpm plugins:sync
```

## Dependency Management

### Dependabot Configuration

Automated dependency updates are configured in `.github/dependabot.yml` (2333 bytes). Dependabot monitors and creates PRs for dependency updates.

### pnpm Overrides

Security and compatibility overrides in `package.json`:

```json
"pnpm": {
  "minimumReleaseAge": 2880,
  "overrides": {
    "fast-xml-parser": "5.3.4",
    "form-data": "2.5.4",
    "qs": "6.14.2",
    "@sinclair/typebox": "0.34.48",
    "tar": "7.5.9",
    "tough-cookie": "4.1.3"
  },
  "onlyBuiltDependencies": [
    "@lydell/node-pty",
    "@matrix-org/matrix-sdk-crypto-nodejs",
    "@napi-rs/canvas",
    "@whiskeysockets/baileys",
    "authenticate-pam",
    "esbuild",
    "node-llama-cpp",
    "protobufjs",
    "sharp"
  ]
}
```

- **minimumReleaseAge**: Wait 48 hours (2880 minutes) before adopting new package versions
- **overrides**: Pin specific versions for security/stability
- **onlyBuiltDependencies**: Native modules that require compilation

## VSCode Configuration

### Recommended Extensions

Defined in `.vscode/extensions.json`:
- Project-specific extension recommendations
- Automatically suggested when opening the project in VSCode

### Editor Settings

Configuration in `.vscode/settings.json` (662 bytes) provides:
- Consistent formatting settings
- Linting integration
- TypeScript configuration
- File associations

## GitHub Actions

### Actionlint Configuration

GitHub Actions workflow validation is configured in `.github/actionlint.yaml` (515 bytes).

### Custom Actions

The project includes custom GitHub Actions in `.github/actions/` for:
- Shared workflow steps
- Reusable build logic
- Common CI/CD operations

## Documentation Development

### Mintlify Documentation

The project uses Mintlify for documentation:

```bash
# Start documentation development server
pnpm docs:dev

# Build documentation list
pnpm docs:bin

# Check documentation links
pnpm docs:check-links
```

Documentation source is in the `docs/` directory.

## Community and Support

### Funding

The project accepts sponsorship via configurations in `.github/FUNDING.yml`.

### Getting Help

- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Participate in GitHub Discussions (if enabled)
- **Pull Requests**: Follow the PR template and guidelines

## Best Practices

1. **Small, Focused PRs**: Keep PRs small and focused on a single concern
2. **Test Coverage**: Maintain or improve test coverage
3. **Documentation**: Update documentation alongside code changes
4. **Breaking Changes**: Avoid breaking changes; if necessary, document thoroughly
5. **Performance**: Consider performance implications of changes
6. **Security**: Follow security best practices
7. **Accessibility**: Ensure UI changes are accessible
8. **Error Handling**: Implement robust error handling
9. **Logging**: Add appropriate logging for debugging
10. **Comments**: Comment complex logic and design decisions

## License

By contributing to OpenClaw, you agree that your contributions will be licensed under the MIT License as specified in the project's LICENSE file.