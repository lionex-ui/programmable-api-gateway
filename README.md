# Programmable API Gateway

[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-00a393.svg)](https://fastapi.tiangolo.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Code style: Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

A high-performance API Gateway with a Policy-as-Code engine, built on FastAPI. Designed to handle 10K+ RPS with flexible authentication, authorization, and traffic management.

## Overview

This gateway sits in front of your microservices and manages all incoming requests through configurable policies:

- **Routing** — Route requests to appropriate upstream services
- **Authentication** — JWT validation, API Keys, OAuth2/OIDC
- **Authorization** — RBAC/ABAC policies via Policy-as-Code
- **Rate Limiting** — Per-user, per-IP, per-endpoint limits
- **Caching** — Response caching with configurable TTL
- **Observability** — OpenTelemetry tracing, Prometheus metrics, structured logging
- **Resilience** — Circuit breaker, retries, timeouts

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Layer                               │
│            FastAPI routes, middleware, schemas                  │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                            │
│              Services, use cases, business logic                │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Layer                               │
│               Models, interfaces (ports)                        │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│                   Infrastructure Layer                          │
│         Redis, PostgreSQL, Casbin, HTTP clients                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       Telemetry                                 │
│          OpenTelemetry tracing, metrics, logging                │
└─────────────────────────────────────────────────────────────────┘
```

### Request Flow

```
Request → Auth → Rate Limit → Policy Check → Transform → Cache Check
        → Proxy → Transform Response → Cache Store → Response
```

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
└── telemetry/            # OpenTelemetry setup
```

## Policy-as-Code Example

```yaml
routes:
  - path: /api/users/**
    upstream: http://users-service:8000
    auth:
      type: jwt
      required: true
    policies:
      - name: rbac
        roles: [admin, user]
    rate_limit:
      requests: 100
      window: 60s
    cache:
      enabled: true
      ttl: 30s
```

## Roadmap

- [x] Project structure and documentation
- [ ] **Phase 1:** Basic proxy with routing
- [ ] **Phase 2:** Authentication (JWT, API Keys, OIDC)
- [ ] **Phase 3:** Policy engine (Casbin)
- [ ] **Phase 4:** Rate limiting
- [ ] **Phase 5:** Caching, circuit breaker, transformations
- [ ] **Phase 6:** Admin API and PostgreSQL storage

## Requirements

- Python 3.11+
- Redis
- PostgreSQL (optional, for policy storage)

## License

MIT
