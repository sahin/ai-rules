# Refactoring Guidelines

## 🔄 REFACTORING PHILOSOPHY

### **Definition**
Refactoring is the process of improving the internal structure of existing code without changing its external behavior. It's a disciplined technique for improving the design of existing code while preserving functionality.

### **Core Principles**
- **Preserve behavior**: External functionality remains unchanged
- **Improve structure**: Make code more readable, maintainable, and extensible  
- **Small steps**: Make incremental changes rather than massive rewrites
- **Test-driven**: Maintain test coverage throughout the process
- **Continuous improvement**: Refactor opportunistically during feature work

---

## ⏰ WHEN TO REFACTOR (MANDATORY TRIGGERS)

### **Rule of Three**
When you see the same code pattern three times, extract it into a reusable function or component.

```typescript
// ❌ BEFORE - Duplicated validation logic
function createUser(userData: UserData) {
  if (!userData.email || !userData.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!userData.password || userData.password.length < 8) {
    throw new Error('Password too short');
  }
  // Create user logic
}

function updateUser(id: string, userData: UserData) {
  if (!userData.email || !userData.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!userData.password || userData.password.length < 8) {
    throw new Error('Password too short');
  }
  // Update user logic
}

function validateUserForRegistration(userData: UserData) {
  if (!userData.email || !userData.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!userData.password || userData.password.length < 8) {
    throw new Error('Password too short');
  }
  // Additional registration validation
}

// ✅ AFTER - Extracted validation function
function validateUserData(userData: UserData): void {
  if (!userData.email || !userData.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!userData.password || userData.password.length < 8) {
    throw new Error('Password too short');
  }
}

function createUser(userData: UserData) {
  validateUserData(userData);
  // Create user logic
}

function updateUser(id: string, userData: UserData) {
  validateUserData(userData);
  // Update user logic
}

function validateUserForRegistration(userData: UserData) {
  validateUserData(userData);
  // Additional registration validation
}
```

### **Before Adding New Features**
Always refactor messy code before adding new functionality to it.

```typescript
// ❌ BAD - Adding to messy existing code
class UserService {
  async processUser(userData: any) {
    // 150 lines of mixed concerns:
    // - validation
    // - business logic
    // - database operations
    // - email sending
    // - logging
    // - error handling
    
    // Now trying to add new feature here makes it worse
    if (userData.subscriptionType === 'premium') {
      // New premium feature logic mixed in
    }
  }
}

// ✅ GOOD - Refactor first, then add
class UserService {
  async processUser(userData: UserData) {
    this.validateUser(userData);
    const user = await this.createUser(userData);
    await this.sendWelcomeEmail(user);
    
    // Clean place to add new feature
    if (userData.subscriptionType === 'premium') {
      await this.setupPremiumFeatures(user);
    }
    
    return user;
  }
  
  private validateUser(userData: UserData) { /* focused validation */ }
  private async createUser(userData: UserData) { /* focused creation */ }
  private async sendWelcomeEmail(user: User) { /* focused email */ }
  private async setupPremiumFeatures(user: User) { /* new feature */ }
}
```

### **When Fixing Bugs in Complex Areas**
Clean up the code structure while fixing bugs to prevent future issues.

### **During Code Reviews**
If code review reveals structural issues, refactor before merging.

### **Performance Issues Identified**
Refactor inefficient code patterns when performance problems are discovered.

---

## 🏗️ REFACTORING PROCESS (MANDATORY)

### **1. Write Comprehensive Tests First**
Before any refactoring, ensure complete test coverage:

```typescript
// STEP 1: Write tests for existing behavior
describe('UserService', () => {
  describe('processUser', () => {
    it('should create user with valid data', async () => {
      const userData = { email: 'test@example.com', password: 'password123' };
      const result = await userService.processUser(userData);
      expect(result.email).toBe('test@example.com');
    });
    
    it('should throw error for invalid email', async () => {
      const userData = { email: 'invalid-email', password: 'password123' };
      await expect(userService.processUser(userData)).rejects.toThrow('Invalid email');
    });
    
    it('should send welcome email', async () => {
      const userData = { email: 'test@example.com', password: 'password123' };
      await userService.processUser(userData);
      expect(emailService.sendWelcomeEmail).toHaveBeenCalled();
    });
    
    // Test ALL existing behaviors before refactoring
  });
});
```

