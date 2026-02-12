# E-Commerce API

A production-ready E-Commerce REST API built with NestJS, Prisma, PostgreSQL, and JWT authentication.

## 🚀 Features

- ✅ **JWT Authentication** - Secure authentication with access tokens
- ✅ **Role-Based Access Control** - ADMIN, SELLER, and CUSTOMER roles
- ✅ **Prisma ORM** - Type-safe database access with PostgreSQL
- ✅ **Docker Support** - PostgreSQL and pgAdmin containers
- ✅ **Swagger Documentation** - Interactive API documentation
- ✅ **Input Validation** - Request validation with class-validator
- ✅ **Password Hashing** - Secure password storage with bcrypt
- ✅ **Global Guards** - Automatic authentication on all routes
- ✅ **Public Routes** - Easy decorator for public endpoints
- ✅ **Production Ready** - Built with best practices and security in mind

## 📋 Prerequisites

- Node.js 20+ (use `fnm` or `nvm` to manage versions)
- Docker and Docker Compose
- pnpm (or npm)

## 🎯 Quick Start

### 1. Install Dependencies
```bash
pnpm install
```

### 2. Setup Environment
```bash
# Copy .env.example to .env
cp .env.example .env

# Update JWT_SECRET in .env with a strong secret
```

### 3. Start Database
```bash
pnpm run docker:up
```

### 4. Setup Database
```bash
# Generate Prisma Client
pnpm run prisma:generate

# Run migrations
pnpm run prisma:migrate

# Seed database (optional)
pnpm run prisma:seed
```

### 5. Start Application
```bash
# Development mode with hot reload
pnpm run start:dev

# Production mode
pnpm run build
pnpm run start:prod
```

### 6. Test Authentication
```bash
# Run automated test script
./test-auth.sh

# Or access Swagger UI
open http://localhost:3000/api
```

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get up and running in 3 minutes
- **[Authentication Guide](AUTH_GUIDE.md)** - Complete auth implementation guide
- **[Authentication Setup](AUTHENTICATION_SETUP_COMPLETE.md)** - Detailed setup documentation
- **[Docker Setup](DOCKER_SETUP.md)** - Docker configuration and usage
- **[Prisma Documentation](README.prisma.md)** - Database and Prisma guide

## 🔐 Authentication

The API uses JWT tokens for authentication. All routes are protected by default.

### Register
```bash
POST /auth/register
{
  "email": "user@example.com",
  "password": "Test123!",
  "firstName": "John",
  "lastName": "Doe"
}
```

### Login
```bash
POST /auth/login
{
  "email": "user@example.com",
  "password": "Test123!"
}
```

### Use Token
```bash
GET /auth/profile
Authorization: Bearer YOUR_JWT_TOKEN
```

## 🎭 User Roles

- **CUSTOMER** (default) - Can browse products, create orders
- **SELLER** - Can manage products
- **ADMIN** - Full system access

## 📦 API Endpoints

### Public Routes
- `GET /` - Health check
- `GET /health` - Detailed health status
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /products` - List products
- `GET /products/:id` - Get product details

### Protected Routes
- `GET /auth/profile` - Current user profile
- `GET /users/:id` - Get user
- `PATCH /users/:id` - Update user

### Admin Routes
- `GET /users` - List all users
- `POST /users` - Create user
- `DELETE /users/:id` - Delete user
- `DELETE /products/:id` - Delete product

### Admin/Seller Routes
- `POST /products` - Create product
- `PATCH /products/:id` - Update product

## 🛠️ Development

### Available Scripts

```bash
# Development
pnpm run start:dev         # Start with hot reload
pnpm run build             # Build for production
pnpm run start:prod        # Start production server

# Database
pnpm run prisma:generate   # Generate Prisma Client
pnpm run prisma:migrate    # Run migrations
pnpm run prisma:studio     # Open Prisma Studio
pnpm run prisma:seed       # Seed database
pnpm run prisma:push       # Push schema changes
pnpm run prisma:pull       # Pull schema from database

# Docker
pnpm run docker:up         # Start containers
pnpm run docker:down       # Stop containers
pnpm run docker:logs       # View logs
pnpm run docker:clean      # Remove volumes

# Testing
pnpm run test              # Unit tests
pnpm run test:e2e          # E2E tests
pnpm run test:cov          # Test coverage
./test-auth.sh             # Auth integration tests
```

### Project Structure

```
src/
├── auth/                  # Authentication module
│   ├── decorators/        # Custom decorators (@Public, @Roles, @CurrentUser)
│   ├── dto/               # Data transfer objects
│   ├── guards/            # Auth guards (JWT, Roles)
│   ├── strategies/        # Passport strategies
│   └── auth.service.ts    # Auth business logic
├── users/                 # Users module
│   ├── dto/               # User DTOs
│   ├── entities/          # User entity
│   └── users.service.ts   # User business logic
├── products/              # Products module
│   ├── dto/               # Product DTOs
│   ├── entities/          # Product entity
│   └── products.service.ts # Product business logic
├── prisma/                # Prisma module
│   └── prisma.service.ts  # Prisma service
├── common/                # Shared utilities
│   └── dto/               # Common DTOs
└── app.module.ts          # Main application module

prisma/
├── schema.prisma          # Database schema
├── migrations/            # Database migrations
└── seed.ts                # Database seeding script
```

## 🐳 Docker

The project includes Docker configuration for PostgreSQL and pgAdmin.

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Clean up (removes volumes)
docker-compose down -v
```

Access pgAdmin at http://localhost:5050 (admin@admin.com / admin)

## 📊 Database

### Prisma Studio
```bash
pnpm run prisma:studio
```

Access at http://localhost:5555

### Direct PostgreSQL Access
```bash
docker exec -it ecommerce-postgres psql -U postgres -d ecommerce_db
```

## 🔒 Security

- JWT tokens for authentication
- Bcrypt password hashing (10 rounds)
- Input validation on all requests
- Never exposes passwords in responses
- Role-based authorization
- CORS enabled
- User status checking

## 🧪 Testing

```bash
# Run authentication tests
./test-auth.sh

# Unit tests
pnpm run test

# E2E tests
pnpm run test:e2e

# Test coverage
pnpm run test:cov
```

## 📖 API Documentation

Interactive API documentation is available at:
- **Swagger UI**: http://localhost:3000/api

Features:
- Try endpoints directly from the browser
- Bearer token authentication
- Request/response schemas
- Example payloads

## 🚀 Deployment

### Build
```bash
pnpm run build
```

### Environment Variables
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=your-production-database-url
JWT_SECRET=your-production-secret-key
JWT_EXPIRES_IN=7d
```

### Run Production
```bash
pnpm run start:prod
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is [MIT licensed](LICENSE).

## 🔗 Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [Prisma Documentation](https://www.prisma.io/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs)
- [JWT Documentation](https://jwt.io)
- [Passport.js](https://www.passportjs.org)

## 👥 Support

For questions and support:
- Check the documentation files
- Open an issue on GitHub
- Review the Swagger documentation

## 📈 Roadmap

- [ ] Refresh tokens
- [ ] Email verification
- [ ] Password reset
- [ ] Rate limiting
- [ ] Two-factor authentication
- [ ] OAuth integration
- [ ] Order management
- [ ] Shopping cart
- [ ] Payment integration
- [ ] Email notifications
- [ ] File upload (product images)
- [ ] Search and filtering
- [ ] Caching with Redis

---

Built with ❤️ using [NestJS](https://nestjs.com)
