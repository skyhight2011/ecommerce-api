# Prisma Setup Guide

This project uses Prisma ORM with a **multi-file schema structure** for better organization and maintainability.

## 📁 Project Structure

```
prisma/
├── schema.prisma              # Main schema file with datasource and generator config
├── prisma.config.ts           # Prisma 7 config for migrations (datasource URL)
├── schema/                    # Individual model files
│   ├── user.prisma           # User and Address models
│   ├── product.prisma        # Product, Category, ProductImage, ProductVariant models
│   ├── order.prisma          # Order and OrderItem models
│   ├── cart.prisma           # Cart and CartItem models
│   ├── wishlist.prisma       # Wishlist and WishlistItem models
│   └── review.prisma         # Review model
└── seed.ts                    # Database seeding script

src/
└── prisma/
    ├── prisma.service.ts     # Prisma service with connection handling (Prisma 7 compatible)
    ├── prisma.module.ts      # Global Prisma module
    └── index.ts              # Barrel export

prisma.config.ts              # Prisma 7 config (PROJECT ROOT!)
```

## 🚀 Getting Started

### 0. Start PostgreSQL with Docker (Recommended)

The easiest way to get started is using Docker for PostgreSQL:

```bash
# Start PostgreSQL container
docker-compose up -d postgres

# Or use the npm script
pnpm run docker:up

# Or use Make
make docker-up
```

PostgreSQL will be available at `localhost:5432`. See [DOCKER_SETUP.md](./DOCKER_SETUP.md) for detailed Docker instructions.

### 1. Install Dependencies

Install the required packages:

```bash
pnpm install
```

### 2. Set Up Environment Variables

Copy the example environment file and update with your database credentials:

```bash
cp .env.example .env
```

Edit `.env` and update the `DATABASE_URL`:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/ecommerce_db?schema=public"
```

**Note for Prisma 7**: The datasource URL is now configured in two places:

- In `.env` as `DATABASE_URL` environment variable
- Passed to `PrismaClient` constructor via `datasourceUrl` option (handled automatically in `PrismaService`)

### 3. Create Database

Make sure PostgreSQL is running, then create the database:

```bash
# Using psql
createdb ecommerce_db

# Or using SQL
psql -U postgres -c "CREATE DATABASE ecommerce_db;"
```

### 4. Generate Prisma Client

**IMPORTANT**: You must generate the Prisma Client before the TypeScript types are available:

```bash
pnpm prisma:generate
```

This command reads your schema files and generates:

- Type-safe Prisma Client
- TypeScript types for all models
- Query builder with autocomplete

Once generated, all TypeScript/ESLint errors in `seed.ts` will be resolved.

### 5. Run Migrations

Create and apply database migrations:

```bash
pnpm prisma:migrate
```

When prompted, give your migration a descriptive name (e.g., "init", "add-users-table").

### 6. Seed the Database (Optional)

Populate the database with sample data:

```bash
pnpm prisma:seed
```

## 📝 Available Scripts

The following Prisma scripts are available in `package.json`:

| Script            | Command                  | Description                            |
| ----------------- | ------------------------ | -------------------------------------- |
| `prisma:generate` | `prisma generate`        | Generate Prisma Client                 |
| `prisma:migrate`  | `prisma migrate dev`     | Create and apply migrations            |
| `prisma:studio`   | `prisma studio`          | Open Prisma Studio (GUI)               |
| `prisma:seed`     | `ts-node prisma/seed.ts` | Seed the database                      |
| `prisma:push`     | `prisma db push`         | Push schema changes without migrations |
| `prisma:pull`     | `prisma db pull`         | Pull schema from existing database     |
| `prisma:format`   | `prisma format`          | Format Prisma schema files             |

## 🗂️ Multi-File Schema

This project uses Prisma's **prismaSchemaFolder** preview feature to split models into multiple files:

### Benefits:

- ✅ Better organization for large projects
- ✅ Easier to navigate and maintain
- ✅ Team collaboration becomes simpler
- ✅ Logical grouping of related models

### How It Works:

The main `schema.prisma` file contains the datasource and generator configuration:

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["prismaSchemaFolder"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

Individual model files are placed in the `prisma/schema/` directory. Each file can contain:

- Models
- Enums
- Relations

### Adding New Models:

1. Create a new file in `prisma/schema/` (e.g., `coupon.prisma`)
2. Define your models, enums, and relations
3. Run `pnpm prisma:format` to format your schema
4. Run `pnpm prisma:generate` to update the Prisma Client
5. Create a migration with `pnpm prisma:migrate`

Example:

```prisma
// prisma/schema/coupon.prisma
enum CouponType {
  PERCENTAGE
  FIXED_AMOUNT
}

