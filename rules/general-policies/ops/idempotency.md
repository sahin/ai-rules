# Idempotency & Rollback Standards

## 🔄 IDEMPOTENT OPERATIONS (MANDATORY)

### **Definition**
An idempotent operation produces the same result when executed multiple times, regardless of how many times it's performed.

### **Why Idempotency Matters**
- **Network reliability**: Handle retry scenarios gracefully  
- **Failure recovery**: Safe to re-execute failed operations
- **Consistency**: Prevent duplicate data creation
- **User experience**: Avoid double-charges, duplicate orders, etc.
- **System stability**: Reduce side effects from retries

---

## 💾 DATA MODIFICATION IDEMPOTENCY

### **Database Operations (MANDATORY)**

#### **CREATE Operations**
```typescript
// ❌ BAD - Non-idempotent creation
async function createUser(userData: UserData): Promise<User> {
  // This will fail on retry due to unique constraints
  return await db.users.create(userData);
}

// ✅ GOOD - Idempotent creation with unique request ID
async function createUser(userData: UserData, requestId: string): Promise<User> {
  // Check if already processed
  const existing = await db.operations.findOne({ requestId });
  if (existing) {
    return existing.result;
  }
  
  try {
    const user = await db.users.create(userData);
    // Store operation result
    await db.operations.create({
      requestId,
      operation: 'createUser',
      result: user,
      completedAt: new Date()
    });
    return user;
  } catch (error) {
    if (error.code === 'DUPLICATE_EMAIL') {
      // Return existing user if email collision
      return await db.users.findOne({ email: userData.email });
    }
    throw error;
  }
}
```

#### **UPDATE Operations**
```typescript
// ❌ BAD - Non-idempotent update
async function updateUserBalance(userId: string, amount: number): Promise<void> {
  // This adds amount every time, causing inconsistency on retry
  await db.users.updateOne(
    { id: userId },
    { $inc: { balance: amount } }
  );
}

// ✅ GOOD - Idempotent update with target value
async function updateUserBalance(
  userId: string, 
  targetBalance: number,
  transactionId: string
): Promise<void> {
  // Check if transaction already processed
  const existing = await db.transactions.findOne({ transactionId });
  if (existing) {
    return; // Already processed
  }
  
  // Set absolute value, not increment
  await db.users.updateOne(
    { id: userId },
    { balance: targetBalance }
  );
  
  // Record transaction
  await db.transactions.create({
    transactionId,
    userId,
    targetBalance,
    completedAt: new Date()
  });
}
```

#### **DELETE Operations**  
```typescript
// ✅ GOOD - DELETE is naturally idempotent
async function deleteUser(userId: string): Promise<boolean> {
  const result = await db.users.deleteOne({ id: userId });
  return result.deletedCount > 0; // Returns false if already deleted
}
```

### **File Operations (MANDATORY)**

#### **File Creation/Updates**
```typescript
// ✅ GOOD - Idempotent file operations
async function saveUserAvatar(userId: string, imageData: Buffer): Promise<string> {
  const filename = `avatars/${userId}.jpg`;
  
  // Check if file exists with same content (checksum)
  const expectedChecksum = crypto
    .createHash('sha256')
    .update(imageData)
    .digest('hex');
    
  try {
    const existingFile = await fs.readFile(filename);
    const existingChecksum = crypto
      .createHash('sha256')
      .update(existingFile)
      .digest('hex');
      
    if (existingChecksum === expectedChecksum) {
      return filename; // Already exists with same content
    }
  } catch (error) {
    // File doesn't exist, continue with creation
  }
  
  // Write file (overwrites if exists)
  await fs.writeFile(filename, imageData);
  return filename;
}
```

---

## 🎯 UNIQUE REQUEST IDs

### **Implementation Pattern (MANDATORY)**
Every critical operation must include a unique request identifier:

```typescript
// Client-side: Generate unique request ID
const requestId = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

// Or use UUID
import { v4 as uuidv4 } from 'uuid';
const requestId = uuidv4();

// Server-side: Store and check request IDs
interface IdempotencyRecord {
  requestId: string;
  operation: string;
  result?: unknown;
  status: 'pending' | 'completed' | 'failed';
  createdAt: Date;
  completedAt?: Date;
  expiresAt: Date;
}
```

