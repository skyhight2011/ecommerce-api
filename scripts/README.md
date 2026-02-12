# Admin User Creation Scripts

This directory contains scripts for creating admin users in the database.

## Available Scripts

### 1. Create Admin (Default Credentials)

Creates an admin user with default credentials:

```bash
npm run create-admin
# or
npx ts-node scripts/create-admin.ts
```

**Default Credentials:**
- Email: `admin@admin.com`
- Password: `Admin123!`
- Name: `Admin User`
- Role: `ADMIN`

**Features:**
- ✅ Checks if admin already exists
- ✅ Updates existing user to ADMIN role if needed
- ✅ No authorization required
- ✅ No phone number required
- ✅ Automatically hashes password
- ✅ Sets user status to ACTIVE

### 2. Create Admin (Interactive)

Creates an admin user with custom credentials via interactive prompts:

```bash
npm run create-admin:interactive
# or
npx ts-node scripts/create-admin-interactive.ts
```

**Interactive Prompts:**
1. Enter admin email
2. Enter admin password
3. Enter first name
4. Enter last name

**Features:**
- ✅ Custom email and password
- ✅ Password validation
- ✅ Checks for existing users
- ✅ Offers to update existing user to ADMIN
- ✅ Interactive confirmation

## Usage Examples

### Quick Setup (Default Admin)

```bash
# 1. Make sure database is running
npm run docker:up

# 2. Run migrations
npm run prisma:migrate

# 3. Create admin user
npm run create-admin
```

Output:
```
🔧 Creating admin user...

✅ Admin user created successfully!

📋 Admin User Details:
   Email: admin@admin.com
   Password: Admin123!
   Name: Admin User
   Role: ADMIN
   Status: ACTIVE
   ID: uuid-here

⚠️  IMPORTANT: Change the password after first login!

🔐 Login with:
   POST http://localhost:3000/auth/login
   Body: {
     "email": "admin@admin.com",
     "password": "Admin123!"
   }

✨ Done!
```

### Custom Admin User

```bash
npm run create-admin:interactive
```

Follow the prompts:
```
🔧 Interactive Admin User Creation

Enter admin email (default: admin@admin.com): superadmin@company.com
Enter admin password (min 6 chars with uppercase, lowercase, number): MySecurePass123!
Enter first name (default: Admin): Super
Enter last name (default: User): Admin

✅ Admin user created successfully!
```

## Login After Creation

After creating an admin user, you can login via the API:

### Using cURL
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@admin.com",
    "password": "Admin123!"
  }'
```

### Using Swagger UI
1. Open http://localhost:3000/api
2. Navigate to `POST /auth/login`
3. Click "Try it out"
4. Enter credentials
5. Click "Execute"
6. Copy the `accessToken` from response
7. Click "Authorize" button at top
8. Enter token and click "Authorize"

## Troubleshooting

### "User already exists"
If you see this message, the script will offer to update the existing user to ADMIN role.

```bash
⚠️  Admin user already exists: admin@admin.com
   Current role: CUSTOMER
   Current status: ACTIVE

✅ Updated existing user to ADMIN role
```

### "Password validation failed"
Make sure your password meets these requirements:
- Minimum 6 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one number (0-9) OR special character (!@#$%^&*)

### "Cannot find module"
Make sure you've installed dependencies:
```bash
npm install
```

### Database connection error
Make sure PostgreSQL is running:
```bash
npm run docker:up
```

Check your `.env` file has the correct `DATABASE_URL`.

## Security Notes

⚠️ **Important Security Reminders:**

1. **Change Default Password**: If using the default script, change the password immediately after first login
2. **Strong Passwords**: Use strong, unique passwords for admin accounts
3. **Limit Admin Access**: Only create admin users when necessary
4. **Regular Audits**: Regularly review admin users in the system
5. **Environment Variables**: In production, consider using environment variables for admin credentials

## Modifying Default Credentials

To change the default credentials, edit `scripts/create-admin.ts`:

```typescript
const ADMIN_USER = {
  email: 'your-email@example.com',
  password: 'YourSecurePassword123!',
  firstName: 'Your',
  lastName: 'Name',
  role: 'ADMIN',
  status: 'ACTIVE',
};
```

## Additional Information

- Scripts use Prisma Client with pg adapter
- Passwords are hashed using bcrypt (10 rounds)
- Scripts can be run while the application is running or stopped
- Scripts automatically handle database connection and cleanup
- All scripts require `DATABASE_URL` environment variable

## Related Documentation

- [Authentication Guide](../AUTH_GUIDE.md)
- [Quick Start Guide](../QUICK_START.md)
- [Authentication Setup](../AUTHENTICATION_SETUP_COMPLETE.md)
