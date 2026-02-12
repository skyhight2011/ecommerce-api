import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import pg from 'pg';
import * as bcrypt from 'bcrypt';
import 'dotenv/config';

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Start seeding...');

  // Create categories
  const electronicsCategory = await prisma.category.upsert({
    where: { slug: 'electronics' },
    update: {},
    create: {
      name: 'Electronics',
      slug: 'electronics',
      description: 'Electronic devices and accessories',
    },
  });

  const clothingCategory = await prisma.category.upsert({
    where: { slug: 'clothing' },
    update: {},
    create: {
      name: 'Clothing',
      slug: 'clothing',
      description: 'Apparel and fashion items',
    },
  });

  console.log('Created categories:', { electronicsCategory, clothingCategory });

  // Create admin user
  const adminPassword = await bcrypt.hash('Admin123!', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@admin.com' },
    update: {},
    create: {
      email: 'admin@admin.com',
      password: adminPassword,
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });

  console.log('Created admin user:', admin.email);

  // Create a sample customer user
  const customerPassword = await bcrypt.hash('Customer123!', 10);
  const customer = await prisma.user.upsert({
    where: { email: 'customer@example.com' },
    update: {},
    create: {
      email: 'customer@example.com',
      password: customerPassword,
      firstName: 'John',
      lastName: 'Doe',
      role: 'CUSTOMER',
      status: 'ACTIVE',
    },
  });

  console.log('Created customer user:', customer.email);

  // Create sample products
  const laptop = await prisma.product.upsert({
    where: { slug: 'macbook-pro-16' },
    update: {},
    create: {
      name: 'MacBook Pro 16"',
      slug: 'macbook-pro-16',
      description: 'Powerful laptop for professionals',
      price: 2499.99,
      comparePrice: 2799.99,
      sku: 'MBP16-001',
      quantity: 50,
      status: 'ACTIVE',
      categoryId: electronicsCategory.id,
      metaTitle: 'MacBook Pro 16" - Best Laptop for Professionals',
      metaDescription: 'Get the powerful MacBook Pro 16" with M3 chip',
    },
  });

  const tshirt = await prisma.product.upsert({
    where: { slug: 'classic-tshirt' },
    update: {},
    create: {
      name: 'Classic T-Shirt',
      slug: 'classic-tshirt',
      description: 'Comfortable cotton t-shirt',
      price: 29.99,
      sku: 'TS-001',
      quantity: 200,
      status: 'ACTIVE',
      categoryId: clothingCategory.id,
    },
  });

  console.log('Created products:', { laptop, tshirt });

  console.log('Seeding finished.');
}

main()
  .catch((e: unknown) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
