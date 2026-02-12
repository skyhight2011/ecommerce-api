# Admin User Credentials

## Seeded Admin Account

The database seed script automatically creates an admin user:

### Admin Login
```
Email:    admin@admin.com
Password: Admin123!
Role:     ADMIN
```

### Customer Login (for testing)
```
Email:    customer@example.com
Password: Customer123!
Role:     CUSTOMER
```

## How to Login

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
1. Go to http://localhost:3000/api
2. Click **POST /auth/login**
3. Click "Try it out"
4. Use the credentials above
5. Copy the `accessToken` from response
6. Click "Authorize" button at top
7. Enter: `Bearer YOUR_TOKEN` or just `YOUR_TOKEN`
8. Now you can access admin endpoints!

## Recreate Admin User

If you need to recreate the admin user:

```bash
# Run the seed script
pnpm run prisma:seed

# Or manually with ts-node
npx ts-node prisma/seed.ts
```

## Change Admin Password

### Method 1: Via API (if already logged in)
```bash
# First login to get token
TOKEN="your-admin-token"

# Call change password endpoint (you'll need to implement this)
curl -X PATCH http://localhost:3000/users/YOUR_USER_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "NewPassword123!"
  }'
```

### Method 2: Via Database (using Node.js)
```bash
node -e "
const bcrypt = require('bcrypt');
bcrypt.hash('YourNewPassword123!', 10).then(hash => {
  console.log('Run this SQL:');
  console.log(\`UPDATE \\\"User\\\" SET password = '\${hash}' WHERE email = 'admin@admin.com';\`);
});
"
```

Then run the generated SQL in TablePlus or psql.

## Security Notes

⚠️ **IMPORTANT**: 
- Change the admin password in production!
- Use a strong, unique password
- Never commit credentials to git
- Consider implementing 2FA for admin accounts

## Email Verification

**Note**: Email verification is **not implemented** in this system yet. All users can login immediately after registration without email verification.

To add email verification, you would need to:
1. Add email service (SendGrid, AWS SES, etc.)
2. Add verification token to User model
3. Send verification email on registration
4. Create verification endpoint
5. Check `emailVerified` status on login

## Admin Capabilities

With the ADMIN role, you can:
- ✅ View all users (`GET /users`)
- ✅ Create users (`POST /users`)
- ✅ Update any user (`PATCH /users/:id`)
- ✅ Delete users (`DELETE /users/:id`)
- ✅ Create products (`POST /products`)
- ✅ Update products (`PATCH /products/:id`)
- ✅ Delete products (`DELETE /products/:id`)
- ✅ Access all protected endpoints

## Upgrading Existing User to Admin

### Using TablePlus
1. Connect to database
2. Open `User` table
3. Find the user
4. Change `role` to `ADMIN`
5. Change `status` to `ACTIVE`
6. Save

### Using SQL
```sql
UPDATE "User" 
SET role = 'ADMIN', status = 'ACTIVE' 
WHERE email = 'user@example.com';
```

### Using Prisma Studio
```bash
npx prisma studio
```
Then navigate to User table and edit the user.

---

**Quick Test:**
```bash
# Test admin login
./test-auth.sh
```

Or manually:
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@admin.com", "password": "Admin123!"}' | jq
```