### **2. Make Small, Incremental Changes**
Never make massive changes in one commit:

```bash
# ❌ BAD - Massive refactor in one commit
git add .
git commit -m "Refactor entire user service"

# ✅ GOOD - Step-by-step refactoring
git add src/services/UserService.ts
git commit -m "refactor: extract user validation to separate method"

git add src/services/UserService.ts
git commit -m "refactor: extract email sending to separate method"  

git add src/services/UserService.ts
git commit -m "refactor: extract database operations to separate method"

git add src/services/UserService.ts
git commit -m "refactor: simplify main processUser method"
```

### **3. Run Tests After Each Change**
```bash
# After each small refactoring step:
npm test
npm run type-check
npm run lint

# Only proceed if all tests pass
```

### **4. Commit Frequently**
Each logical refactoring step should be its own commit:

```bash
# Descriptive commit messages for refactoring
git commit -m "refactor: extract validateUser method from processUser"
git commit -m "refactor: move email logic to separate service"  
git commit -m "refactor: replace switch statement with strategy pattern"
git commit -m "refactor: simplify error handling in UserService"
```

---

## 🚩 RED FLAGS REQUIRING REFACTOR

### **Code Complexity Indicators**

#### **Functions Longer Than 50 Lines**
```typescript
// ❌ RED FLAG - 80+ line function
async function processOrder(orderData: OrderData) {
  // Lines 1-20: Input validation
  if (!orderData.items || orderData.items.length === 0) {
    throw new Error('No items in order');
  }
  for (const item of orderData.items) {
    if (!item.productId || !item.quantity || item.quantity <= 0) {
      throw new Error('Invalid item data');
    }
  }
  
  // Lines 21-40: Inventory checks
  for (const item of orderData.items) {
    const product = await productService.getById(item.productId);
    if (!product) {
      throw new Error('Product not found');
    }
    if (product.stock < item.quantity) {
      throw new Error('Insufficient stock');
    }
  }
  
  // Lines 41-60: Price calculations
  let total = 0;
  for (const item of orderData.items) {
    const product = await productService.getById(item.productId);
    total += product.price * item.quantity;
  }
  if (orderData.discountCode) {
    const discount = await discountService.getByCode(orderData.discountCode);
    if (discount && discount.isValid) {
      total -= total * (discount.percentage / 100);
    }
  }
  
  // Lines 61-80: Payment and order creation
  const payment = await paymentService.charge({
    amount: total,
    paymentMethod: orderData.paymentMethod,
    customerId: orderData.customerId
  });
  
  const order = await orderRepository.create({
    ...orderData,
    total,
    paymentId: payment.id,
    status: 'confirmed'
  });
  
  await emailService.sendOrderConfirmation(order);
  return order;
}

// ✅ REFACTORED - Extracted to focused methods
class OrderService {
  async processOrder(orderData: OrderData): Promise<Order> {
    this.validateOrderData(orderData);
    await this.checkInventoryAvailability(orderData.items);
    const total = await this.calculateOrderTotal(orderData);
    const payment = await this.processPayment(total, orderData);
    const order = await this.createOrder(orderData, total, payment);
    await this.sendConfirmationEmail(order);
    return order;
  }
  
  private validateOrderData(orderData: OrderData) { /* focused validation */ }
  private async checkInventoryAvailability(items: OrderItem[]) { /* focused inventory */ }
  private async calculateOrderTotal(orderData: OrderData) { /* focused calculation */ }
  private async processPayment(total: number, orderData: OrderData) { /* focused payment */ }
  private async createOrder(orderData: OrderData, total: number, payment: Payment) { /* focused creation */ }
  private async sendConfirmationEmail(order: Order) { /* focused email */ }
}
```

