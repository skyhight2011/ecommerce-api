# Type-Safe Patterns Guide

This guide shows how to write type-safe code instead of using `any` types.

## ✅ Type-Safe Solutions Applied

### 1. Typed Request Objects

**❌ Before (Using `any`)**:
```typescript
@Get('profile')
async getProfile(@Request() req: any) {
  return req.user; // ❌ Unsafe access
}
```

**✅ After (Type-Safe)**:
```typescript
// Define the user type
interface UserPayload {
  id: string;
  email: string;
  role: string;
  firstName?: string | null;
  lastName?: string | null;
  status: string;
}

@Get('profile')
getProfile(@Request() req: { user: UserPayload }) {
  return req.user; // ✅ Type-safe access
}

// Or use a proper interface
interface RequestWithUser extends Request {
  user: UserPayload;
}

@Get('profile')
getProfile(@Request() req: RequestWithUser) {
  return req.user; // ✅ Even better
}
```

**Benefits**:
- ✅ Auto-completion in editor
- ✅ Type checking
- ✅ Refactoring safety
- ✅ Catch errors at compile time

---

### 2. Typed Function Parameters

**❌ Before (Using `any`)**:
```typescript
private generateAuthResponse(user: any): AuthResponseDto {
  return {
    user: {
      id: user.id, // ❌ No type safety
      email: user.email,
      role: user.role,
    },
  };
}
```

**✅ After (Type-Safe)**:
```typescript
private generateAuthResponse(user: {
  id: string;
  email: string;
  firstName?: string | null;
  lastName?: string | null;
  role: string;
}): AuthResponseDto {
  return {
    user: {
      id: user.id, // ✅ Type-safe
      email: user.email,
      firstName: user.firstName ?? undefined,
      lastName: user.lastName ?? undefined,
      role: user.role,
    },
  };
}

// Or use Prisma generated types
import { User } from '@prisma/client';

private generateAuthResponse(
  user: Pick<User, 'id' | 'email' | 'firstName' | 'lastName' | 'role'>
): AuthResponseDto {
  // Implementation...
}
```

**Benefits**:
- ✅ Compiler catches missing properties
- ✅ Refactor with confidence
- ✅ Self-documenting code

---

### 3. Typed Decorators

**❌ Before (Using `any`)**:
```typescript
export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user; // ❌ 'any' type

    return data ? user?.[data] : user; // ❌ Unsafe access
  },
);
```

**✅ After (Type-Safe)**:
```typescript
interface UserPayload {
  id: string;
  email: string;
  role: string;
  firstName?: string | null;
  lastName?: string | null;
  status: string;
}

export const CurrentUser = createParamDecorator(
  (data: keyof UserPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<{ user: UserPayload }>();
    const user = request.user; // ✅ Typed as UserPayload

    return data ? user?.[data] : user; // ✅ Type-safe access
  },
);
```

**Benefits**:
- ✅ `keyof UserPayload` ensures only valid properties
- ✅ Auto-completion for property names
- ✅ Compile-time error if property doesn't exist

---

### 4. Typed Update Operations

**❌ Before (Using `any`)**:
```typescript
async update(id: string, updateDto: UpdateUserDto): Promise<UserEntity> {
  const updateData: any = { ...updateDto }; // ❌ Loses all type safety

  if (updateDto.password) {
    updateData.password = await bcrypt.hash(updateDto.password, 10);
  }

  return await this.prisma.user.update({
    where: { id },
    data: updateData, // ❌ Could pass wrong data
  });
}
```

**✅ After (Type-Safe)**:
```typescript
async update(id: string, updateDto: UpdateUserDto): Promise<UserEntity> {
  // Properly typed with specific shape
  const updateData: Partial<typeof updateDto> & { password?: string } = {
    ...updateDto,
  };

  if (updateDto.password) {
    updateData.password = await bcrypt.hash(updateDto.password, 10);
  }

  return await this.prisma.user.update({
    where: { id },
    data: updateData, // ✅ Type-checked
  });
}
```

**Benefits**:
- ✅ Type checking on update data
- ✅ Can't accidentally pass wrong properties
- ✅ Prisma validates at runtime

---

### 5. Safe Type Deletion

**❌ Before (Using `any`)**:
```typescript
constructor(partial: Partial<UserEntity>) {
  Object.assign(this, partial);
  delete (this as any).password; // ❌ Bypasses type system
}
```

**✅ After (Type-Safe)**:
```typescript
constructor(partial: Partial<UserEntity>) {
  Object.assign(this, partial);
  // Type-safe deletion
  if ('password' in this) {
    delete (this as Partial<Record<string, unknown>>).password;
  }
}

// Or better: Don't include password in the first place
constructor(partial: Omit<Partial<UserEntity>, 'password'>) {
  Object.assign(this, partial);
  // No need to delete - password never existed
}
```

**Benefits**:
- ✅ More explicit about what we're doing
- ✅ Still type-safe
- ✅ No `any` escape hatch

---

## 🎯 Common Patterns

### Pattern 1: Type Guards

Use type guards to safely check types at runtime:

