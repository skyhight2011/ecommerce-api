# ESLint TypeScript Errors Guide

This guide explains common TypeScript ESLint errors and how to fix them.

## ❌ `@typescript-eslint/no-unsafe-call`

### What It Means
You're calling a function on a value that TypeScript can't verify is actually a function.

### Example Error
```typescript
// ❌ Error: bcrypt.hash might not be a function
const hash = await bcrypt.hash('password', 10);

// ❌ Error: callback might not be a function
const result = callback();

// ❌ Error: obj.method might not be a function
obj.method();
```

### Common Causes

1. **Untyped imports**
```typescript
// ❌ bcrypt has 'any' type
import * as bcrypt from 'bcrypt';
```

2. **Missing type definitions**
```typescript
// ❌ No @types/bcrypt installed
import bcrypt from 'bcrypt';
```

3. **Using 'any' typed values**
```typescript
function doSomething(callback: any) {
  callback(); // ❌ Error: callback is 'any'
}
```

### Solutions

#### Solution 1: Disable the Rule (Recommended for NestJS)
In `eslint.config.mjs`:
```javascript
{
  rules: {
    '@typescript-eslint/no-unsafe-call': 'off',
  }
}
```

**Status**: ✅ Already configured in this project

#### Solution 2: Add Type Definitions
```bash
# Install type definitions
npm install -D @types/bcrypt
npm install -D @types/package-name
```

#### Solution 3: Add Type Annotations
```typescript
// ✅ Type the callback
function doSomething(callback: () => void) {
  callback(); // No error
}

// ✅ Type the method
interface MyObject {
  method: () => void;
}
const obj: MyObject = { method: () => {} };
obj.method(); // No error
```

#### Solution 4: Use Type Assertion
```typescript
// ✅ Assert the type (use carefully)
const result = (callback as Function)();

// ✅ Better: Type guard
if (typeof callback === 'function') {
  callback();
}
```

---

## ❌ `@typescript-eslint/no-unsafe-assignment`

### What It Means
You're assigning a value of type `any` to a variable, which bypasses type safety.

### Example
```typescript
// ❌ Error
const user: any = getUser();
const name = user.name; // 'name' is now 'any'
```

### Solution
```typescript
// ✅ Use proper types
interface User {
  name: string;
}
const user: User = getUser();
const name = user.name; // 'name' is 'string'
```

**Status**: ✅ Disabled in this project (common in NestJS)

---

## ❌ `@typescript-eslint/no-unsafe-member-access`

### What It Means
You're accessing a property on a value of type `any`.

### Example
```typescript
// ❌ Error
function process(data: any) {
  return data.id; // Unsafe member access
}
```

### Solution
```typescript
// ✅ Type the parameter
interface Data {
  id: string;
}
function process(data: Data) {
  return data.id; // Safe
}

// ✅ Or use type guard
function process(data: any) {
  if (typeof data === 'object' && 'id' in data) {
    return data.id;
  }
}
```

**Status**: ✅ Disabled in this project

---

## ❌ `@typescript-eslint/no-unsafe-return`

### What It Means
You're returning a value of type `any` from a function.

### Example
```typescript
// ❌ Error
function getUser(): User {
  const data: any = fetchData();
  return data; // Unsafe return
}
```

### Solution
```typescript
// ✅ Type the intermediate value
function getUser(): User {
  const data: User = fetchData();
  return data;
}

// ✅ Or cast it
function getUser(): User {
  const data: any = fetchData();
  return data as User;
}
```

**Status**: ✅ Disabled in this project

---

## ❌ `@typescript-eslint/no-unsafe-argument`

### What It Means
You're passing an `any` typed value as a function argument.

### Example
```typescript
// ❌ Error
function saveUser(user: User) {
  const data: any = getData();
  saveUser(data); // Unsafe argument
}
```

### Solution
```typescript
// ✅ Type the data
const data: User = getData();
saveUser(data);

// ✅ Or validate it
if (isUser(data)) {
  saveUser(data);
}
```

**Status**: ⚠️ Set to 'warn' in this project

---

## ❌ `@typescript-eslint/require-await`

### What It Means
An `async` function has no `await` expression.

### Example
```typescript
// ❌ Error: No await in async function
async function getProfile() {
  return { name: 'John' };
}
```

### Solution
```typescript
// ✅ Remove async if not needed
function getProfile() {
  return { name: 'John' };
}

// ✅ Or keep if you'll add await later
async function getProfile() {
  // Will add await later
  return { name: 'John' };
}
```

**Status**: ✅ Disabled in this project

---

## 🎯 Project Configuration

### Current ESLint Rules

