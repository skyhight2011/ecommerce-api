# Quick Start Guide - E-Commerce API with JWT Authentication

## 🚀 Quick Setup (3 Minutes)

### 1. Start Database
```bash
npm run docker:up
```

### 2. Configure Environment
```bash
# Make sure .env has these values:
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ecommerce_db?schema=public
```

### 3. Generate Prisma Client & Migrate
```bash
npx prisma generate
npx prisma migrate dev
```

### 4. Seed Database (Optional)
```bash
npx ts-node prisma/seed.ts
```

### 5. Start Application
```bash
npm run start:dev
```

### 6. Test Authentication
```bash
./test-auth.sh
```

## 📚 Quick Reference

### API Endpoints
- **Swagger UI**: http://localhost:3000/api
- **Health Check**: http://localhost:3000/
- **Register**: POST http://localhost:3000/auth/register
- **Login**: POST http://localhost:3000/auth/login
- **Profile**: GET http://localhost:3000/auth/profile (Auth required)

### User Roles
- `CUSTOMER` - Default role for registered users
- `SELLER` - Can manage products
- `ADMIN` - Full system access

### Example Requests

#### Register
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Test123!",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

#### Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Test123!"
  }'
```

#### Access Protected Route
```bash
TOKEN="your-jwt-token"
curl -X GET http://localhost:3000/auth/profile \
  -H "Authorization: Bearer $TOKEN"
```

### Make User Admin
```bash
# Option 1: Prisma Studio
npx prisma studio
# Find user and change role to ADMIN

# Option 2: Direct SQL
docker exec -it ecommerce-postgres psql -U postgres -d ecommerce_db
UPDATE "User" SET role = 'ADMIN' WHERE email = 'user@example.com';
```

## 📖 Documentation

- **Full Auth Guide**: `AUTH_GUIDE.md`
- **Setup Details**: `AUTHENTICATION_SETUP_COMPLETE.md`
- **Docker Setup**: `DOCKER_SETUP.md`
- **Prisma Docs**: `README.prisma.md`

## 🛠️ Useful Commands

```bash
# Development
npm run start:dev          # Start dev server
npm run build              # Build for production
npm run start:prod         # Start production server

# Database
npm run prisma:generate    # Generate Prisma Client
npm run prisma:migrate     # Run migrations
npm run prisma:studio      # Open Prisma Studio
npm run prisma:seed        # Seed database

# Docker
npm run docker:up          # Start containers
npm run docker:down        # Stop containers
npm run docker:logs        # View logs
npm run docker:clean       # Remove volumes

# Testing
./test-auth.sh             # Test authentication
```

## 🔒 Security Notes

- Change `JWT_SECRET` in production
- Use HTTPS in production
- Store tokens securely on client
- Implement rate limiting
- Consider refresh tokens

## 🎯 Next Steps

1. Test the API using Swagger UI or the test script
2. Create admin user and test role-based access
3. Implement additional modules (orders, cart, etc.)
4. Add refresh tokens
5. Implement email verification
6. Add rate limiting

---

**Everything is ready!** Start with `npm run start:dev` and open http://localhost:3000/api
