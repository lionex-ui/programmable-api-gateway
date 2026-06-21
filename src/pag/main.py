"""FastAPI application entry point."""

from fastapi import FastAPI

from pag.config import settings

app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Programmable API Gateway with Policy-as-Code Engine",
)


@app.get("/health")
async def health_check() -> dict[str, str]:
    """Health check endpoint."""
    return {"status": "healthy"}


@app.get("/")
async def root() -> dict[str, str]:
    """Root endpoint."""
    return {"message": "Programmable API Gateway", "version": "0.1.0"}