### **Request ID Storage Strategy**
```typescript
class IdempotencyService {
  // Store operation state
  async storeOperation(
    requestId: string,
    operation: string,
    ttlMinutes: number = 60
  ): Promise<void> {
    const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000);
    
    await db.idempotencyRecords.create({
      requestId,
      operation,
      status: 'pending',
      createdAt: new Date(),
      expiresAt
    });
  }
  
  // Check if operation was already processed
  async getOperationResult(requestId: string): Promise<IdempotencyRecord | null> {
    return await db.idempotencyRecords.findOne({
      requestId,
      expiresAt: { $gt: new Date() } // Not expired
    });
  }
  
  // Mark operation as completed
  async completeOperation(
    requestId: string, 
    result: unknown
  ): Promise<void> {
    await db.idempotencyRecords.updateOne(
      { requestId },
      { 
        status: 'completed',
        result,
        completedAt: new Date()
      }
    );
  }
}
```

---

## 🔄 DATABASE MIGRATIONS (MANDATORY)

### **Reversible Migration Pattern**
Every migration must be reversible:

```sql
-- Migration: 001_add_user_preferences.sql
-- UP Migration
CREATE TABLE user_preferences (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  preference_key VARCHAR(100) NOT NULL,
  preference_value TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, preference_key)
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- DOWN Migration (Rollback)
-- This should be in a separate file: 001_add_user_preferences_down.sql
DROP INDEX IF EXISTS idx_user_preferences_user_id;
DROP TABLE IF EXISTS user_preferences;
```

### **Migration Testing Requirements**
```typescript
// Test both UP and DOWN migrations
describe('Migration 001: Add user preferences', () => {
  it('should apply migration successfully', async () => {
    await runMigration('001_add_user_preferences.sql');
    
    // Verify table exists
    const tables = await db.query("SELECT * FROM information_schema.tables WHERE table_name = 'user_preferences'");
    expect(tables.length).toBe(1);
  });
  
  it('should rollback migration successfully', async () => {
    // Apply migration first
    await runMigration('001_add_user_preferences.sql');
    
    // Then rollback
    await runMigration('001_add_user_preferences_down.sql');
    
    // Verify table is gone
    const tables = await db.query("SELECT * FROM information_schema.tables WHERE table_name = 'user_preferences'");
    expect(tables.length).toBe(0);
  });
  
  it('should be idempotent - safe to run multiple times', async () => {
    // Should not fail when run multiple times
    await runMigration('001_add_user_preferences.sql');
    await runMigration('001_add_user_preferences.sql');
    await runMigration('001_add_user_preferences.sql');
    
    // Table should still exist and be correct
    const tables = await db.query("SELECT * FROM information_schema.tables WHERE table_name = 'user_preferences'");
    expect(tables.length).toBe(1);
  });
});
```

---

## 🛡️ ROLLBACK STRATEGY (MANDATORY)

### **Rollback Plan Requirements**
Every change must document its rollback plan:

#### **Code Deployment Rollbacks**
```yaml
# deployment-plan.yml
deployment:
  version: "v2.1.0"
  rollback_version: "v2.0.3"
  rollback_triggers:
    - error_rate > 5%
    - response_time > 2s
    - user_complaints > 10
  
rollback_plan:
  steps:
    1. "Stop new deployments"
    2. "Redirect traffic to previous version"
    3. "Verify system stability"
    4. "Communicate to stakeholders"
  
  data_changes:
    - "Migration 015 can be safely reverted"
    - "No data loss expected"
    - "User sessions will be preserved"
  
  estimated_time: "15 minutes"
  verification_steps:
    - "Health check endpoints respond"
    - "User login flow works"
    - "Payment processing functional"
```

