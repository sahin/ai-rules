# Database Migration Safety Rules

## Purpose
Comprehensive database migration safety patterns to prevent data loss, ensure rollback capabilities, and maintain multi-tenant isolation during schema changes.

## 🚨 CRITICAL: Migration Safety Requirements

### Mandatory Migration Checklist
- ✅ **Rollback Function**: Every migration MUST have a working `downgrade()` function
- ✅ **Farm Isolation**: New tables MUST include `farm_id` for multi-tenant isolation
- ✅ **Index Safety**: Foreign keys MUST have corresponding indexes
- ✅ **Test Validation**: All migrations MUST be tested on copy of production data
- ✅ **Backup Required**: Production backup MUST exist before migration
- ✅ **Zero Downtime**: Migrations MUST support zero-downtime deployment

## Migration Patterns

### Safe Migration Template
```python
"""Add sensor_calibration table

Revision ID: abc123
Revises: def456
Create Date: 2024-01-15 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers
revision = 'abc123'
down_revision = 'def456'
branch_labels = None
depends_on = None

def upgrade():
    """
    Add sensor calibration tracking table
    """
    # Create table with farm_id for multi-tenant isolation
    op.create_table(
        'sensor_calibrations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('farm_id', sa.Integer(), nullable=False),  # REQUIRED for isolation
        sa.Column('sensor_id', sa.Integer(), nullable=False),
        sa.Column('calibration_date', sa.DateTime(timezone=True), nullable=False),
        sa.Column('calibration_value', sa.Float(), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.text('now()')),
        
        # Primary key
        sa.PrimaryKeyConstraint('id'),
        
        # Foreign keys with proper indexing
        sa.ForeignKeyConstraint(['farm_id'], ['farms.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['sensor_id'], ['sensors.id'], ondelete='CASCADE'),
        
        # Indexes for performance
        sa.Index('ix_sensor_calibrations_farm_id', 'farm_id'),
        sa.Index('ix_sensor_calibrations_sensor_id', 'sensor_id'),
        sa.Index('ix_sensor_calibrations_calibration_date', 'calibration_date'),
        
        # Unique constraints
        sa.UniqueConstraint('farm_id', 'sensor_id', 'calibration_date', 
                           name='uq_sensor_calibration_per_date')
    )

def downgrade():
    """
    Remove sensor calibration tracking table
    CRITICAL: This function MUST work correctly
    """
    # Drop table (indexes and constraints automatically dropped)
    op.drop_table('sensor_calibrations')
```

### Multi-Tenant Migration Patterns
```python
# Adding column to existing table
def upgrade():
    """Add pH calibration offset column"""
    # Add column with default value for existing rows
    op.add_column('sensors', 
        sa.Column('ph_calibration_offset', sa.Float(), nullable=True, default=0.0)
    )
    
    # Update existing sensors per farm to avoid cross-contamination
    connection = op.get_bind()
    
    # Process each farm separately to maintain isolation
    farms = connection.execute(sa.text("SELECT id FROM farms")).fetchall()
    
    for farm in farms:
        connection.execute(
            sa.text("""
                UPDATE sensors 
                SET ph_calibration_offset = 0.0 
                WHERE farm_id = :farm_id AND sensor_type = 'ph'
            """),
            {"farm_id": farm.id}
        )
    
    # Make column non-nullable after setting defaults
    op.alter_column('sensors', 'ph_calibration_offset', nullable=False)

def downgrade():
    """Remove pH calibration offset column"""
    op.drop_column('sensors', 'ph_calibration_offset')
```

### Zero-Downtime Migration Patterns
```python
# Safe column renaming (multi-step process)

# Step 1: Add new column
def upgrade_step_1():
    """Add new column alongside old one"""
    op.add_column('sensors', 
        sa.Column('location_description', sa.String(255), nullable=True)
    )

# Step 2: Migrate data and update application
def upgrade_step_2():
    """Copy data from old column to new column"""
    connection = op.get_bind()
    connection.execute(
        sa.text("UPDATE sensors SET location_description = location_name")
    )

# Step 3: Remove old column (after application updated)
def upgrade_step_3():
    """Remove old column after application migration"""
    op.drop_column('sensors', 'location_name')

# Complete rollback process
def downgrade():
    """Rollback all steps"""
    # Add back old column
    op.add_column('sensors', 
        sa.Column('location_name', sa.String(255), nullable=True)
    )
    
    # Copy data back
    connection = op.get_bind()
    connection.execute(
        sa.text("UPDATE sensors SET location_name = location_description")
    )
    
    # Remove new column
    op.drop_column('sensors', 'location_description')
```