#### **Classes Longer Than 300 Lines**
When a class exceeds 300 lines, consider:
- Single Responsibility Principle violations
- Extract related methods into separate services
- Use composition over inheritance
- Split into multiple focused classes

#### **Cyclomatic Complexity > 10**
```typescript
// ❌ HIGH COMPLEXITY - Nested conditions
function determineShippingCost(order: Order): number {
  if (order.country === 'US') {
    if (order.state === 'CA') {
      if (order.total > 100) {
        if (order.isPrimeMember) {
          return 0;
        } else {
          return 5.99;
        }
      } else {
        return 9.99;
      }
    } else if (order.state === 'NY') {
      if (order.total > 50) {
        return 0;
      } else {
        return 7.99;
      }
    } else {
      return 12.99;
    }
  } else if (order.country === 'CA') {
    return 15.99;
  } else {
    return 25.99;
  }
}

// ✅ REDUCED COMPLEXITY - Strategy pattern
interface ShippingStrategy {
  calculateCost(order: Order): number;
}

class USShippingStrategy implements ShippingStrategy {
  calculateCost(order: Order): number {
    const stateRules = {
      'CA': () => order.total > 100 ? (order.isPrimeMember ? 0 : 5.99) : 9.99,
      'NY': () => order.total > 50 ? 0 : 7.99
    };
    
    return stateRules[order.state] ? stateRules[order.state]() : 12.99;
  }
}

class CanadaShippingStrategy implements ShippingStrategy {
  calculateCost(order: Order): number {
    return 15.99;
  }
}

class InternationalShippingStrategy implements ShippingStrategy {
  calculateCost(order: Order): number {
    return 25.99;
  }
}

class ShippingCalculator {
  private strategies = {
    'US': new USShippingStrategy(),
    'CA': new CanadaShippingStrategy()
  };
  
  calculateShippingCost(order: Order): number {
    const strategy = this.strategies[order.country] || new InternationalShippingStrategy();
    return strategy.calculateCost(order);
  }
}
```

#### **Duplicate Code Blocks (> 5 Lines)**
```typescript
// ❌ DUPLICATE CODE
function sendEmailNotification(user: User, subject: string, content: string) {
  const transporter = nodemailer.createTransporter({
    host: process.env.SMTP_HOST,
    port: 587,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });
  
  await transporter.sendMail({
    from: 'noreply@company.com',
    to: user.email,
    subject,
    html: content
  });
}

function sendSMSNotification(user: User, message: string) {
  const client = new TwilioClient(
    process.env.TWILIO_SID,
    process.env.TWILIO_TOKEN
  );
  
  await client.messages.create({
    body: message,
    from: process.env.TWILIO_FROM,
    to: user.phoneNumber
  });
}

// ✅ EXTRACTED COMMON PATTERN
abstract class NotificationService {
  abstract send(user: User, message: NotificationMessage): Promise<void>;
}

class EmailNotificationService extends NotificationService {
  private transporter = nodemailer.createTransporter({
    host: process.env.SMTP_HOST,
    port: 587,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });
  
  async send(user: User, message: NotificationMessage): Promise<void> {
    await this.transporter.sendMail({
      from: 'noreply@company.com',
      to: user.email,
      subject: message.subject,
      html: message.content
    });
  }
}

class SMSNotificationService extends NotificationService {
  private client = new TwilioClient(
    process.env.TWILIO_SID,
    process.env.TWILIO_TOKEN
  );
  
  async send(user: User, message: NotificationMessage): Promise<void> {
    await this.client.messages.create({
      body: message.content,
      from: process.env.TWILIO_FROM,
      to: user.phoneNumber
    });
  }
}

class NotificationManager {
  constructor(
    private emailService: EmailNotificationService,
    private smsService: SMSNotificationService
  ) {}
  
  async notify(user: User, message: NotificationMessage, channels: NotificationChannel[]) {
    const promises = channels.map(channel => {
      switch (channel) {
        case 'email':
          return this.emailService.send(user, message);
        case 'sms':
          return this.smsService.send(user, message);
        default:
          throw new Error(`Unsupported notification channel: ${channel}`);
      }
    });
    
    await Promise.all(promises);
  }
}
```

