FROM python:3.11-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Copy source code
COPY src/ src/

# Run application
CMD ["uv", "run", "uvicorn", "pag.main:app", "--host", "0.0.0.0", "--port", "8000"]
