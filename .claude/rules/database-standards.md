# Database Standards

## Naming
- Tables and columns: `snake_case`
- Tables: plural nouns (`users`, `order_items`)
- Boolean columns: prefix with `is_` or `has_`

## Required Table Structure
- Every table: primary key (SERIAL or UUID)
- Every table: `created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()`
- Every table: `updated_at TIMESTAMP WITH TIME ZONE`
- Soft deletes: `deleted_at TIMESTAMP WITH TIME ZONE NULL` when needed
- All columns: explicit NOT NULL unless intentionally nullable

## Constraints
- Foreign key constraints mandatory with ON DELETE behavior specified
- Index every foreign key column
- Index columns used in WHERE, JOIN, ORDER BY
- Use CHECK constraints for data validation at DB level
- Use UNIQUE constraints to prevent duplicates

## Data Types
- IDs: SERIAL or UUID
- Text: VARCHAR(n) with appropriate limits, not unbounded TEXT
- Numbers: INTEGER or DECIMAL(p,s) with specific precision
- Dates: TIMESTAMP WITH TIME ZONE (always include timezone)
- Booleans: BOOLEAN (never CHAR(1) or integers)
- JSON: JSONB (not JSON) for better indexing and performance

## Migrations
- All schema changes via versioned migration files
- Every migration must have a working rollback/down script
- Test migrations on copy of production data before applying
- Create backup before running production migrations
- Non-destructive: avoid data loss during schema changes

## Performance
- Index columns used in query patterns
- No N+1 queries - use JOINs or batch loading
- Use EXPLAIN ANALYZE for query optimization
- Implement connection pooling
- Simple queries: < 100ms, complex queries: < 500ms
