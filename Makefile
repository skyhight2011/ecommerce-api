.PHONY: help install dev build start test clean docker-up docker-down docker-clean prisma-generate prisma-migrate prisma-seed

# Default target
help:
	@echo "Available commands:"
	@echo "  make install          - Install dependencies"
	@echo "  make dev              - Start development server"
	@echo "  make build            - Build for production"
	@echo "  make start            - Start production server"
	@echo "  make test             - Run tests"
	@echo "  make docker-up        - Start Docker services"
	@echo "  make docker-down      - Stop Docker services"
	@echo "  make docker-clean     - Stop and remove Docker volumes"
	@echo "  make db-setup         - Complete database setup (Docker + Prisma)"
	@echo "  make prisma-generate  - Generate Prisma Client"
	@echo "  make prisma-migrate   - Run Prisma migrations"
	@echo "  make prisma-seed      - Seed database"
	@echo "  make clean            - Clean build artifacts"

# Install dependencies
install:
	pnpm install

# Development
dev:
	pnpm run start:dev

# Build
build:
	pnpm run build

# Production start
start:
	pnpm run start:prod

# Tests
test:
	pnpm run test

# Docker commands
docker-up:
	docker-compose up -d postgres

docker-down:
	docker-compose down

docker-clean:
	docker-compose down -v

# Prisma commands
prisma-generate:
	pnpm prisma:generate

prisma-migrate:
	pnpm prisma:migrate

prisma-seed:
	pnpm prisma:seed

# Complete database setup
db-setup: docker-up
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 5
	@echo "Generating Prisma Client..."
	@pnpm prisma:generate
	@echo "Running migrations..."
	@pnpm prisma:migrate
	@echo "Seeding database..."
	@pnpm prisma:seed
	@echo "Database setup complete!"

# Setup entire project
setup: install docker-up
	@sleep 5
	@cp .env.example .env || true
	@pnpm prisma:generate
	@pnpm prisma:migrate
	@pnpm prisma:seed
	@echo "Project setup complete! Run 'make dev' to start."

# Clean
clean:
	rm -rf dist
	rm -rf node_modules
	rm -rf coverage