---

## 🔧 COMMON REFACTORING PATTERNS

### **Extract Method**
Break down large functions into smaller, focused methods:

```typescript
// BEFORE
function processUserRegistration(userData: any) {
  // 50 lines of mixed logic
}

// AFTER
function processUserRegistration(userData: UserData) {
  validateUserData(userData);
  const user = createUserRecord(userData);
  setupUserProfile(user);
  sendWelcomeEmail(user);
  logUserRegistration(user);
  return user;
}
```

### **Extract Class**
When a class has too many responsibilities:

```typescript
// BEFORE - God class
class UserManager {
  validateEmail() { /* email validation */ }
  hashPassword() { /* password hashing */ }
  saveToDatabase() { /* database operations */ }
  sendWelcomeEmail() { /* email sending */ }
  generateReport() { /* reporting */ }
  processPayment() { /* payment processing */ }
}

// AFTER - Separated responsibilities
class UserValidator {
  validateEmail(email: string): boolean { /* focused validation */ }
  validatePassword(password: string): boolean { /* focused validation */ }
}

class UserRepository {
  async save(user: User): Promise<User> { /* focused persistence */ }
  async findById(id: string): Promise<User> { /* focused retrieval */ }
}

class EmailService {
  async sendWelcomeEmail(user: User): Promise<void> { /* focused email */ }
}

class UserService {
  constructor(
    private validator: UserValidator,
    private repository: UserRepository,
    private emailService: EmailService
  ) {}
  
  async registerUser(userData: UserData): Promise<User> {
    this.validator.validateEmail(userData.email);
    this.validator.validatePassword(userData.password);
    const user = await this.repository.save(userData);
    await this.emailService.sendWelcomeEmail(user);
    return user;
  }
}
```

### **Replace Conditional with Polymorphism**
```typescript
// BEFORE - Switch statement
function calculateShipping(order: Order): number {
  switch (order.shippingType) {
    case 'standard':
      return 5.99;
    case 'express':
      return 12.99;
    case 'overnight':
      return 24.99;
    default:
      throw new Error('Unknown shipping type');
  }
}

// AFTER - Polymorphism
interface ShippingMethod {
  calculateCost(order: Order): number;
}

class StandardShipping implements ShippingMethod {
  calculateCost(order: Order): number {
    return 5.99;
  }
}

class ExpressShipping implements ShippingMethod {
  calculateCost(order: Order): number {
    return 12.99;
  }
}

class OvernightShipping implements ShippingMethod {
  calculateCost(order: Order): number {
    return 24.99;
  }
}

class ShippingCalculator {
  private methods: Record<string, ShippingMethod> = {
    'standard': new StandardShipping(),
    'express': new ExpressShipping(),
    'overnight': new OvernightShipping()
  };
  
  calculateShipping(order: Order): number {
    const method = this.methods[order.shippingType];
    if (!method) {
      throw new Error(`Unknown shipping type: ${order.shippingType}`);
    }
    return method.calculateCost(order);
  }
}
```

### **Introduce Parameter Object**
When functions have too many parameters:

```typescript
// BEFORE - Too many parameters
function createUser(
  firstName: string,
  lastName: string,
  email: string,
  phoneNumber: string,
  address: string,
  city: string,
  state: string,
  zipCode: string,
  country: string
): User {
  // Implementation
}

// AFTER - Parameter object
interface UserCreationData {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address: {
    street: string;
    city: string;
    state: string;
    zipCode: string;
    country: string;
  };
}

function createUser(userData: UserCreationData): User {
  // Implementation
}
```

---

## 🧪 REFACTORING SAFETY NETS

### **Comprehensive Test Coverage**
```typescript
// Test existing behavior before refactoring
describe('Before Refactoring', () => {
  it('should handle all existing use cases', () => {
    // Test all current functionality
    // These tests should pass before AND after refactoring
  });
  
  it('should handle edge cases', () => {
    // Test boundary conditions
  });
  
  it('should handle error cases', () => {
    // Test error handling
  });
});
```

