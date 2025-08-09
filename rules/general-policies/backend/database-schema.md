# Universal Database & Schema Rules

This document outlines universal standards for database design, schema management, data modeling, and database operations that must be followed across all projects.

## 🗄️ CRITICAL DATABASE REQUIREMENTS

### 1. **Schema Design Standards (MANDATORY)**

#### **Table Design Principles:**
- **Normalized structure**: Minimize data redundancy (3NF minimum)
- **Consistent naming**: snake_case for tables and columns
- **Primary keys**: Every table must have a primary key
- **Foreign key constraints**: Enforce referential integrity
- **Indexing strategy**: Index foreign keys and query columns

#### **Required Table Standards:**
```sql
-- MANDATORY table structure example
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL  -- Soft delete support
);

-- MANDATORY: Add indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

#### **Column Standards:**
- **NOT NULL constraints**: Explicitly define nullable vs non-nullable
- **Data types**: Use appropriate types (VARCHAR with limits, specific numeric types)
- **Default values**: Provide sensible defaults where applicable
- **Timestamp fields**: Include created_at, updated_at for audit trails
- **Soft deletes**: Use deleted_at for logical deletion when needed

### 2. **Migration Management (CRITICAL)**

#### **Migration Standards:**
- **Version control**: All schema changes in versioned migration files
- **Reversible migrations**: Every migration must have a rollback script
- **Non-destructive changes**: Avoid data loss during schema changes
- **Testing required**: Test migrations on copy of production data
- **Incremental deployment**: Deploy schema changes gradually

#### **Migration Best Practices:**
```sql
-- Good migration example
-- UP migration
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
UPDATE users SET phone = '' WHERE phone IS NULL;
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- DOWN migration (rollback)
ALTER TABLE users DROP COLUMN phone;
```

#### **Migration Checklist:**
- [ ] Migration tested on development database
- [ ] Migration tested on staging with production data copy
- [ ] Rollback script tested and verified
- [ ] Performance impact assessed
- [ ] Data backup completed before migration
- [ ] Migration dependencies documented

### 3. **Data Integrity & Constraints (MANDATORY)**

#### **Required Constraints:**
- **Primary key constraints**: Unique row identification
- **Foreign key constraints**: Referential integrity between tables
- **Check constraints**: Data validation at database level
- **Unique constraints**: Prevent duplicate data where needed
- **Not null constraints**: Enforce required fields

#### **Constraint Examples:**
```sql
-- MANDATORY constraints
ALTER TABLE orders 
ADD CONSTRAINT fk_orders_user_id 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE products 
ADD CONSTRAINT chk_price_positive 
CHECK (price > 0);

ALTER TABLE users 
ADD CONSTRAINT chk_email_format 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

### 4. **Performance Optimization (CRITICAL)**

#### **Index Strategy:**
- **Query-based indexing**: Index columns used in WHERE, JOIN, ORDER BY
- **Composite indexes**: Multi-column indexes for complex queries
- **Partial indexes**: Conditional indexes for filtered queries
- **Index maintenance**: Regular analysis and optimization
- **Avoid over-indexing**: Balance query performance with write performance

#### **Query Optimization:**
```sql
-- Good: Use indexes effectively
SELECT * FROM orders 
WHERE user_id = $1 AND status = 'active' 
ORDER BY created_at DESC;

-- Requires: Composite index on (user_id, status, created_at)
CREATE INDEX idx_orders_user_status_created 
ON orders(user_id, status, created_at DESC);
```

#### **Performance Requirements:**
- **Query response time**: < 100ms for simple queries
- **Complex query time**: < 500ms for reports and analytics
- **Index usage**: 95% of queries should use indexes
- **Connection pooling**: Implement proper connection management
- **Query monitoring**: Track slow queries and optimize

### 5. **Security & Access Control (MANDATORY)**

#### **Database Security:**
- **Least privilege access**: Users get minimum required permissions
- **Role-based security**: Define clear database roles
- **Connection encryption**: SSL/TLS for all database connections
- **SQL injection prevention**: Use parameterized queries only
- **Audit logging**: Log all data modification operations

#### **Access Control Patterns:**
```sql
-- MANDATORY: Role-based access control
CREATE ROLE app_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;

CREATE ROLE app_write;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_write;

-- MANDATORY: Row-level security for multi-tenant apps
CREATE POLICY tenant_isolation ON sensitive_table
FOR ALL TO app_users
USING (tenant_id = current_setting('app.current_tenant')::INTEGER);
```