```javascript
// eslint.config.mjs
{
  rules: {
    // Disabled for NestJS compatibility
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-unsafe-assignment': 'off',
    '@typescript-eslint/no-unsafe-member-access': 'off',
    '@typescript-eslint/no-unsafe-return': 'off',
    '@typescript-eslint/no-unsafe-call': 'off',
    '@typescript-eslint/require-await': 'off',
    '@typescript-eslint/no-redundant-type-constituents': 'off',
    
    // Set to warnings
    '@typescript-eslint/no-floating-promises': 'warn',
    '@typescript-eslint/no-unsafe-argument': 'warn',
  }
}
```

### Why These Rules Are Disabled

**NestJS Pattern**: NestJS uses decorators and dependency injection that often require `any` types for:
- Request/Response objects
- Decorator parameters
- Dynamic imports
- Third-party library integrations

**Pragmatic Approach**: 
- Type safety where it matters most (DTOs, entities, services)
- Allow flexibility for framework patterns
- Focus on actual bugs vs. theoretical type issues

---

## 🛠️ When to Use Each Approach

### Disable Rules (Current Approach)
✅ **Use when**:
- Working with NestJS/Express
- Using decorators heavily
- Integrating third-party libraries
- Prototyping/MVP

❌ **Avoid when**:
- Building type-safe libraries
- Need strict type guarantees
- Working on critical systems

### Add Type Definitions
✅ **Use when**:
- Types are available
- Package has @types
- Long-term maintenance

### Type Assertions
✅ **Use when**:
- You know the type
- One-off cases
- Type definitions unavailable

⚠️ **Careful with**:
- Can hide real bugs
- No runtime validation
- Can become outdated

### Type Guards
✅ **Best for**:
- Runtime validation
- External data
- API responses
- User input

```typescript
// ✅ Type guard
function isUser(obj: any): obj is User {
  return obj && 
         typeof obj.id === 'string' &&
         typeof obj.email === 'string';
}

if (isUser(data)) {
  // data is now User type
  console.log(data.email);
}
```

---

## 📋 Quick Reference

### Check for Errors
```bash
# Run ESLint
pnpm run lint

# Check specific file
npx eslint src/path/to/file.ts

# Show all rules
npx eslint --print-config eslint.config.mjs
```

### Fix Errors
```bash
# Auto-fix
pnpm run lint --fix

# Format code
pnpm run format
```

### Editor Integration
Your Cursor editor will:
- ✅ Show errors inline
- ✅ Auto-fix on save
- ✅ Suggest quick fixes (⌘+.)

---

## 🎓 Best Practices

### 1. Type Your DTOs
```typescript
// ✅ Good
export class CreateUserDto {
  @IsEmail()
  email!: string;
  
  @IsString()
  password!: string;
}
```

### 2. Type Your Entities
```typescript
// ✅ Good
export class UserEntity implements User {
  id!: string;
  email!: string;
  role!: UserRole;
}
```

### 3. Type Function Parameters
```typescript
// ❌ Avoid
function createUser(data: any) { }

// ✅ Good
function createUser(data: CreateUserDto): Promise<User> { }
```

### 4. Use Interface Over Any
```typescript
// ❌ Avoid
const config: any = { port: 3000 };

// ✅ Good
interface Config {
  port: number;
}
const config: Config = { port: 3000 };
```

### 5. Validate External Data
```typescript
// ✅ Good
async function handleWebhook(@Body() body: any) {
  // Validate before using
  if (!isValidWebhook(body)) {
    throw new BadRequestException();
  }
  
  // Now safe to use
  await this.processWebhook(body);
}
```

---

## 🔍 Debugging Type Errors

### See Inferred Types
```typescript
// Hover over variables in Cursor to see types
const result = await fetchData();
//    ^? See inferred type here
```

### Check Type at Runtime
```typescript
console.log(typeof value); // 'string', 'number', 'object', etc.
console.log(value instanceof Array); // true/false
console.log('property' in object); // true/false
```

### Use TypeScript Playground
https://www.typescriptlang.org/play

---

## 📚 Resources

- [TypeScript ESLint Rules](https://typescript-eslint.io/rules/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Type Guards](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)

---

## ✅ Summary

For this project:
- ✅ Most strict type rules are **disabled**
- ✅ This is **normal** for NestJS projects
- ✅ Focus on typing DTOs, entities, and business logic
- ✅ Use `any` pragmatically for framework code
- ✅ Editor will auto-fix on save

**If you see the error**:
1. It's likely from TypeScript, not ESLint
2. Reload Cursor window (`⌘+Shift+P` → "Reload Window")
3. Check if types are installed (`@types/package`)
4. The rule is disabled, so it won't block builds

**Need help?** Check `EDITOR_SETUP.md` for more troubleshooting.