#### **Database Change Rollbacks**
```typescript
interface RollbackPlan {
  changeDescription: string;
  rollbackSteps: string[];
  dataLossRisk: 'none' | 'minimal' | 'significant';
  estimatedTime: string;
  verificationQueries: string[];
  dependencies: string[];
}

const rollbackPlan: RollbackPlan = {
  changeDescription: "Add user_preferences table",
  rollbackSteps: [
    "1. Export user preferences data if needed",
    "2. Run down migration: DROP TABLE user_preferences", 
    "3. Verify table removal",
    "4. Update application to handle missing preferences"
  ],
  dataLossRisk: 'minimal', // Only preferences data
  estimatedTime: "5 minutes",
  verificationQueries: [
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'user_preferences'",
    "SELECT COUNT(*) FROM users WHERE id = 1" // Verify users table unaffected
  ],
  dependencies: ["User settings feature must be disabled first"]
};
```

---

## 🔧 STATE MANAGEMENT (MANDATORY)

### **Avoid Partial State Updates**
```typescript
// ❌ BAD - Partial state that can leave system inconsistent
async function processOrder(orderData: OrderData): Promise<void> {
  // If this fails after updating inventory but before creating order...
  await updateInventory(orderData.items);        // Step 1
  await createOrder(orderData);                  // Step 2 - might fail
  await chargePayment(orderData.paymentInfo);   // Step 3 - might fail
  await sendConfirmationEmail(orderData.email); // Step 4 - might fail
}

// ✅ GOOD - Transactional approach
async function processOrder(
  orderData: OrderData,
  requestId: string
): Promise<Order> {
  // Check if already processed
  const existing = await idempotencyService.getOperationResult(requestId);
  if (existing && existing.status === 'completed') {
    return existing.result as Order;
  }
  
  // Use database transaction for atomicity
  const transaction = await db.beginTransaction();
  
  try {
    // All operations within transaction
    const inventoryUpdate = await updateInventory(orderData.items, { transaction });
    const order = await createOrder(orderData, { transaction });
    const payment = await chargePayment(orderData.paymentInfo, { transaction });
    
    // Commit all changes atomically
    await transaction.commit();
    
    // Non-critical operations can happen after transaction
    await sendConfirmationEmail(orderData.email);
    
    // Store result for idempotency
    await idempotencyService.completeOperation(requestId, order);
    
    return order;
  } catch (error) {
    // Rollback all changes
    await transaction.rollback();
    
    // Store failure for idempotency
    await idempotencyService.failOperation(requestId, error);
    
    throw error;
  }
}
```

### **Distributed System Compensation Patterns**
For operations across multiple services:

```typescript
// Saga Pattern for distributed transactions
class OrderSagaOrchestrator {
  async processOrder(orderData: OrderData, requestId: string): Promise<Order> {
    const sagaId = requestId;
    const steps: SagaStep[] = [];
    
    try {
      // Step 1: Reserve inventory
      const inventoryReservation = await inventoryService.reserve(
        orderData.items, 
        sagaId
      );
      steps.push({
        service: 'inventory',
        action: 'reserve', 
        compensationAction: 'release',
        data: inventoryReservation
      });
      
      // Step 2: Create order
      const order = await orderService.create(orderData, sagaId);
      steps.push({
        service: 'orders',
        action: 'create',
        compensationAction: 'cancel', 
        data: order
      });
      
      // Step 3: Process payment
      const payment = await paymentService.charge(
        orderData.paymentInfo, 
        sagaId
      );
      steps.push({
        service: 'payments',
        action: 'charge',
        compensationAction: 'refund',
        data: payment
      });
      
      // All steps successful
      await this.completeSaga(sagaId);
      return order;
      
    } catch (error) {
      // Compensate in reverse order
      await this.compensateSaga(sagaId, steps.reverse());
      throw error;
    }
  }
  
  private async compensateSaga(sagaId: string, steps: SagaStep[]): Promise<void> {
    for (const step of steps) {
      try {
        await this.executeCompensation(step);
      } catch (compensationError) {
        // Log compensation failures but continue
        logger.error('Compensation failed', { sagaId, step, error: compensationError });
      }
    }
  }
}
```

---

## 🧪 TESTING IDEMPOTENCY (MANDATORY)

### **Idempotency Test Pattern**
Every critical operation must have idempotency tests:

