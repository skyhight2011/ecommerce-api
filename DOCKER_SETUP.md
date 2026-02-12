# Docker Setup Guide

This guide explains how to run PostgreSQL using Docker for your e-commerce API.

## 📦 What's Included

- **PostgreSQL 16** - Main database (Alpine Linux for smaller image size)
- **pgAdmin 4** - Optional web-based database management UI
- **Development environment** - Optional containerized app setup

## 🚀 Quick Start

### Option 1: Database Only (Recommended for Local Development)

Run just the PostgreSQL database in Docker while developing your app locally:

```bash
# Start PostgreSQL
docker-compose up -d postgres

# View logs
docker-compose logs -f postgres

# Stop
docker-compose down
```

Your app will connect to PostgreSQL at `localhost:5432`.

### Option 2: With pgAdmin (Database Management UI)

```bash
# Start PostgreSQL + pgAdmin
docker-compose up -d postgres pgadmin

# Access pgAdmin at http://localhost:5050
# Email: admin@admin.com
# Password: admin
```

### Option 3: Full Development Environment

Run everything in Docker (app + database):

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop all services
docker-compose -f docker-compose.dev.yml down
```

## 🔧 Configuration

### 1. Environment Variables

Copy and configure your environment:

```bash
cp .env.example .env
```

Default configuration in `.env`:

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=ecommerce_db

# App connection (for local development)
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ecommerce_db?schema=public"

# pgAdmin (optional)
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
```

### 2. Database Connection URLs

**Local Development (app runs locally, DB in Docker):**
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ecommerce_db?schema=public"
```

**Full Docker (app also in Docker):**
```env
DATABASE_URL="postgresql://postgres:postgres@postgres:5432/ecommerce_db?schema=public"
```

Note: Use `postgres` as hostname when app is in Docker, `localhost` when app runs locally.

## 📝 Common Commands

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Stop and remove volumes (⚠️ deletes all data)
docker-compose down -v

# View logs
docker-compose logs -f [service_name]

# Restart a service
docker-compose restart postgres

# Check service status
docker-compose ps

# Execute command in container
docker-compose exec postgres psql -U postgres -d ecommerce_db
```

### Database Commands

```bash
# Connect to PostgreSQL CLI
docker-compose exec postgres psql -U postgres -d ecommerce_db

# Create database backup
docker-compose exec postgres pg_dump -U postgres ecommerce_db > backup.sql

# Restore database from backup
docker-compose exec -T postgres psql -U postgres -d ecommerce_db < backup.sql

# View database logs
docker-compose logs -f postgres
```

### Prisma Commands with Docker

```bash
# Run migrations (from host)
pnpm prisma:migrate

# Generate Prisma Client
pnpm prisma:generate

# Open Prisma Studio
pnpm prisma:studio

# Seed database
pnpm prisma:seed

# Reset database (⚠️ deletes all data)
pnpm exec prisma migrate reset
```

## 🗄️ pgAdmin Setup

1. Start pgAdmin:
   ```bash
   docker-compose up -d pgadmin
   ```

2. Access pgAdmin: http://localhost:5050
   - Email: `admin@admin.com`
   - Password: `admin`

3. Add PostgreSQL Server:
   - **Right-click** "Servers" → "Register" → "Server"
   - **General Tab:**
     - Name: `Ecommerce DB`
   - **Connection Tab:**
     - Host: `postgres` (or `host.docker.internal` on Mac/Windows)
     - Port: `5432`
     - Database: `ecommerce_db`
     - Username: `postgres`
     - Password: `postgres`

## 🔍 Troubleshooting

### Port Already in Use

If port 5432 is already in use:

```bash
# Check what's using the port
lsof -i :5432

# Stop existing PostgreSQL
brew services stop postgresql  # macOS
sudo service postgresql stop   # Linux

# Or change the port in docker-compose.yml
ports:
  - '5433:5432'  # Use port 5433 instead

# Then update DATABASE_URL
DATABASE_URL="postgresql://postgres:postgres@localhost:5433/ecommerce_db?schema=public"
```

### Connection Refused

```bash
# Check if container is running
docker-compose ps

# Check container logs
docker-compose logs postgres

# Restart the container
docker-compose restart postgres

# Check health status
docker-compose exec postgres pg_isready -U postgres
```

### Permission Denied

```bash
# Fix volume permissions (Linux)
sudo chown -R $USER:$USER ./docker/postgres

# Or remove volumes and recreate
docker-compose down -v
docker-compose up -d
```

### Database Not Found

```bash
# List databases
docker-compose exec postgres psql -U postgres -c "\l"

# Create database manually if needed
docker-compose exec postgres psql -U postgres -c "CREATE DATABASE ecommerce_db;"
```

## 🧹 Cleanup

### Remove Everything

```bash
# Stop and remove containers, networks
docker-compose down

# Also remove volumes (⚠️ deletes all data)
docker-compose down -v

# Remove images
docker rmi postgres:16-alpine dpage/pgadmin4:latest
```

### Fresh Start

```bash
# Complete cleanup
docker-compose down -v
docker volume prune -f

# Start fresh
docker-compose up -d postgres

# Run migrations
pnpm prisma:migrate

# Seed database
pnpm prisma:seed
```

## 📊 Data Persistence

Data is stored in Docker volumes:
- `postgres_data` - Database files
- `pgadmin_data` - pgAdmin configuration

These persist even when containers are stopped. To delete data, use:
```bash
docker-compose down -v
```

## 🔐 Security Notes

**Development Setup - Not for Production!**

For production:
1. Use strong passwords
2. Don't expose ports publicly
3. Use environment-specific compose files
4. Enable SSL/TLS connections
5. Implement proper backup strategies
6. Use secrets management (Docker Swarm secrets, Kubernetes secrets, etc.)

## 🚢 Production Deployment

For production, consider:
- Managed PostgreSQL (AWS RDS, Google Cloud SQL, DigitalOcean, etc.)
- Docker Swarm or Kubernetes for orchestration
- Separate docker-compose.prod.yml with production settings
- Connection pooling (PgBouncer)
- Replication and high availability
- Automated backups

## 📚 Resources

- [PostgreSQL Docker Documentation](https://hub.docker.com/_/postgres)
- [pgAdmin Docker Documentation](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Prisma with Docker](https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-docker)

## ✅ Verification

After setup, verify everything works:

```bash
# 1. Check containers are running
docker-compose ps

# 2. Check database connection
docker-compose exec postgres psql -U postgres -d ecommerce_db -c "SELECT version();"

# 3. Generate Prisma Client
pnpm prisma:generate

# 4. Run migrations
pnpm prisma:migrate

# 5. Seed database
pnpm prisma:seed

# 6. Start your app
pnpm run start:dev
```

If all commands succeed, your Docker PostgreSQL setup is complete! 🎉