model Coupon {
  id          String     @id @default(uuid())
  code        String     @unique
  type        CouponType
  value       Decimal    @db.Decimal(10, 2)
  isActive    Boolean    @default(true)
  expiresAt   DateTime?

  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  @@index([code])
  @@map("coupons")
}
```

## 🔧 Using Prisma in Your Code

### Inject PrismaService:

The `PrismaModule` is marked as `@Global()`, so you can inject `PrismaService` anywhere:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      include: {
        addresses: true,
        orders: true,
      },
    });
  }

  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async create(data: CreateUserDto) {
    return this.prisma.user.create({
      data,
    });
  }
}
```

## 🎨 Prisma Studio

Prisma Studio is a GUI for viewing and editing data in your database:

```bash
pnpm prisma:studio
```

This will open a browser at `http://localhost:5555` where you can:

- View all tables
- Add, edit, and delete records
- Run filters and queries
- See relationships between tables

## 🔄 Migrations

### Development Workflow:

1. Modify your schema files in `prisma/schema/`
2. Run `pnpm prisma:migrate` to create a new migration
3. Give your migration a descriptive name
4. The migration will be applied automatically

### Production Deployment:

```bash
# Generate Prisma Client
pnpm prisma:generate

# Apply migrations
npx prisma migrate deploy
```

## 🧪 Testing

For testing, you can use the `cleanDatabase()` method from `PrismaService`:

```typescript
import { Test } from '@nestjs/testing';
import { PrismaService } from './prisma';

describe('UserService', () => {
  let prisma: PrismaService;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    prisma = module.get(PrismaService);
  });

  beforeEach(async () => {
    await prisma.cleanDatabase();
  });
});
```

## 📚 Database Schema

### Main Entities:

- **User**: Customer accounts with authentication
- **Address**: User shipping addresses
- **Category**: Product categories with hierarchy support
- **Product**: Products with variants and images
- **Cart**: Shopping carts and cart items
- **Order**: Orders with line items
- **Wishlist**: User wishlists
- **Review**: Product reviews and ratings

### Key Features:

- UUID primary keys
- Soft delete support (status fields)
- Timestamp tracking (createdAt, updatedAt)
- Indexes for performance
- Cascading deletes where appropriate
- Decimal precision for monetary values

## 🔐 Best Practices

1. **Always use migrations** in production (not `prisma db push`)
2. **Version control your migrations** (commit the `prisma/migrations` folder)
3. **Use transactions** for operations that must succeed or fail together
4. **Add indexes** to frequently queried fields
5. **Use proper decimal types** for monetary values
6. **Validate data** before passing to Prisma
7. **Handle errors** gracefully with try-catch blocks

## 📖 Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Multi-File Schema](https://www.prisma.io/docs/orm/prisma-schema/overview/location#multi-file-prisma-schema)
- [NestJS + Prisma Guide](https://docs.nestjs.com/recipes/prisma)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)

## 🐛 Troubleshooting

### Prisma Client is not generated:

```bash
pnpm prisma:generate
```

### Migration conflicts:

```bash
# Reset the database (WARNING: deletes all data)
npx prisma migrate reset
```

### Connection errors:

- Check your `DATABASE_URL` in `.env`
- Ensure PostgreSQL is running
- Verify database credentials

### Type errors after schema changes:

```bash
pnpm prisma:generate
```

---

Need help? Check the [Prisma Discord](https://pris.ly/discord) or [GitHub Issues](https://github.com/prisma/prisma/issues).
