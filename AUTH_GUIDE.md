# Authentication Guide

This guide explains how to use JWT authentication in the E-Commerce API.

## Table of Contents

- [Overview](#overview)
- [Environment Setup](#environment-setup)
- [Authentication Flow](#authentication-flow)
- [Protected Routes](#protected-routes)
- [Role-Based Access Control](#role-based-access-control)
- [API Endpoints](#api-endpoints)
- [Testing with cURL](#testing-with-curl)
- [Decorators](#decorators)

## Overview

The API uses JWT (JSON Web Tokens) for authentication. All routes are protected by default unless explicitly marked as public using the `@Public()` decorator.

### Key Features

- ✅ JWT-based authentication
- ✅ Password hashing with bcrypt
- ✅ Role-based access control (ADMIN, SELLER, CUSTOMER)
- ✅ Global authentication guard
- ✅ Public route decorator
- ✅ Swagger/OpenAPI documentation with Bearer auth

## Environment Setup

Add the following to your `.env` file:

```env
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
```

## Authentication Flow

1. **Register** a new user → Get JWT token
2. **Login** with credentials → Get JWT token
3. Use token in `Authorization` header for protected routes

## Protected Routes

### Route Protection Levels

1. **Public Routes** (no auth required):
   - `GET /` - API health
   - `GET /health` - Health check
   - `POST /auth/register` - Register new user
   - `POST /auth/login` - Login
   - `GET /products` - List products
   - `GET /products/:id` - Get product details

2. **Authenticated Routes** (any logged-in user):
   - `GET /auth/profile` - Get current user profile
   - `GET /users/:id` - Get user by ID
   - `PATCH /users/:id` - Update user

3. **Role-Based Routes**:
   - **ADMIN only**:
     - `POST /users` - Create user
     - `GET /users` - List all users
     - `DELETE /users/:id` - Delete user
     - `DELETE /products/:id` - Delete product
   
   - **ADMIN or SELLER**:
     - `POST /products` - Create product
     - `PATCH /products/:id` - Update product

## Role-Based Access Control

### User Roles

```typescript
enum UserRole {
  ADMIN = 'ADMIN',       // Full system access
  SELLER = 'SELLER',     // Can manage products
  CUSTOMER = 'CUSTOMER', // Regular user (default)
}
```

### Applying Roles to Routes

```typescript
@Get('admin-only')
@Roles('ADMIN')
@UseGuards(JwtAuthGuard, RolesGuard)
adminOnlyEndpoint() {
  return 'This is admin only';
}

@Get('admin-or-seller')
@Roles('ADMIN', 'SELLER')
@UseGuards(JwtAuthGuard, RolesGuard)
adminOrSellerEndpoint() {
  return 'This is for admins or sellers';
}
```

## API Endpoints

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": "7d",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "CUSTOMER"
  }
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response:** Same as register

#### Get Profile
```http
GET /auth/profile
Authorization: Bearer YOUR_JWT_TOKEN
```

### Protected Product Endpoints

#### Create Product (ADMIN/SELLER only)
```http
POST /products
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "MacBook Pro 16\"",
  "slug": "macbook-pro-16",
  "description": "Powerful laptop",
  "price": 2499.99,
  "sku": "MBP16-001",
  "quantity": 50,
  "categoryId": "category-uuid"
}
```

#### Get Products (Public)
```http
GET /products?page=1&limit=10
```

#### Update Product (ADMIN/SELLER only)
```http
PATCH /products/:id
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "price": 2399.99,
  "quantity": 45
}
```

## Testing with cURL

### 1. Register a new user
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User"
  }'
```

### 2. Login and get token
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

Save the `accessToken` from the response.

### 3. Access protected route
```bash
TOKEN="your-jwt-token-here"

curl -X GET http://localhost:3000/auth/profile \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Create an admin user (run in database)
```sql
-- First, find the user ID
SELECT id, email, role FROM "User" WHERE email = 'test@example.com';

-- Update to admin role
UPDATE "User" SET role = 'ADMIN' WHERE email = 'test@example.com';
```

Or use Prisma Studio:
```bash
npx prisma studio
```

### 5. Test admin endpoint
```bash
TOKEN="your-jwt-token-here"

curl -X GET http://localhost:3000/users \
  -H "Authorization: Bearer $TOKEN"
```

## Decorators

### @Public()
Makes a route publicly accessible (no authentication required)

```typescript
@Get('public-route')
@Public()
publicRoute() {
  return 'Anyone can access this';
}
```

### @Roles(...roles)
Restricts route to specific roles

```typescript
@Get('admin-route')
@Roles('ADMIN')
adminRoute() {
  return 'Only admins can access this';
}
```

### @CurrentUser()
Injects the current authenticated user

```typescript
@Get('profile')
@UseGuards(JwtAuthGuard)
getProfile(@CurrentUser() user: any) {
  return user;
}

// Access specific property
@Get('email')
@UseGuards(JwtAuthGuard)
getEmail(@CurrentUser('email') email: string) {
  return { email };
}
```

## Creating Protected Routes in New Modules

### Step 1: Import guards and decorators

```typescript
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
```

### Step 2: Apply guards to controller

```typescript
@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class OrdersController {
  // All routes here require authentication by default
}
```

### Step 3: Use decorators on routes

```typescript
// Public route (no auth)
@Get('status')
@Public()
getStatus() {
  return { status: 'operational' };
}

// Authenticated route (any logged-in user)
@Get('my-orders')
getMyOrders(@CurrentUser('id') userId: string) {
  return this.ordersService.findByUser(userId);
}

// Admin only route
@Get('all')
@Roles('ADMIN')
getAllOrders() {
  return this.ordersService.findAll();
}

// Multiple roles
@Post()
@Roles('ADMIN', 'SELLER')
createOrder(@CurrentUser() user: any, @Body() dto: CreateOrderDto) {
  return this.ordersService.create(user.id, dto);
}
```

## Password Requirements

Passwords must meet the following criteria:
- Minimum 6 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number or special character

## Security Best Practices

1. **JWT Secret**: Use a strong, random secret in production (at least 32 characters)
2. **HTTPS**: Always use HTTPS in production
3. **Token Storage**: Store tokens securely on the client (e.g., httpOnly cookies)
4. **Token Expiration**: Use appropriate expiration times (default: 7 days)
5. **Password Policy**: Enforce strong passwords
6. **Rate Limiting**: Implement rate limiting on auth endpoints (recommended)
7. **Refresh Tokens**: Consider implementing refresh tokens for longer sessions

## Swagger Documentation

The API includes Swagger documentation with JWT authentication support.

1. Start the server: `npm run start:dev`
2. Open browser: `http://localhost:3000/api`
3. Click "Authorize" button
4. Enter your JWT token (without "Bearer" prefix)
5. Test endpoints directly from Swagger UI

## Troubleshooting

### Common Issues

1. **401 Unauthorized**
   - Check if token is included in Authorization header
   - Verify token format: `Bearer YOUR_TOKEN`
   - Ensure token hasn't expired
   - Check JWT_SECRET matches in .env

2. **403 Forbidden**
   - User doesn't have required role
   - Check user role in database
   - Verify @Roles decorator has correct roles

3. **Token expired**
   - Login again to get new token
   - Consider implementing refresh token flow

4. **Password validation error**
   - Ensure password meets complexity requirements
   - Check error message for specific requirement

## Next Steps

1. **Refresh Tokens**: Implement refresh token flow for better security
2. **Email Verification**: Add email verification on registration
3. **Password Reset**: Implement forgot password functionality
4. **Rate Limiting**: Add rate limiting to prevent brute force attacks
5. **2FA**: Add two-factor authentication for enhanced security
6. **Session Management**: Track and manage user sessions
7. **OAuth**: Add social login (Google, Facebook, etc.)

## Example: Complete Auth Flow

```bash
# 1. Register
RESPONSE=$(curl -s -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "Demo123!",
    "firstName": "Demo",
    "lastName": "User"
  }')

# Extract token
TOKEN=$(echo $RESPONSE | jq -r '.accessToken')

# 2. Access protected route
curl -X GET http://localhost:3000/auth/profile \
  -H "Authorization: Bearer $TOKEN"

# 3. Try accessing public route (no token needed)
curl -X GET http://localhost:3000/products

# 4. Try accessing admin route (will fail unless user is admin)
curl -X GET http://localhost:3000/users \
  -H "Authorization: Bearer $TOKEN"
```

## Support

For issues or questions, please check:
- API documentation: `http://localhost:3000/api`
- Project README: `README.md`
- Prisma documentation: `README.prisma.md`