```typescript
describe('User Creation Idempotency', () => {
  it('should handle duplicate requests gracefully', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User'
    };
    const requestId = 'test-request-123';
    
    // First request
    const user1 = await createUser(userData, requestId);
    expect(user1.email).toBe('test@example.com');
    
    // Duplicate request with same ID
    const user2 = await createUser(userData, requestId);
    
    // Should return same result
    expect(user2.id).toBe(user1.id);
    expect(user2.email).toBe(user1.email);
    
    // Verify only one user created
    const users = await db.users.find({ email: 'test@example.com' });
    expect(users.length).toBe(1);
  });
  
  it('should handle network retry scenarios', async () => {
    const userData = { email: 'retry@example.com', name: 'Retry User' };
    const requestId = 'retry-request-456';
    
    // Simulate network failure after partial completion
    let callCount = 0;
    const originalCreate = db.users.create;
    db.users.create = jest.fn().mockImplementation(async (data) => {
      callCount++;
      if (callCount === 1) {
        // Simulate failure after storing idempotency record
        await idempotencyService.storeOperation(requestId, 'createUser');
        throw new Error('Network timeout');
      }
      return originalCreate.call(db.users, data);
    });
    
    // First attempt fails
    await expect(createUser(userData, requestId)).rejects.toThrow('Network timeout');
    
    // Retry should complete successfully
    const user = await createUser(userData, requestId);
    expect(user.email).toBe('retry@example.com');
    
    // Should only have one user
    const users = await db.users.find({ email: 'retry@example.com' });
    expect(users.length).toBe(1);
  });
});
```

---

## 📋 ROLLBACK TESTING (MANDATORY)

### **Rollback Verification Requirements**
```typescript
describe('Deployment Rollback Tests', () => {
  it('should rollback database migration successfully', async () => {
    // Apply migration
    await runMigration('015_add_user_settings.sql');
    
    // Add some test data
    await db.userSettings.create({ userId: 1, theme: 'dark' });
    
    // Rollback migration
    await runMigration('015_add_user_settings_down.sql');
    
    // Verify rollback
    const tables = await db.query(
      "SELECT * FROM information_schema.tables WHERE table_name = 'user_settings'"
    );
    expect(tables.length).toBe(0);
  });
  
  it('should preserve critical data during rollback', async () => {
    const userCount = await db.users.count();
    
    // Apply migration
    await runMigration('016_add_user_metadata.sql');
    
    // Rollback migration
    await runMigration('016_add_user_metadata_down.sql');
    
    // Verify users table unaffected
    const newUserCount = await db.users.count();
    expect(newUserCount).toBe(userCount);
  });
});
```

---

## 📝 DOCUMENTATION REQUIREMENTS

### **Idempotency Documentation Template**
```markdown
# Operation: CreateUserAccount

## Idempotency Design
- **Request ID**: Required in all requests (`requestId` parameter)
- **Storage**: Redis with 1-hour TTL for request tracking
- **Behavior**: Returns existing user if email already exists

## Rollback Plan
- **Trigger**: User creation failure after email verification sent
- **Steps**: 
  1. Delete user record from database
  2. Invalidate email verification token
  3. Remove user from search index
- **Data Loss**: None (user can re-register)
- **Estimated Time**: 30 seconds

## Testing
- Unit tests verify duplicate request handling
- Integration tests confirm rollback procedures
- Load tests validate request ID storage performance
```

## 🚨 ENFORCEMENT RULES

### **Code Review Checklist**
- [ ] All data modifications use request IDs or natural idempotency
- [ ] Database operations are atomic (use transactions)
- [ ] File operations check existence before creation
- [ ] API endpoints handle duplicate requests gracefully  
- [ ] Migration includes both UP and DOWN scripts
- [ ] Rollback plan documented and tested
- [ ] Idempotency tests written and passing
- [ ] Distributed operations use compensation patterns

### **Pre-Deployment Verification**
- [ ] Rollback procedures tested in staging
- [ ] Migration rollback verified
- [ ] Request ID storage configured
- [ ] Monitoring alerts for duplicate operations
- [ ] Documentation complete and reviewed

---

**Related Rules**: See `general-policies/ops/observability.md` for monitoring rollback operations and `core-standards/coding-standards.md` for transaction patterns.