## 📊 DATA MODELING STANDARDS

### **Entity Relationship Design:**
- **Clear relationships**: Define one-to-one, one-to-many, many-to-many explicitly
- **Avoiding circular references**: Design hierarchies carefully
- **Normalization**: Eliminate redundancy while maintaining performance
- **Denormalization**: Strategic denormalization for read performance
- **Reference data**: Separate tables for lookup/reference data

### **Data Types Best Practices:**
```sql
-- MANDATORY data type usage
id: SERIAL or UUID           -- Primary keys
text: VARCHAR(n) not TEXT    -- With appropriate length limits
numbers: INTEGER, DECIMAL(p,s) -- Specific precision
dates: TIMESTAMP WITH TIME ZONE -- Always include timezone
booleans: BOOLEAN            -- Never use CHAR(1) or integers
json: JSONB not JSON         -- Better performance and indexing
```

## 🔄 BACKUP & RECOVERY

### **Backup Requirements:**
- **Automated backups**: Daily full backups, hourly incremental
- **Backup testing**: Monthly restore testing required
- **Retention policy**: Define backup retention periods
- **Offsite storage**: Backups stored in different geographic location
- **Encryption**: All backups encrypted at rest and in transit

### **Recovery Procedures:**
- **Point-in-time recovery**: Ability to restore to specific timestamp
- **Recovery testing**: Quarterly disaster recovery drills
- **Documentation**: Detailed recovery procedures documented
- **RTO/RPO targets**: Recovery Time Objective < 4 hours, Recovery Point Objective < 1 hour
- **Monitoring**: Backup success/failure alerting

## 📈 MONITORING & MAINTENANCE

### **Required Monitoring:**
- **Performance metrics**: Query response times, connection counts
- **Capacity monitoring**: Storage usage, growth trends
- **Error tracking**: Failed queries, connection errors
- **Security monitoring**: Failed authentication attempts, privilege escalations
- **Backup monitoring**: Backup success/failure status

### **Maintenance Tasks:**
```sql
-- MANDATORY maintenance procedures
-- Weekly: Update table statistics
ANALYZE;

-- Monthly: Rebuild indexes
REINDEX DATABASE database_name;

-- Quarterly: Check for unused indexes
SELECT schemaname, tablename, indexname, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_tup_read = 0 AND idx_tup_fetch = 0;
```

## 🚨 DATABASE VIOLATIONS - ZERO TOLERANCE

### **Critical Violations:**
- ❌ Direct production database access without approval
- ❌ Schema changes without migrations
- ❌ Missing foreign key constraints
- ❌ Unencrypted sensitive data storage
- ❌ SQL injection vulnerabilities
- ❌ Missing backup verification
- ❌ Hardcoded database credentials
- ❌ Tables without primary keys

### **Immediate Action Required:**
1. **Stop deployment** if schema violation detected
2. **Review all related queries** for security issues
3. **Create proper migration** for any schema changes
4. **Test migration** on staging environment
5. **Document changes** and get approval

## 📋 DATABASE CHECKLIST

### **Before Schema Changes:**
- [ ] Migration script created and tested
- [ ] Rollback script prepared and tested
- [ ] Performance impact assessed
- [ ] Backup completed
- [ ] Stakeholder approval obtained
- [ ] Dependencies documented
- [ ] Testing plan prepared

### **Production Database Health:**
- [ ] All tables have primary keys
- [ ] Foreign key constraints properly defined
- [ ] Indexes optimized for query patterns
- [ ] Backup and recovery tested
- [ ] Security policies implemented
- [ ] Performance monitoring active
- [ ] Maintenance procedures scheduled

## 🎯 DATABASE PERFORMANCE TARGETS

### **Performance Metrics:**
- **Simple queries**: < 100ms response time
- **Complex queries**: < 500ms response time
- **Database availability**: 99.9% uptime
- **Backup completion**: < 2 hours for full backup
- **Recovery time**: < 4 hours for complete restore

### **Capacity Planning:**
- **Storage growth**: Monitor and project 6 months ahead
- **Connection limits**: Stay under 80% of maximum connections
- **Memory usage**: Optimize buffer pools and cache
- **CPU utilization**: Keep under 70% during normal operations
- **Disk I/O**: Monitor and optimize for performance bottlenecks