```typescript
// Define the type
interface User {
  id: string;
  email: string;
  role: string;
}

// Create type guard
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj &&
    'role' in obj &&
    typeof (obj as User).id === 'string' &&
    typeof (obj as User).email === 'string' &&
    typeof (obj as User).role === 'string'
  );
}

// Use it
function processUser(data: unknown) {
  if (!isUser(data)) {
    throw new Error('Invalid user data');
  }
  
  // Now 'data' is typed as User
  console.log(data.email); // ✅ Type-safe
}
```

### Pattern 2: Utility Types

Use TypeScript utility types:

```typescript
import { User } from '@prisma/client';

// Pick specific fields
type UserProfile = Pick<User, 'id' | 'email' | 'firstName' | 'lastName'>;

// Omit sensitive fields
type SafeUser = Omit<User, 'password'>;

// Make fields optional
type PartialUser = Partial<User>;

// Make fields required
type RequiredUser = Required<User>;

// Extract keys
type UserKeys = keyof User;

// Readonly
type ImmutableUser = Readonly<User>;
```

### Pattern 3: Generic Functions

Create reusable type-safe functions:

```typescript
// Generic response wrapper
interface ApiResponse<T> {
  data: T;
  message: string;
  success: boolean;
}

function createResponse<T>(data: T, message: string): ApiResponse<T> {
  return {
    data,
    message,
    success: true,
  };
}

// Usage
const userResponse = createResponse(user, 'User fetched');
// userResponse.data is typed as typeof user
```

### Pattern 4: Discriminated Unions

For different response types:

```typescript
type ApiResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };

async function fetchUser(id: string): Promise<ApiResult<User>> {
  try {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      return { success: false, error: 'User not found' };
    }
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: 'Database error' };
  }
}

// Usage with type narrowing
const result = await fetchUser('123');
if (result.success) {
  console.log(result.data.email); // ✅ Type-safe
} else {
  console.error(result.error); // ✅ Type-safe
}
```

---

## 📋 Checklist for Type Safety

### Before Writing Code
- [ ] Import types from Prisma (`import { User } from '@prisma/client'`)
- [ ] Define interfaces for complex objects
- [ ] Use DTOs for API inputs/outputs
- [ ] Create type guards for runtime validation

### While Writing Code
- [ ] Avoid `any` - use `unknown` if type is truly unknown
- [ ] Use utility types (`Pick`, `Omit`, `Partial`, etc.)
- [ ] Type function parameters explicitly
- [ ] Type function return values explicitly

### After Writing Code
- [ ] Check for `any` in your code
- [ ] Add JSDoc comments for complex types
- [ ] Test with TypeScript strict mode
- [ ] Run ESLint to catch issues

---

## 🚀 Gradual Migration Strategy

If you have existing code with `any`:

### Step 1: Find All `any` Usage
```bash
# Search for 'any' in your code
grep -r ": any" src/

# Or use ESLint
npx eslint src/ --format=stylish | grep "no-explicit-any"
```

### Step 2: Enable Warnings (Not Errors)
```javascript
// eslint.config.mjs
{
  rules: {
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unsafe-assignment': 'warn',
    '@typescript-eslint/no-unsafe-call': 'warn',
  }
}
```

### Step 3: Fix One File at a Time
1. Start with DTOs and entities (easiest)
2. Then services (medium)
3. Finally controllers and guards (can be complex)

### Step 4: Gradually Increase Strictness
```javascript
// Once most files are fixed, change to errors
{
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
  }
}
```

---

## 🎓 Best Practices

### 1. Always Type DTOs
```typescript
// ✅ Good
export class CreateUserDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(6)
  password!: string;
}
```

### 2. Use Prisma Types
```typescript
// ✅ Good
import { User, Prisma } from '@prisma/client';

type UserWithOrders = Prisma.UserGetPayload<{
  include: { orders: true };
}>;
```

### 3. Type Service Methods
```typescript
// ✅ Good
async findAll(
  page: number = 1,
  limit: number = 10
): Promise<{ data: User[]; total: number }> {
  // Implementation
}
```

### 4. Use Branded Types for IDs
```typescript
// ✅ Good - prevents mixing different ID types
type UserId = string & { readonly brand: unique symbol };
type OrderId = string & { readonly brand: unique symbol };

function getUserById(id: UserId) { }
function getOrderById(id: OrderId) { }

// This would be a compile error:
// getUserById(orderId); // ❌ Type mismatch
```

---

## 📚 Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Prisma Type Utilities](https://www.prisma.io/docs/concepts/components/prisma-client/advanced-type-safety)
- [NestJS TypeScript Tips](https://docs.nestjs.com/techniques/typescript)

---

## ✅ Summary

Your codebase now uses these type-safe patterns:

1. ✅ **Typed Request Objects** - No more `any` for req
2. ✅ **Typed Function Parameters** - Explicit interfaces
3. ✅ **Typed Decorators** - Type-safe property access
4. ✅ **Typed Update Operations** - Proper partial types
5. ✅ **Safe Deletion** - No `any` type casting

**Benefits Achieved**:
- 🎯 Catch errors at compile time
- 🚀 Better IDE auto-completion
- 📝 Self-documenting code
- 🔄 Safer refactoring
- 🐛 Fewer runtime bugs

**Next Steps**:
1. Review warnings from ESLint
2. Fix remaining `any` usage gradually
3. Add type guards for external data
4. Use Prisma generated types more

Keep your code type-safe! 💪
