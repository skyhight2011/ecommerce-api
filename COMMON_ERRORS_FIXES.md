# Common TypeScript Errors & Fixes

Quick reference for fixing common TypeScript errors in this project.

## ❌ Index Signature Missing Error

### Error Message
```
Index signature for type 'string' is missing in type 'UserEntity & Record<"password", unknown>'.
```

### What It Means
TypeScript can't verify that deleting a property is safe because the object doesn't have an index signature.

### ✅ Solution 1: Cast to Record (Current Fix)
```typescript
constructor(partial: Partial<UserEntity>) {
  Object.assign(this, partial);
  // Cast to Record to allow property deletion
  const self = this as Record<string, unknown>;
  if ('password' in self) {
    delete self.password;
  }
}
```

### ✅ Solution 2: Don't Include Password (Better)
```typescript
// In service, exclude password before creating entity
const user = await this.prisma.user.findUnique({
  where: { id },
  select: {
    id: true,
    email: true,
    firstName: true,
    lastName: true,
    phone: true,
    role: true,
    status: true,
    createdAt: true,
    updatedAt: true,
    // password: false (excluded by default)
  },
});

return new UserEntity(user);
```

### ✅ Solution 3: Use Omit Type
```typescript
export class UserEntity implements Omit<PrismaUser, 'password'> {
  // All properties except password
  
  constructor(partial: Omit<PrismaUser, 'password'>) {
    Object.assign(this, partial);
    // No need to delete - password never existed
  }
}
```

**Status**: ✅ Fixed with Solution 1

---

## ❌ No Unsafe Call Error

### Error Message
```
Unsafe call of a(n) `any` typed value
```

### What It Means
You're calling a method on a value that TypeScript can't verify is callable.

### Example
```typescript
// ❌ bcrypt has 'any' type
import * as bcrypt from 'bcrypt';
const hash = await bcrypt.hash('password', 10);
```

### ✅ Solutions

**1. Install Type Definitions**
```bash
npm install -D @types/bcrypt
```

**2. Import Properly**
```typescript
// ✅ Import default export
import bcrypt from 'bcrypt';

// ✅ Or use named import
import { hash } from 'bcrypt';
```

**3. Type the Import**
```typescript
import * as bcrypt from 'bcrypt';

// Add type assertion
const bcryptTyped = bcrypt as {
  hash: (data: string, saltRounds: number) => Promise<string>;
};
```

**Status**: ✅ @types/bcrypt already installed

---

## ❌ Unsafe Assignment Error

### Error Message
```
Unsafe assignment of an `any` value
```

### What It Means
You're assigning an `any` typed value to a variable, losing type safety.

### Example
```typescript
// ❌ updateData is 'any'
const updateData: any = { ...dto };
```

### ✅ Solution
```typescript
// ✅ Type it properly
const updateData: Partial<typeof dto> & { password?: string } = {
  ...dto,
};

// Or use a specific type
const updateData: Prisma.UserUpdateInput = {
  ...dto,
};
```

**Status**: ✅ Fixed in users.service.ts

---

## ❌ Unsafe Member Access Error

### Error Message
```
Unsafe member access .property on an `any` value
```

### What It Means
You're accessing a property on an `any` typed value.

### Example
```typescript
// ❌ request is 'any'
function handler(request: any) {
  return request.user.id; // Unsafe access
}
```

### ✅ Solution
```typescript
// ✅ Type the parameter
interface RequestWithUser {
  user: {
    id: string;
    email: string;
  };
}

function handler(request: RequestWithUser) {
  return request.user.id; // Type-safe
}

// Or use type guard
function handler(request: unknown) {
  if (isRequestWithUser(request)) {
    return request.user.id; // Type-safe after guard
  }
}
```

**Status**: ✅ Fixed in auth files

---

## ❌ Unsafe Return Error

### Error Message
```
Unsafe return of a value of type `any`
```

### What It Means
Function returns `any` typed value, losing type safety.

### Example
```typescript
// ❌ Returns 'any'
function getUser(): User {
  const data: any = fetchData();
  return data; // Unsafe return
}
```

### ✅ Solution
```typescript
// ✅ Type the intermediate value
function getUser(): User {
  const data: User = fetchData();
  return data;
}

// Or use type assertion with validation
function getUser(): User {
  const data = fetchData();
  if (!isUser(data)) {
    throw new Error('Invalid user data');
  }
  return data;
}
```

**Status**: ✅ Fixed in auth.service.ts

---

## ❌ Module Resolution Error

### Error Message
```
Cannot find module '@prisma/client' or its corresponding type declarations
```

### What It Means
Prisma Client hasn't been generated yet.

### ✅ Solution
```bash
# Generate Prisma Client
npx prisma generate

# Or use npm script
npm run prisma:generate
```

**Prevention**: Always run `prisma generate` after:
- Installing dependencies
- Changing schema
- Pulling repository

---

## ❌ Circular Dependency Error

### Error Message
```
Warning: Nest can't resolve dependencies of the UserService
```

### What It Means
Two modules/services depend on each other.

### ✅ Solution