### **Feature Flags for Large Refactors**
```typescript
// Use feature flags for risky refactors
class OrderService {
  async processOrder(orderData: OrderData): Promise<Order> {
    if (featureFlags.isEnabled('new-order-processing')) {
      return this.processOrderV2(orderData);  // New refactored version
    } else {
      return this.processOrderV1(orderData);  // Legacy version
    }
  }
}
```

### **Parallel Implementation**
For critical systems, implement new version alongside old:

```typescript
// Keep both versions during transition
class PaymentProcessor {
  async processPayment(paymentData: PaymentData): Promise<Payment> {
    // Process with both old and new implementation
    const [legacyResult, newResult] = await Promise.allSettled([
      this.processPaymentLegacy(paymentData),
      this.processPaymentNew(paymentData)
    ]);
    
    // Compare results and log discrepancies
    if (this.resultsMatch(legacyResult, newResult)) {
      return legacyResult.value;
    } else {
      this.logDiscrepancy(legacyResult, newResult);
      return legacyResult.value;  // Use legacy as fallback
    }
  }
}
```

---

## 📋 REFACTORING CHECKLIST

### **Pre-Refactoring**
- [ ] Comprehensive test suite exists and passes
- [ ] Performance benchmarks established
- [ ] Backup/branch created for rollback
- [ ] Stakeholders informed of refactoring plan
- [ ] Feature flags implemented for risky changes

### **During Refactoring**
- [ ] Make small, incremental changes
- [ ] Run tests after each step
- [ ] Commit frequently with descriptive messages
- [ ] Maintain functionality throughout process
- [ ] Update documentation as needed

### **Post-Refactoring**
- [ ] All tests still pass
- [ ] Performance hasn't degraded
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Metrics monitoring shows no regressions

### **Quality Gates**
- [ ] Cyclomatic complexity reduced
- [ ] Code duplication eliminated  
- [ ] Method/class sizes reasonable
- [ ] Single responsibility maintained
- [ ] Error handling preserved

---

## ⚠️ REFACTORING ANTI-PATTERNS

### **Don't Do These**
- ❌ **Refactor without tests**: Never refactor code without proper test coverage
- ❌ **Big bang refactor**: Don't rewrite large portions all at once
- ❌ **Mix refactoring with feature work**: Don't add features while refactoring
- ❌ **Ignore performance**: Don't assume refactored code performs the same
- ❌ **Change behavior**: Refactoring should preserve external behavior
- ❌ **Skip documentation**: Update docs when refactoring public interfaces

### **Warning Signs to Stop**
- Tests start failing frequently
- Performance degrades significantly  
- Team members can't understand changes
- Refactoring is taking longer than original estimate
- Business stakeholders are getting concerned

---

## 📊 REFACTORING METRICS

### **Track These Metrics**
- **Cyclomatic complexity** before/after
- **Code duplication percentage** reduction
- **Test coverage** maintenance
- **Performance metrics** (response time, memory usage)
- **Code review time** improvement
- **Bug frequency** in refactored areas

### **Success Indicators**
- Decreased time to add new features
- Fewer bugs in refactored code
- Improved developer productivity
- Better code review feedback
- Easier onboarding of new team members

---

## 🎯 REFACTORING STRATEGY

### **Opportunistic Refactoring**
Refactor code when you're already working in that area:
- Fixing bugs → Clean up surrounding code
- Adding features → Improve structure first
- Code review → Suggest structural improvements

### **Planned Refactoring Sprints**
Schedule dedicated time for structural improvements:
- Technical debt reduction
- Performance optimization  
- Architecture improvements
- Legacy code modernization

### **Continuous Refactoring**
Make refactoring part of daily development:
- Boy Scout Rule: Leave code cleaner than you found it
- Code review feedback incorporation
- Small improvements during maintenance

---

**Related Rules**: See `core-standards/coding-standards.md` for code quality standards and `general-policies/anti-patterns.md` for patterns to avoid during refactoring.