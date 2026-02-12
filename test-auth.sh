#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

API_URL="http://localhost:3000"
EMAIL="test@example.com"
PASSWORD="Test123!"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Authentication Testing Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: Health Check
echo -e "${BLUE}1. Testing Health Check (Public)...${NC}"
HEALTH=$(curl -s "$API_URL/")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "Response: $HEALTH"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Register User
echo -e "${BLUE}2. Registering new user...${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
        \"email\": \"$EMAIL\",
        \"password\": \"$PASSWORD\",
        \"firstName\": \"Test\",
        \"lastName\": \"User\"
    }")

if echo "$REGISTER_RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✓ Registration successful${NC}"
    TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"accessToken":"[^"]*' | sed 's/"accessToken":"//')
    echo "Token received (first 50 chars): ${TOKEN:0:50}..."
else
    echo -e "${RED}Note: User might already exist, trying login...${NC}"
    echo "Response: $REGISTER_RESPONSE"
fi
echo ""

# Test 3: Login
echo -e "${BLUE}3. Testing Login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"email\": \"$EMAIL\",
        \"password\": \"$PASSWORD\"
    }")

if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✓ Login successful${NC}"
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | sed 's/"accessToken":"//')
    echo "Token received (first 50 chars): ${TOKEN:0:50}..."
    
    # Pretty print the response
    if command -v jq &> /dev/null; then
        echo -e "\n${BLUE}User Info:${NC}"
        echo $LOGIN_RESPONSE | jq '.user'
    fi
else
    echo -e "${RED}✗ Login failed${NC}"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get Profile (Protected Route)
echo -e "${BLUE}4. Testing Protected Route (Get Profile)...${NC}"
PROFILE_RESPONSE=$(curl -s -X GET "$API_URL/auth/profile" \
    -H "Authorization: Bearer $TOKEN")

if echo "$PROFILE_RESPONSE" | grep -q "email"; then
    echo -e "${GREEN}✓ Profile access successful${NC}"
    if command -v jq &> /dev/null; then
        echo $PROFILE_RESPONSE | jq '.'
    else
        echo "Response: $PROFILE_RESPONSE"
    fi
else
    echo -e "${RED}✗ Profile access failed${NC}"
    echo "Response: $PROFILE_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Access Public Products Route
echo -e "${BLUE}5. Testing Public Products Route...${NC}"
PRODUCTS_RESPONSE=$(curl -s -X GET "$API_URL/products?page=1&limit=5")

if echo "$PRODUCTS_RESPONSE" | grep -q "data"; then
    echo -e "${GREEN}✓ Public products access successful${NC}"
    if command -v jq &> /dev/null; then
        echo "Total products: $(echo $PRODUCTS_RESPONSE | jq '.meta.total')"
    else
        echo "Response: $PRODUCTS_RESPONSE"
    fi
else
    echo -e "${RED}✗ Products access failed${NC}"
    echo "Response: $PRODUCTS_RESPONSE"
fi
echo ""

# Test 6: Access Protected Route Without Token
echo -e "${BLUE}6. Testing Protected Route Without Token (should fail)...${NC}"
NO_AUTH_RESPONSE=$(curl -s -X GET "$API_URL/users")

if echo "$NO_AUTH_RESPONSE" | grep -q "Unauthorized"; then
    echo -e "${GREEN}✓ Authorization correctly enforced${NC}"
    echo "Response: $NO_AUTH_RESPONSE"
else
    echo -e "${RED}✗ Authorization not working properly${NC}"
    echo "Response: $NO_AUTH_RESPONSE"
fi
echo ""

# Test 7: Try to access admin route (should fail for regular user)
echo -e "${BLUE}7. Testing Admin Route with Regular User Token (should fail)...${NC}"
ADMIN_RESPONSE=$(curl -s -X GET "$API_URL/users" \
    -H "Authorization: Bearer $TOKEN")

if echo "$ADMIN_RESPONSE" | grep -q "Forbidden\|data"; then
    if echo "$ADMIN_RESPONSE" | grep -q "Forbidden"; then
        echo -e "${GREEN}✓ Role-based access control working correctly${NC}"
        echo "Response: User does not have admin privileges"
    else
        echo -e "${BLUE}Note: User has admin access${NC}"
        if command -v jq &> /dev/null; then
            echo "Total users: $(echo $ADMIN_RESPONSE | jq '.meta.total')"
        fi
    fi
else
    echo -e "${RED}Response: $ADMIN_RESPONSE${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Authentication Testing Complete!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${BLUE}Your JWT Token (save this for API testing):${NC}"
echo "$TOKEN"
echo ""

echo -e "${BLUE}Quick Command References:${NC}"
echo -e "Export token:         ${GREEN}export TOKEN=\"$TOKEN\"${NC}"
echo -e "Test with curl:       ${GREEN}curl -H \"Authorization: Bearer \$TOKEN\" $API_URL/auth/profile${NC}"
echo -e "Swagger UI:           ${GREEN}$API_URL/api${NC}"
echo -e "Prisma Studio:        ${GREEN}npx prisma studio${NC}"
echo ""

echo -e "${BLUE}To upgrade user to admin:${NC}"
echo -e "${GREEN}npx prisma studio${NC}"
echo -e "Then find user '$EMAIL' and change role to 'ADMIN'"
echo ""