**1. Use forwardRef**
```typescript
@Injectable()
export class UserService {
  constructor(
    @Inject(forwardRef(() => AuthService))
    private authService: AuthService,
  ) {}
}
```

**2. Restructure Dependencies**
```typescript
// Create a shared service
@Injectable()
export class SharedService {
  // Common functionality
}

// Both services use shared service
export class UserService {
  constructor(private shared: SharedService) {}
}

export class AuthService {
  constructor(private shared: SharedService) {}
}
```

---

## ❌ Async Without Await Error

### Error Message
```
Async method has no 'await' expression
```

### What It Means
Function is marked `async` but doesn't use `await`.

### ✅ Solutions

**1. Remove async**
```typescript
// ❌ Before
async getProfile() {
  return { name: 'John' };
}

// ✅ After
getProfile() {
  return { name: 'John' };
}
```

**2. Keep async for consistency**
```typescript
// ✅ If you plan to add await later
async getProfile() {
  // Will add async operations later
  return { name: 'John' };
}
```

**Status**: Rule disabled in eslint.config.mjs

---

## ❌ Property Has No Initializer Error

### Error Message
```
Property 'name' has no initializer and is not definitely assigned in the constructor
```

### What It Means
Property isn't initialized and TypeScript can't verify it will be assigned.

### ✅ Solutions

**1. Use Definite Assignment Assertion**
```typescript
export class UserDto {
  @IsString()
  name!: string; // ✅ '!' tells TS it will be assigned
}
```

**2. Initialize in Constructor**
```typescript
export class User {
  name: string;
  
  constructor() {
    this.name = ''; // ✅ Initialized
  }
}
```

**3. Make Optional**
```typescript
export class User {
  name?: string; // ✅ Optional property
}
```

**Status**: ✅ Using '!' in DTOs and entities

---

## 🛠️ Quick Fixes

### Clear TypeScript Cache
```bash
# If you see weird errors
rm -rf dist/
rm -rf node_modules/.cache/
npm run build
```

### Restart TypeScript Server (In Cursor)
1. `⌘+Shift+P` (Command Palette)
2. Type "TypeScript: Restart TS Server"
3. Press Enter

### Check TSConfig
```bash
# View effective TypeScript config
npx tsc --showConfig
```

### Verify Node Version
```bash
# Project requires Node 20+
node --version

# Switch version with fnm
fnm use 25.2.1
```

---

## 🔍 Debugging Type Errors

### See Inferred Types
```typescript
// Hover over variables in editor
const result = await fetchData();
//    ^? Hover to see type
```

### Print Type Information
```typescript
// Use 'as const' to narrow types
const config = {
  port: 3000,
  host: 'localhost'
} as const;
// config is readonly with literal types

// Check at runtime
console.log(typeof value);
console.log(value instanceof Array);
```

### Use TypeScript Playground
Test code at: https://www.typescriptlang.org/play

---

## 📋 Prevention Checklist

### Before Coding
- [ ] Run `npm run prisma:generate`
- [ ] Check Node version (`node -v`)
- [ ] Verify dependencies installed

### While Coding
- [ ] Import types from Prisma
- [ ] Type function parameters
- [ ] Type return values
- [ ] Use DTOs for API boundaries

### Before Committing
- [ ] Run `npm run lint`
- [ ] Run `npm run build`
- [ ] Fix all errors (warnings OK)
- [ ] Test locally

---

## 🎯 Common Patterns

### Pattern 1: Type Guard
```typescript
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj
  );
}

// Usage
if (isUser(data)) {
  console.log(data.email); // ✅ Type-safe
}
```

### Pattern 2: Utility Type
```typescript
// Pick specific fields
type UserProfile = Pick<User, 'id' | 'email' | 'name'>;

// Omit sensitive fields
type SafeUser = Omit<User, 'password'>;

// Make all optional
type PartialUser = Partial<User>;
```

### Pattern 3: Generic Function
```typescript
async function findById<T>(
  id: string,
  model: { findUnique: any }
): Promise<T | null> {
  return await model.findUnique({ where: { id } });
}

const user = await findById<User>('123', prisma.user);
```

---

## 📚 Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [NestJS TypeScript](https://docs.nestjs.com/techniques/typescript)
- [Prisma Type Safety](https://www.prisma.io/docs/concepts/components/prisma-client/advanced-type-safety)
- [ESLint TypeScript Rules](https://typescript-eslint.io/rules/)

---

## ✅ Current Project Status

### Type Safety Level
- **DTOs**: ✅ Fully typed
- **Entities**: ✅ Fully typed
- **Services**: ✅ Mostly typed (16 warnings)
- **Controllers**: ✅ Mostly typed
- **Guards**: ✅ Fully typed

### Build Status
- **Compilation**: ✅ Success
- **Linting**: ✅ 0 errors, 16 warnings
- **Runtime**: ✅ Working

### Next Steps
1. Fix remaining 16 warnings gradually
2. Add type guards for external data
3. Use Prisma types more extensively
4. Consider enabling stricter rules

---

**Last Updated**: After fixing index signature error  
**Status**: ✅ All critical errors fixed, project building successfully
