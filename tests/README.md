# VaultOS Testing

Testing infrastructure for VaultOS.

## Test Structure

```
tests/
├── unit/              # Unit tests
├── integration/       # Integration tests
├── themes/            # Theme compatibility tests
└── scripts/           # Test scripts
```

## Running Tests

```bash
./tests/run-tests.sh
```

## Test Types

### Unit Tests
- Component-level tests
- Function tests
- Module tests

### Integration Tests
- Full system tests
- Component interaction tests
- End-to-end tests

### Theme Tests
- Theme compatibility
- CSS validation
- Color scheme validation

### Regression Tests
- Verify existing functionality
- Check for breakages

## Test Coverage

Test coverage reports are generated:
```
tests/coverage/
```

## Continuous Testing

Tests run automatically in CI/CD pipeline (GitHub Actions).
