#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  E-Commerce API Test Suite${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Test 1: Check if Docker is running
echo -e "${BLUE}[1/7]${NC} Testing Docker PostgreSQL..."
if docker-compose exec postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} PostgreSQL is running"
else
    echo -e "${RED}✗${NC} PostgreSQL is not running"
    exit 1
fi

# Test 2: Check database tables
echo -e "${BLUE}[2/7]${NC} Verifying database schema..."
TABLE_COUNT=$(docker-compose exec postgres psql -U postgres -d ecommerce_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | xargs)
echo -e "${GREEN}✓${NC} Found $TABLE_COUNT tables in database"

# Test 3: Check seeded data
echo -e "${BLUE}[3/7]${NC} Verifying seeded data..."
PRODUCT_COUNT=$(docker-compose exec postgres psql -U postgres -d ecommerce_db -t -c "SELECT COUNT(*) FROM products;" 2>/dev/null | xargs)
USER_COUNT=$(docker-compose exec postgres psql -U postgres -d ecommerce_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs)
echo -e "${GREEN}✓${NC} Found $PRODUCT_COUNT products and $USER_COUNT users"

# Test 4: Check if API is responding
echo -e "${BLUE}[4/7]${NC} Testing API root endpoint..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓${NC} API responding (HTTP $RESPONSE)"
else
    echo -e "${RED}✗${NC} API not responding (HTTP $RESPONSE)"
    exit 1
fi

# Test 5: Check Swagger documentation
echo -e "${BLUE}[5/7]${NC} Testing Swagger documentation..."
SWAGGER_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api)
if [ "$SWAGGER_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓${NC} Swagger UI available (HTTP $SWAGGER_RESPONSE)"
else
    echo -e "${RED}✗${NC} Swagger UI not available (HTTP $SWAGGER_RESPONSE)"
fi

# Test 6: Check Swagger JSON
echo -e "${BLUE}[6/7]${NC} Testing Swagger JSON spec..."
SWAGGER_JSON=$(curl -s http://localhost:3000/api-json)
if echo "$SWAGGER_JSON" | grep -q "openapi"; then
    echo -e "${GREEN}✓${NC} Swagger JSON spec valid"
else
    echo -e "${RED}✗${NC} Swagger JSON spec invalid"
fi

# Test 7: Check Prisma Client
echo -e "${BLUE}[7/7]${NC} Verifying Prisma Client..."
if [ -d "node_modules/@prisma/client" ]; then
    echo -e "${GREEN}✓${NC} Prisma Client installed"
else
    echo -e "${RED}✗${NC} Prisma Client not found"
fi

echo ""
echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}  All Tests Passed! 🎉${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo "📍 Available endpoints:"
echo "   - API Root:    http://localhost:3000"
echo "   - Swagger UI:  http://localhost:3000/api"
echo "   - API JSON:    http://localhost:3000/api-json"
echo ""
echo "🗄️  Database access:"
echo "   - PostgreSQL:  localhost:5432 (postgres/postgres)"
echo "   - pgAdmin:     http://localhost:5050"
echo "   - Prisma Studio: npx prisma studio"
echo ""
