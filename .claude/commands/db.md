# Database Guide

Use this guide when working with database schema design, migrations, queries, and optimization.

## Migration Templates

### Create Table Migration
```sql
-- migrations/YYYYMMDDHHMMSS_create_<table>.sql

-- UP
CREATE TABLE table_name (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  is_active BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_table_name_status ON table_name(status);

-- DOWN
DROP TABLE IF EXISTS table_name;
```

### Add Column Migration
```sql
-- UP
ALTER TABLE table_name
  ADD COLUMN new_column VARCHAR(100) NOT NULL DEFAULT 'default_value';

CREATE INDEX idx_table_name_new_column ON table_name(new_column);

-- DOWN
DROP INDEX IF EXISTS idx_table_name_new_column;
ALTER TABLE table_name DROP COLUMN IF EXISTS new_column;
```

### Add Foreign Key
```sql
-- UP
ALTER TABLE child_table
  ADD COLUMN parent_id INTEGER NOT NULL REFERENCES parent_table(id) ON DELETE CASCADE;

CREATE INDEX idx_child_table_parent_id ON child_table(parent_id);

-- DOWN
DROP INDEX IF EXISTS idx_child_table_parent_id;
ALTER TABLE child_table DROP COLUMN IF EXISTS parent_id;
```

## Zero-Downtime Migration Patterns

### Adding a NOT NULL Column
1. Add column as nullable with default
2. Backfill existing rows
3. Add NOT NULL constraint

```sql
-- Step 1: Add nullable
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT false;

-- Step 2: Backfill
UPDATE users SET email_verified = false WHERE email_verified IS NULL;

-- Step 3: Add constraint
ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
```

### Renaming a Column
1. Add new column
2. Dual-write to both columns (app change)
3. Backfill old data
4. Switch reads to new column (app change)
5. Stop writing old column (app change)
6. Drop old column

### Dropping a Column
1. Stop reading the column (app change)
2. Stop writing the column (app change)
3. Drop the column in migration

## Index Strategy

### When to Create Indexes
- Every foreign key column
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Columns with high selectivity used in filters

### Index Types
```sql
-- B-tree (default): equality and range queries
CREATE INDEX idx_users_email ON users(email);

-- Composite: multi-column queries (leftmost prefix rule)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial: filtered subset of rows
CREATE INDEX idx_orders_pending ON orders(created_at)
  WHERE status = 'pending';

-- GIN: JSONB and array columns
CREATE INDEX idx_products_tags ON products USING GIN(tags);

-- Unique: enforce uniqueness
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
```

### Index Anti-Patterns
- Indexing low-cardinality columns (boolean, status with 2-3 values)
- Too many indexes on write-heavy tables
- Unused indexes (check `pg_stat_user_indexes`)
- Missing composite index when queries filter on multiple columns

## Query Optimization

### Use EXPLAIN ANALYZE
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id;
```

### What to Look For
- **Seq Scan** on large tables: add an index
- **Nested Loop** with large outer set: consider Hash Join
- **Sort** without index: add index matching ORDER BY
- **High actual rows vs estimated**: run ANALYZE to update statistics

### Common Optimizations
```sql
-- BAD: N+1 query pattern
SELECT * FROM users WHERE id = 1;
SELECT * FROM orders WHERE user_id = 1;
SELECT * FROM orders WHERE user_id = 2;

-- GOOD: JOIN or batch
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.id IN (1, 2);

-- BAD: SELECT *
SELECT * FROM users;

-- GOOD: Select only needed columns
SELECT id, name, email FROM users;

-- BAD: OFFSET for deep pagination
SELECT * FROM posts ORDER BY id LIMIT 20 OFFSET 10000;

-- GOOD: Cursor-based pagination
SELECT * FROM posts WHERE id > :last_id ORDER BY id LIMIT 20;
```

### Performance Targets
- Simple queries (single table, indexed): < 10ms
- Standard queries (joins, filters): < 100ms
- Complex queries (aggregations, subqueries): < 500ms
- Reports/analytics: < 2s (consider materialized views)

## Connection Pooling

```typescript
// Use a connection pool, never direct connections
const pool = new Pool({
  max: 20,              // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// Always release connections
const client = await pool.connect();
try {
  const result = await client.query('SELECT ...');
  return result.rows;
} finally {
  client.release();
}
```

## Rollback Procedures

### Before Any Migration
1. Verify DOWN migration works on staging
2. Create database backup: `pg_dump -Fc dbname > backup.dump`
3. Test rollback: run DOWN, verify schema, run UP again

### Emergency Rollback
```bash
# Restore from backup
pg_restore -d dbname --clean backup.dump

# Or run DOWN migration
npm run migrate:down
```

### Rollback Checklist
- [ ] DOWN migration tested on staging
- [ ] Backup created before production run
- [ ] App code compatible with both old and new schema
- [ ] Rollback time estimated and communicated
- [ ] Monitoring in place for errors after migration

## Data Type Reference

| Use Case | Type | Notes |
|----------|------|-------|
| Primary key | `SERIAL` or `UUID` | UUID for distributed systems |
| Short text | `VARCHAR(n)` | Always set appropriate limit |
| Long text | `TEXT` | Only when no reasonable limit |
| Money | `DECIMAL(19,4)` | Never use FLOAT for money |
| Timestamps | `TIMESTAMP WITH TIME ZONE` | Always include timezone |
| Boolean | `BOOLEAN` | Never CHAR(1) or INT |
| JSON data | `JSONB` | Never JSON (no indexing) |
| Enum-like | `VARCHAR` + CHECK | More flexible than ENUM type |
| IP address | `INET` | Native PostgreSQL type |
| Arrays | `type[]` | Only for simple, small arrays |