## Migration Safety Checks

### Pre-Migration Validation
```python
# Migration validation script
import sqlalchemy as sa
from alembic import op

def validate_migration_safety():
    """Validate migration follows safety patterns"""
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    
    checks = {
        'has_rollback': check_rollback_function_exists(),
        'farm_isolation': check_farm_isolation_maintained(),
        'indexes_present': check_foreign_key_indexes(),
        'backup_exists': check_backup_exists(),
        'test_passed': check_test_migration_passed()
    }
    
    failed_checks = [check for check, passed in checks.items() if not passed]
    
    if failed_checks:
        raise Exception(f"Migration safety checks failed: {failed_checks}")
    
    return True

def check_farm_isolation_maintained():
    """Ensure new tables include farm_id"""
    # Implementation to check farm_id presence
    return True

def check_foreign_key_indexes():
    """Ensure all foreign keys have indexes"""
    # Implementation to validate indexes
    return True
```

### Migration Testing Patterns
```python
# Test migration on copy of production data
import pytest
from alembic.command import upgrade, downgrade
from alembic.config import Config

@pytest.fixture
def migration_config():
    """Setup migration configuration for testing"""
    config = Config("alembic.ini")
    config.set_main_option("sqlalchemy.url", "postgresql://test:test@localhost/test_db")
    return config

def test_migration_up_and_down(migration_config):
    """Test migration and rollback"""
    # Test upgrade
    upgrade(migration_config, "head")
    
    # Verify schema changes
    assert table_exists("sensor_calibrations")
    assert column_exists("sensor_calibrations", "farm_id")
    
    # Test downgrade
    downgrade(migration_config, "-1")
    
    # Verify rollback
    assert not table_exists("sensor_calibrations")

def test_farm_isolation_maintained(migration_config):
    """Test multi-tenant isolation is maintained"""
    # Create test data for multiple farms
    farm1_id = create_test_farm("Farm Alpha")
    farm2_id = create_test_farm("Farm Beta")
    
    # Run migration
    upgrade(migration_config, "head")
    
    # Test farm isolation
    sensor1 = create_test_sensor(farm1_id)
    sensor2 = create_test_sensor(farm2_id)
    
    # Verify data isolation
    farm1_sensors = get_farm_sensors(farm1_id)
    farm2_sensors = get_farm_sensors(farm2_id)
    
    assert sensor1 in farm1_sensors
    assert sensor1 not in farm2_sensors
    assert sensor2 in farm2_sensors
    assert sensor2 not in farm1_sensors
```

## Production Migration Workflow

### Safe Production Migration Process
```bash
#!/bin/bash
# production-migration.sh - Safe production migration workflow

set -e  # Exit on any error

echo "🚀 Starting Production Migration"

# 1. Pre-migration validation
echo "1️⃣ Validating migration safety..."
python scripts/validate_migration.py

# 2. Create backup
echo "2️⃣ Creating database backup..."
pg_dump $DATABASE_URL > "backup_$(date +%Y%m%d_%H%M%S).sql"

# 3. Test migration on copy
echo "3️⃣ Testing migration on database copy..."
createdb ${DATABASE_NAME}_test
pg_restore -d ${DATABASE_NAME}_test backup_*.sql
alembic -x database_url=${TEST_DATABASE_URL} upgrade head

# 4. Run migration on production (if test passed)
echo "4️⃣ Running production migration..."
alembic upgrade head

# 5. Verify migration success
echo "5️⃣ Verifying migration..."
python scripts/verify_migration.py

# 6. Clean up test database
echo "6️⃣ Cleaning up..."
dropdb ${DATABASE_NAME}_test

echo "✅ Migration completed successfully"
```

