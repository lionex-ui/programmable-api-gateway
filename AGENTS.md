# Agent Guidelines

This document provides guidelines for AI agents working on this project.

## Project Overview

**Programmable API Gateway** — a high-performance API Gateway with Policy-as-Code engine built on FastAPI. Designed for 10K+ RPS with flexible authentication, authorization, and traffic management.

### Key Features

- Request routing to upstream services
- Authentication (JWT, API Keys, OAuth2/OIDC)
- Authorization (RBAC/ABAC via Policy-as-Code)
- Rate limiting (per-user, per-IP, per-endpoint)
- Response caching
- OpenTelemetry observability
- Circuit breaker and resilience patterns

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Layer                               │
│            FastAPI routes, middleware, schemas                  │
│                        src/pag/api/                             │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                            │
│              Services, use cases, business logic                │
│                        src/pag/app/                             │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Layer                               │
│               Models, interfaces (ports)                        │
│                      src/pag/domain/                            │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│                   Infrastructure Layer                          │
│         Redis, PostgreSQL, Casbin, HTTP clients                 │
│                       src/pag/infra/                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       Telemetry                                 │
│          OpenTelemetry tracing, metrics, logging                │
│                     src/pag/telemetry/                          │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Dependencies

- **API Layer** → depends on Application, Domain, Telemetry
- **Application Layer** → depends on Domain interfaces only (not implementations)
- **Domain Layer** → no dependencies (pure Python)
- **Infrastructure Layer** → implements Domain interfaces
- **Telemetry** → used by all layers

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | FastAPI + Uvicorn |
| Policy Engine | Casbin |
| Auth | python-jose (JWT), Authlib (OIDC) |
| Rate Limiting | Redis (sliding window) |
| Database | PostgreSQL + asyncpg |
| Caching | Redis |
| Observability | OpenTelemetry, Prometheus |
| HTTP Client | httpx |
| Package Manager | uv |

## Project Structure

```
src/pag/
├── api/                  # HTTP interface layer
│   ├── middleware/       # Gateway, error handling, request ID
│   ├── routes/           # Admin API, health, metrics
│   └── schemas/          # Pydantic request/response models
├── app/                  # Application layer
│   ├── services/         # Business logic services
│   └── use_cases/        # High-level operations
├── domain/               # Domain layer
│   ├── models/           # Domain entities
│   └── interfaces/       # Abstract interfaces (ports)
├── infra/                # Infrastructure layer
│   ├── auth/             # JWT, API Key, OIDC implementations
│   ├── policy/           # Casbin engine, policy loaders
│   ├── rate_limit/       # Redis/memory backends
│   ├── cache/            # Redis cache
│   ├── resilience/       # Circuit breaker, retry
│   ├── persistence/      # Database, Redis clients
│   └── http/             # HTTP client pool
├── telemetry/            # OpenTelemetry setup
├── config.py             # Application configuration
└── main.py               # FastAPI app entry point
```

## Git Workflow

### Branch Naming

```
feat/short-description     # New feature
fix/short-description      # Bug fix
chore/short-description    # Maintenance, config, dependencies
docs/short-description     # Documentation
refactor/short-description # Code refactoring
test/short-description     # Tests
ci/short-description       # CI/CD changes
```

### Commit Messages (Conventional Commits)

Format: `<type>: <description>`

```
feat: add JWT authentication middleware
fix: resolve rate limiter race condition
chore: update dependencies
docs: add API documentation
refactor: extract policy evaluation logic
test: add unit tests for auth service
ci: add code coverage reporting
```

**Types:**
- `feat` — new feature
- `fix` — bug fix
- `chore` — maintenance (deps, config)
- `docs` — documentation
- `refactor` — code refactoring (no behavior change)
- `test` — adding/updating tests
- `ci` — CI/CD changes

**Rules:**
- Use lowercase
- No period at the end
- Imperative mood ("add" not "added")
- Keep under 72 characters
- One commit = one logical change

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes with atomic commits
3. Push branch and create PR to `develop`
4. PR requires at least 1 approval
5. All CI checks must pass
6. Squash merge or rebase (no merge commits)

### Branch Protection

- `main` — protected, requires PR with 1 approval, no direct push
- `develop` — protected, requires PR with 1 approval, no direct push

## Development Commands

```bash
# Install dependencies
make install

# Run development server
make dev

# Run tests
make test

# Run tests with coverage
make test-cov

# Lint code
make lint

# Format code
make format

# Type check
make typecheck

# Run all checks
make check
```

## Code Style

- **Formatter:** Ruff
- **Linter:** Ruff
- **Type Checker:** mypy (strict mode)
- **Line Length:** 100 characters
- **Python Version:** 3.11+

### Import Order

1. Standard library
2. Third-party packages
3. Local packages (`pag.*`)

### Type Hints

- Required for all function signatures
- Use `from __future__ import annotations` if needed
- Use `typing` module types for complex types

## Testing

- **Framework:** pytest
- **Async:** pytest-asyncio
- **Coverage:** pytest-cov
- **Location:** `tests/`

### Test Structure

```
tests/
├── unit/           # Unit tests (no external deps)
│   ├── app/        # Application layer tests
│   └── domain/     # Domain layer tests
├── integration/    # Integration tests (with Redis, DB)
│   └── infra/      # Infrastructure tests
└── e2e/            # End-to-end tests
```

## Adding New Features

1. Start with domain models/interfaces
2. Implement application layer logic
3. Add infrastructure implementations
4. Create API endpoints
5. Add telemetry instrumentation
6. Write tests (unit → integration)
7. Update documentation if needed
