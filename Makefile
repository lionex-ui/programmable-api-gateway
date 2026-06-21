.PHONY: dev test lint format typecheck install clean docker-up docker-down docker-app

# Development server
dev:
	uv run uvicorn pag.main:app --reload --host 0.0.0.0 --port 8000

# Install dependencies
install:
	uv sync --dev
	uv run pre-commit install

# Run tests
test:
	uv run pytest

# Run tests with coverage
test-cov:
	uv run pytest --cov=src/pag --cov-report=term-missing --cov-report=html

# Lint code
lint:
	uv run ruff check src tests

# Format code
format:
	uv run ruff format src tests
	uv run ruff check --fix src tests

# Type check
typecheck:
	uv run mypy src

# Run all checks
check: lint typecheck test

# Docker: start infrastructure only (Redis, Postgres, Jaeger)
docker-up:
	docker compose -f docker/docker-compose.yaml up -d

# Docker: stop infrastructure
docker-down:
	docker compose -f docker/docker-compose.yaml down

# Docker: start everything including app
docker-app:
	docker compose -f docker/docker-compose.app.yaml up -d --build

# Clean up
clean:
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} +