### Migration Monitoring
```python
# Monitor migration progress and health
from sqlalchemy import text
import time
import logging

class MigrationMonitor:
    def __init__(self, db_connection):
        self.db = db_connection
        self.logger = logging.getLogger(__name__)
    
    def monitor_migration_progress(self, migration_id: str):
        """Monitor long-running migration progress"""
        start_time = time.time()
        
        while True:
            # Check if migration is still running
            result = self.db.execute(
                text("SELECT * FROM alembic_version WHERE version_num = :version"),
                {"version": migration_id}
            ).fetchone()
            
            # Check database health
            health = self.check_database_health()
            
            elapsed = time.time() - start_time
            
            self.logger.info(f"Migration progress: {elapsed:.1f}s elapsed, DB health: {health}")
            
            if result:
                break
                
            if elapsed > 3600:  # 1 hour timeout
                raise Exception("Migration taking too long")
            
            time.sleep(30)
    
    def check_database_health(self):
        """Check database connection and performance"""
        try:
            # Check connection
            self.db.execute(text("SELECT 1"))
            
            # Check for blocking queries
            blocking_queries = self.db.execute(
                text("""
                    SELECT count(*) 
                    FROM pg_stat_activity 
                    WHERE state = 'active' AND wait_event_type = 'Lock'
                """)
            ).scalar()
            
            return {
                "connection": "healthy",
                "blocking_queries": blocking_queries,
                "status": "warning" if blocking_queries > 10 else "healthy"
            }
            
        except Exception as e:
            return {"connection": "failed", "error": str(e), "status": "critical"}
```

## Emergency Rollback Procedures

### Emergency Rollback Script
```bash
#!/bin/bash
# emergency-rollback.sh - Emergency migration rollback

set -e

echo "🚨 EMERGENCY ROLLBACK INITIATED"

# 1. Immediate rollback
echo "1️⃣ Rolling back migration..."
alembic downgrade -1

# 2. Verify rollback success
echo "2️⃣ Verifying rollback..."
python scripts/verify_rollback.py

# 3. Check application health
echo "3️⃣ Checking application health..."
curl -f http://localhost:8000/health || echo "⚠️ Application health check failed"

# 4. Restore from backup if needed
if [ "$1" = "--restore-backup" ]; then
    echo "4️⃣ Restoring from backup..."
    LATEST_BACKUP=$(ls -t backup_*.sql | head -1)
    pg_restore -d $DATABASE_NAME $LATEST_BACKUP
fi

echo "✅ Emergency rollback completed"
```

### Rollback Validation
```python
def validate_rollback_success():
    """Validate that rollback was successful"""
    checks = [
        check_schema_reverted(),
        check_data_integrity(),
        check_farm_isolation(),
        check_application_functionality()
    ]
    
    failed_checks = [check.__name__ for check in checks if not check()]
    
    if failed_checks:
        raise Exception(f"Rollback validation failed: {failed_checks}")
    
    return True

def check_schema_reverted():
    """Verify schema is back to expected state"""
    # Implementation to check schema
    return True

def check_data_integrity():
    """Verify no data corruption occurred"""
    # Implementation to validate data
    return True
```

## Best Practices Summary

### DO's
- ✅ Always include rollback functions
- ✅ Test migrations on production data copy
- ✅ Include farm_id in all new tables
- ✅ Add indexes for all foreign keys
- ✅ Use zero-downtime migration patterns
- ✅ Monitor migration progress
- ✅ Create backups before migration
- ✅ Validate migration safety pre-execution

### DON'Ts
- ❌ Never run migrations without rollback
- ❌ Don't skip testing on production data copy
- ❌ Don't create tables without farm_id
- ❌ Don't add foreign keys without indexes
- ❌ Don't run destructive operations without backup
- ❌ Don't ignore migration warnings
- ❌ Don't migrate during peak hours
- ❌ Don't skip post-migration validation

This comprehensive migration safety system ensures zero data loss and maintains multi-tenant isolation throughout all database schema changes.