# Cross-Farm Data Isolation Testing Patterns

## Purpose
Comprehensive testing patterns to ensure absolute data isolation between farms in ClarosFarm's multi-tenant hydroponic management system. Critical for preventing data leaks, maintaining compliance, and ensuring customer trust.

## 🚨 CRITICAL: Multi-Tenant Isolation Requirements

### Mandatory Isolation Checklist
- ✅ **Database Level**: Row-Level Security (RLS) enforcement
- ✅ **API Level**: Farm ID validation on all endpoints
- ✅ **Service Level**: Farm context in all business logic
- ✅ **Cache Level**: Farm-scoped cache keys
- ✅ **File Storage**: Farm-specific storage paths
- ✅ **Logs & Analytics**: Farm ID in all log entries
- ✅ **Real-time Data**: WebSocket farm isolation
- ✅ **Background Jobs**: Farm context in async processing

## Database Isolation Testing

### Row-Level Security Validation
```python
# Database isolation test suite
import pytest
from sqlalchemy import create_engine, text
from app.models import Farm, Sensor, SensorReading
from app.core.security import set_farm_context

class TestDatabaseIsolation:
    
    async def test_rls_prevents_cross_farm_access(self):
        """Test that RLS prevents accessing other farm's data"""
        
        # Create test farms
        farm_alpha = await create_test_farm("Farm Alpha")
        farm_beta = await create_test_farm("Farm Beta")
        
        # Create sensors for each farm
        sensor_alpha = await create_test_sensor(farm_alpha.id, "Alpha Sensor")
        sensor_beta = await create_test_sensor(farm_beta.id, "Beta Sensor")
        
        # Set farm context for Alpha
        await set_farm_context(farm_alpha.id)
        
        # Query sensors - should only return Alpha's sensors
        alpha_sensors = await db.execute(
            select(Sensor).where(Sensor.farm_id == farm_alpha.id)
        ).scalars().all()
        
        # Attempt to query Beta's sensors directly (should fail)
        with pytest.raises(PermissionError):
            beta_sensors = await db.execute(
                select(Sensor).where(Sensor.id == sensor_beta.id)
            ).scalars().all()
        
        # Verify only Alpha sensors returned
        assert len(alpha_sensors) == 1
        assert alpha_sensors[0].id == sensor_alpha.id
        
        # Test cross-farm query prevention
        all_sensors = await db.execute(select(Sensor)).scalars().all()
        farm_ids = {s.farm_id for s in all_sensors}
        assert farm_ids == {farm_alpha.id}  # Only current farm visible

    async def test_database_transaction_isolation(self):
        """Test that transactions maintain farm isolation"""
        
        farm_1 = await create_test_farm("Farm 1") 
        farm_2 = await create_test_farm("Farm 2")
        
        # Concurrent transaction test
        async def farm_1_transaction():
            await set_farm_context(farm_1.id)
            sensor = await create_test_sensor(farm_1.id, "F1 Sensor")
            return await get_farm_sensors(farm_1.id)
        
        async def farm_2_transaction(): 
            await set_farm_context(farm_2.id)
            sensor = await create_test_sensor(farm_2.id, "F2 Sensor")
            return await get_farm_sensors(farm_2.id)
        
        # Run transactions concurrently
        f1_sensors, f2_sensors = await asyncio.gather(
            farm_1_transaction(),
            farm_2_transaction()
        )
        
        # Verify isolation
        assert len(f1_sensors) == 1
        assert len(f2_sensors) == 1
        assert f1_sensors[0].farm_id == farm_1.id
        assert f2_sensors[0].farm_id == farm_2.id
```

### SQL Injection & Farm Context Bypass Tests
```python
class TestSecurityBypass:
    
    async def test_sql_injection_cannot_bypass_isolation(self):
        """Test that SQL injection cannot access other farms"""
        
        farm_1 = await create_test_farm("Target Farm")
        farm_2 = await create_test_farm("Attacker Farm")
        
        # Create sensitive data in farm_1
        await create_test_sensor(farm_1.id, "Secret Sensor")
        
        # Set context to farm_2
        await set_farm_context(farm_2.id)
        
        # Attempt SQL injection to access farm_1 data
        malicious_queries = [
            "1 OR 1=1",
            f"1 UNION SELECT * FROM sensors WHERE farm_id = {farm_1.id}",
            f"1'; DROP TABLE sensors; SELECT * FROM sensors WHERE farm_id = {farm_1.id}; --",
            f"1 OR farm_id = {farm_1.id}"
        ]
        
        for malicious_input in malicious_queries:
            with pytest.raises((ValueError, PermissionError, SQLError)):
                # This should fail due to parameterized queries + RLS
                await sensor_service.search_sensors(malicious_input)
    
    async def test_farm_context_tampering_prevention(self):
        """Test that farm context cannot be tampered with"""
        
        farm_1 = await create_test_farm("Legitimate Farm")
        farm_2 = await create_test_farm("Target Farm") 
        
        # Set legitimate farm context
        await set_farm_context(farm_1.id)
        
        # Attempt to tamper with farm context
        with pytest.raises(SecurityError):
            # Direct context manipulation should fail
            db.session.execute(text(f"SET app.current_farm_id = '{farm_2.id}'"))
        
        # Verify context unchanged
        current_farm = await get_current_farm_context()
        assert current_farm.id == farm_1.id
```

## API Endpoint Isolation Testing

### Comprehensive API Isolation Suite
```python
class TestAPIIsolation:
    
    async def test_all_endpoints_enforce_farm_isolation(self):
        """Test that every API endpoint enforces farm isolation"""
        
        # Create test farms with data
        farm_alpha = await self.setup_test_farm("Alpha")
        farm_beta = await self.setup_test_farm("Beta")
        
        # Test all CRUD endpoints
        endpoints_to_test = [
            ("GET", "/api/sensors"),
            ("POST", "/api/sensors"),
            ("PUT", "/api/sensors/{id}"),
            ("DELETE", "/api/sensors/{id}"),
            ("GET", "/api/sensor-readings"),
            ("POST", "/api/sensor-readings"),
            ("GET", "/api/alerts"),
            ("GET", "/api/irrigation-schedules"),
            ("POST", "/api/irrigation-schedules")
        ]
        
        for method, endpoint in endpoints_to_test:
            await self.test_endpoint_isolation(
                method, endpoint, farm_alpha, farm_beta
            )
    
    async def test_endpoint_isolation(self, method, endpoint, farm_alpha, farm_beta):
        """Test specific endpoint for farm isolation"""
        
        # Authenticate as farm_alpha user
        alpha_headers = await get_auth_headers(farm_alpha.owner_id)
        
        # Make request - should only return alpha data
        if "{id}" in endpoint:
            endpoint = endpoint.replace("{id}", str(farm_alpha.sensor_ids[0]))
        
        response = await self.client.request(
            method, endpoint, headers=alpha_headers
        )
        
        if response.status_code == 200 and "sensors" in response.json():
            sensors = response.json()["sensors"]
            # All returned sensors should belong to farm_alpha
            for sensor in sensors:
                assert sensor["farm_id"] == farm_alpha.id
        
        # Attempt to access farm_beta data with alpha credentials
        if method == "GET" and "{id}" in endpoint:
            beta_endpoint = endpoint.replace(
                str(farm_alpha.sensor_ids[0]),
                str(farm_beta.sensor_ids[0])
            )
            
            response = await self.client.get(beta_endpoint, headers=alpha_headers)
            # Should return 403 or 404, never farm_beta data
            assert response.status_code in [403, 404]

    async def test_bulk_operations_maintain_isolation(self):
        """Test that bulk operations don't leak across farms"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create sensors in both farms
        f1_sensors = await create_bulk_test_sensors(farm_1.id, count=5)
        f2_sensors = await create_bulk_test_sensors(farm_2.id, count=3)
        
        # Authenticate as farm_1 user
        f1_headers = await get_auth_headers(farm_1.owner_id)
        
        # Bulk update request
        bulk_update_data = {
            "sensor_ids": [s.id for s in f1_sensors] + [s.id for s in f2_sensors],
            "updates": {"status": "maintenance"}
        }
        
        response = await self.client.put(
            "/api/sensors/bulk", 
            json=bulk_update_data,
            headers=f1_headers
        )
        
        # Should only update farm_1 sensors, ignore farm_2 sensor IDs
        assert response.status_code == 200
        updated_count = response.json()["updated_count"]
        assert updated_count == 5  # Only farm_1 sensors updated
        
        # Verify farm_2 sensors unchanged
        f2_sensors_after = await get_farm_sensors(farm_2.id)
        for sensor in f2_sensors_after:
            assert sensor.status != "maintenance"
```

### Authentication & Authorization Isolation
```python
class TestAuthIsolation:
    
    async def test_jwt_token_farm_scoping(self):
        """Test that JWT tokens are properly farm-scoped"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create users for each farm
        user_1 = await create_farm_user(farm_1.id, role="manager")
        user_2 = await create_farm_user(farm_2.id, role="manager")
        
        # Generate tokens
        token_1 = generate_jwt_token(user_1, farm_1.id)
        token_2 = generate_jwt_token(user_2, farm_2.id)
        
        # User 1 attempts to access farm 2 data
        headers_1 = {"Authorization": f"Bearer {token_1}"}
        response = await self.client.get(
            f"/api/farms/{farm_2.id}/sensors",
            headers=headers_1
        )
        
        assert response.status_code == 403
        assert "farm access denied" in response.json()["error"]["message"].lower()
    
    async def test_role_isolation_across_farms(self):
        """Test that roles don't cross farm boundaries"""
        
        farm_1 = await create_test_farm("Farm 1") 
        farm_2 = await create_test_farm("Farm 2")
        
        # Create admin user in farm_1
        admin_user = await create_farm_user(farm_1.id, role="admin")
        admin_token = generate_jwt_token(admin_user, farm_1.id)
        
        # Admin of farm_1 should NOT have admin access to farm_2
        headers = {"Authorization": f"Bearer {admin_token}"}
        
        # Attempt admin operations on farm_2
        response = await self.client.delete(
            f"/api/farms/{farm_2.id}/sensors/1",
            headers=headers
        )
        
        assert response.status_code == 403
        
        # Verify farm_2 data unchanged
        f2_sensors = await get_farm_sensors(farm_2.id)
        assert len(f2_sensors) > 0  # Sensors still exist
```

## Service Layer Isolation Testing

### Business Logic Isolation
```python
class TestServiceIsolation:
    
    async def test_sensor_service_farm_isolation(self):
        """Test that sensor service enforces farm isolation"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create sensors in both farms
        s1 = await create_test_sensor(farm_1.id, "F1 Sensor")
        s2 = await create_test_sensor(farm_2.id, "F2 Sensor")
        
        # Service call should be farm-scoped
        sensor_service = SensorService(farm_context=farm_1.id)
        
        # Get all sensors - should only return farm_1 sensors
        sensors = await sensor_service.get_all_sensors()
        assert len(sensors) == 1
        assert sensors[0].id == s1.id
        
        # Attempt to get farm_2 sensor by ID should fail
        with pytest.raises(PermissionError):
            await sensor_service.get_sensor(s2.id)
    
    async def test_alert_service_cross_farm_prevention(self):
        """Test alert service doesn't leak across farms"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create critical alert in farm_1
        alert_1 = await create_test_alert(farm_1.id, severity="critical")
        alert_2 = await create_test_alert(farm_2.id, severity="warning")
        
        # Alert service scoped to farm_1
        alert_service = AlertService(farm_context=farm_1.id)
        
        # Get critical alerts - should only return farm_1 alerts
        critical_alerts = await alert_service.get_critical_alerts()
        assert len(critical_alerts) == 1
        assert critical_alerts[0].farm_id == farm_1.id
        
        # Global alert stats should be farm-scoped
        stats = await alert_service.get_alert_statistics()
        assert stats["total_alerts"] == 1
        assert stats["critical_alerts"] == 1

    async def test_irrigation_scheduling_isolation(self):
        """Test irrigation service maintains farm boundaries"""
        
        farm_1 = await create_test_farm("Farm 1", system_type="nft")
        farm_2 = await create_test_farm("Farm 2", system_type="dwc")
        
        # Create irrigation schedules
        schedule_1 = await create_irrigation_schedule(farm_1.id, "morning")
        schedule_2 = await create_irrigation_schedule(farm_2.id, "evening")
        
        # Irrigation service scoped to farm_1
        irrigation_service = IrrigationService(farm_context=farm_1.id)
        
        # Get active schedules
        schedules = await irrigation_service.get_active_schedules()
        assert len(schedules) == 1
        assert schedules[0].farm_id == farm_1.id
        
        # Cross-farm schedule modification should fail
        with pytest.raises(PermissionError):
            await irrigation_service.update_schedule(
                schedule_2.id, {"frequency": "twice_daily"}
            )
```

## Real-time Data Isolation Testing

### WebSocket Isolation Testing
```python
class TestWebSocketIsolation:
    
    async def test_websocket_farm_scoping(self):
        """Test WebSocket connections are farm-scoped"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create WebSocket connections for each farm
        ws_client_1 = await self.create_ws_connection(farm_1.id)
        ws_client_2 = await self.create_ws_connection(farm_2.id)
        
        # Simulate sensor reading for farm_1
        await simulate_sensor_reading(farm_1.id, {
            "sensor_id": "temp_001",
            "value": 24.5,
            "timestamp": datetime.utcnow()
        })
        
        # Only farm_1 client should receive the update
        message_1 = await ws_client_1.receive_json(timeout=1.0)
        assert message_1["farm_id"] == farm_1.id
        assert message_1["sensor_reading"]["value"] == 24.5
        
        # Farm_2 client should not receive the update
        with pytest.raises(TimeoutError):
            await ws_client_2.receive_json(timeout=0.5)
    
    async def test_websocket_subscription_isolation(self):
        """Test WebSocket subscriptions respect farm boundaries"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create sensors in both farms
        sensor_1 = await create_test_sensor(farm_1.id, "Temp Sensor F1")
        sensor_2 = await create_test_sensor(farm_2.id, "Temp Sensor F2")
        
        # Client 1 connects and subscribes to farm_1 updates
        ws_client_1 = await self.create_ws_connection(farm_1.id)
        await ws_client_1.send_json({
            "action": "subscribe",
            "sensor_ids": [sensor_1.id, sensor_2.id]  # Try to subscribe to both
        })
        
        # Should only be subscribed to farm_1 sensors
        subscription_response = await ws_client_1.receive_json()
        subscribed_sensors = subscription_response["subscribed_sensors"]
        assert len(subscribed_sensors) == 1
        assert subscribed_sensors[0] == sensor_1.id
```

### Background Job Isolation
```python
class TestBackgroundJobIsolation:
    
    async def test_celery_task_farm_context(self):
        """Test that Celery tasks maintain farm context"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create sensors in both farms
        sensor_1 = await create_test_sensor(farm_1.id, "pH Sensor F1")
        sensor_2 = await create_test_sensor(farm_2.id, "pH Sensor F2")
        
        # Queue background tasks for sensor data processing
        task_1 = process_sensor_data.delay(
            sensor_1.id, 
            {"value": 6.5, "timestamp": datetime.utcnow()},
            farm_context=farm_1.id
        )
        
        task_2 = process_sensor_data.delay(
            sensor_2.id,
            {"value": 7.2, "timestamp": datetime.utcnow()}, 
            farm_context=farm_2.id
        )
        
        # Wait for tasks to complete
        result_1 = await task_1.get(timeout=5)
        result_2 = await task_2.get(timeout=5)
        
        # Verify tasks processed data for correct farms only
        assert result_1["farm_id"] == farm_1.id
        assert result_2["farm_id"] == farm_2.id
        
        # Check database isolation maintained
        f1_readings = await get_sensor_readings(farm_1.id)
        f2_readings = await get_sensor_readings(farm_2.id)
        
        assert len(f1_readings) == 1
        assert len(f2_readings) == 1
        assert f1_readings[0].farm_id == farm_1.id
        assert f2_readings[0].farm_id == farm_2.id

    async def test_scheduled_task_isolation(self):
        """Test scheduled tasks respect farm boundaries"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Schedule irrigation tasks for both farms
        await schedule_irrigation_check.delay(farm_1.id)
        await schedule_irrigation_check.delay(farm_2.id)
        
        # Tasks should process separately and maintain isolation
        # This test would verify through logs/database that tasks
        # only affected their respective farms
        
        f1_irrigation_logs = await get_irrigation_logs(farm_1.id)
        f2_irrigation_logs = await get_irrigation_logs(farm_2.id)
        
        # Verify separate processing
        assert len(f1_irrigation_logs) == 1
        assert len(f2_irrigation_logs) == 1
        assert f1_irrigation_logs[0].farm_id == farm_1.id
        assert f2_irrigation_logs[0].farm_id == farm_2.id
```

## Cache and Storage Isolation

### Cache Isolation Testing
```python
class TestCacheIsolation:
    
    async def test_redis_cache_farm_scoping(self):
        """Test that Redis cache keys are properly farm-scoped"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Cache sensor data for both farms
        sensor_data_1 = {"temp": 24.5, "humidity": 65}
        sensor_data_2 = {"temp": 26.2, "humidity": 70}
        
        await cache_service.set_sensor_data(farm_1.id, "temp_001", sensor_data_1)
        await cache_service.set_sensor_data(farm_2.id, "temp_001", sensor_data_2)
        
        # Retrieve cached data - should be farm-specific
        cached_1 = await cache_service.get_sensor_data(farm_1.id, "temp_001")
        cached_2 = await cache_service.get_sensor_data(farm_2.id, "temp_001")
        
        assert cached_1["temp"] == 24.5
        assert cached_2["temp"] == 26.2
        
        # Cross-farm cache access should return None
        cross_access = await cache_service.get_sensor_data(farm_1.id, "temp_002")
        assert cross_access is None
    
    async def test_cache_key_collision_prevention(self):
        """Test that cache keys don't collide across farms"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2") 
        
        # Same sensor ID in both farms (common scenario)
        sensor_id = "sensor_001"
        
        data_1 = {"status": "online", "location": "greenhouse_a"}
        data_2 = {"status": "maintenance", "location": "greenhouse_b"}
        
        # Cache data with same sensor ID for different farms
        await cache_service.set_sensor_metadata(farm_1.id, sensor_id, data_1)
        await cache_service.set_sensor_metadata(farm_2.id, sensor_id, data_2)
        
        # Retrieve data - should be farm-specific
        meta_1 = await cache_service.get_sensor_metadata(farm_1.id, sensor_id)
        meta_2 = await cache_service.get_sensor_metadata(farm_2.id, sensor_id)
        
        assert meta_1["status"] == "online"
        assert meta_2["status"] == "maintenance"
        assert meta_1["location"] != meta_2["location"]
```

### File Storage Isolation
```python
class TestFileStorageIsolation:
    
    async def test_file_upload_farm_isolation(self):
        """Test file uploads are isolated by farm"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Upload files for each farm
        file_1 = await upload_test_image(farm_1.id, "greenhouse_layout.jpg")
        file_2 = await upload_test_image(farm_2.id, "greenhouse_layout.jpg")
        
        # Files should have different storage paths
        assert file_1.storage_path.startswith(f"farms/{farm_1.id}/")
        assert file_2.storage_path.startswith(f"farms/{farm_2.id}/")
        assert file_1.storage_path != file_2.storage_path
        
        # Cross-farm file access should fail
        with pytest.raises(PermissionError):
            await file_service.get_file(farm_1.id, file_2.id)
    
    async def test_file_listing_isolation(self):
        """Test file listing is farm-scoped"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Upload multiple files to each farm
        await upload_test_files(farm_1.id, count=3)
        await upload_test_files(farm_2.id, count=2)
        
        # List files for farm_1
        f1_files = await file_service.list_farm_files(farm_1.id)
        f2_files = await file_service.list_farm_files(farm_2.id)
        
        assert len(f1_files) == 3
        assert len(f2_files) == 2
        
        # All files should belong to correct farm
        for file in f1_files:
            assert file.farm_id == farm_1.id
        for file in f2_files:
            assert file.farm_id == farm_2.id
```

## Performance Impact Testing

### Isolation Performance Tests
```python
class TestIsolationPerformance:
    
    async def test_rls_performance_impact(self):
        """Test Row-Level Security doesn't severely impact performance"""
        
        farms = []
        for i in range(10):
            farm = await create_test_farm(f"Farm {i}")
            farms.append(farm)
            # Create 100 sensors per farm
            await create_bulk_test_sensors(farm.id, count=100)
        
        # Measure query performance with RLS
        start_time = time.time()
        
        # Set context to random farm
        target_farm = farms[5]
        await set_farm_context(target_farm.id)
        
        # Query all sensors (should only return target farm's sensors)
        sensors = await db.execute(select(Sensor)).scalars().all()
        
        query_time = time.time() - start_time
        
        # Performance requirements
        assert query_time < 0.5  # Should complete in <500ms
        assert len(sensors) == 100  # Only target farm sensors
        
        # Verify all sensors belong to target farm
        for sensor in sensors:
            assert sensor.farm_id == target_farm.id

    async def test_concurrent_farm_access_performance(self):
        """Test performance under concurrent multi-farm access"""
        
        farms = [await create_test_farm(f"Farm {i}") for i in range(5)]
        
        async def farm_operations(farm_id):
            """Simulate typical farm operations"""
            await set_farm_context(farm_id)
            
            # Typical operations
            sensors = await get_farm_sensors(farm_id)
            readings = await get_latest_readings(farm_id, limit=50)
            alerts = await get_active_alerts(farm_id)
            
            return {
                "farm_id": farm_id,
                "sensors_count": len(sensors),
                "readings_count": len(readings),
                "alerts_count": len(alerts)
            }
        
        # Run concurrent operations
        start_time = time.time()
        
        results = await asyncio.gather(*[
            farm_operations(farm.id) for farm in farms
        ])
        
        total_time = time.time() - start_time
        
        # Performance requirements
        assert total_time < 2.0  # All operations in <2 seconds
        assert len(results) == 5  # All farms processed
        
        # Verify isolation maintained under load
        for i, result in enumerate(results):
            assert result["farm_id"] == farms[i].id
            assert result["sensors_count"] > 0
```

## Compliance and Audit Testing

### Audit Trail Isolation
```python
class TestAuditIsolation:
    
    async def test_audit_logs_farm_isolation(self):
        """Test that audit logs maintain farm isolation"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Perform auditable actions in both farms
        await perform_audit_action(farm_1.id, "sensor_created", {"sensor_id": 1})
        await perform_audit_action(farm_2.id, "alert_dismissed", {"alert_id": 5})
        
        # Query audit logs for farm_1
        f1_audit_logs = await get_audit_logs(farm_1.id)
        f2_audit_logs = await get_audit_logs(farm_2.id)
        
        assert len(f1_audit_logs) == 1
        assert len(f2_audit_logs) == 1
        
        assert f1_audit_logs[0].farm_id == farm_1.id
        assert f1_audit_logs[0].action == "sensor_created"
        
        assert f2_audit_logs[0].farm_id == farm_2.id
        assert f2_audit_logs[0].action == "alert_dismissed"
    
    async def test_gdpr_data_export_isolation(self):
        """Test GDPR data export respects farm boundaries"""
        
        farm_1 = await create_test_farm("Farm 1")
        farm_2 = await create_test_farm("Farm 2")
        
        # Create user data in both farms
        user_1 = await create_farm_user(farm_1.id, email="user1@farm1.com")
        user_2 = await create_farm_user(farm_2.id, email="user2@farm2.com")
        
        # Generate GDPR export for user_1
        export_data = await generate_gdpr_export(user_1.id)
        
        # Export should only contain farm_1 data
        assert export_data["farm_id"] == farm_1.id
        assert export_data["user_email"] == "user1@farm1.com"
        
        # Verify no farm_2 data leaked into export
        for data_item in export_data["personal_data"]:
            if "farm_id" in data_item:
                assert data_item["farm_id"] == farm_1.id
```

## Best Practices Summary

### DO's
- ✅ Test database RLS enforcement on every table
- ✅ Validate API endpoints prevent cross-farm access
- ✅ Test service layer farm context enforcement  
- ✅ Verify cache keys include farm ID prefixes
- ✅ Test WebSocket connections are farm-scoped
- ✅ Validate background jobs maintain farm context
- ✅ Test file storage uses farm-specific paths
- ✅ Verify audit logs include farm isolation

### DON'Ts
- ❌ Don't skip testing concurrent farm access
- ❌ Don't assume RLS works without explicit testing
- ❌ Don't forget to test bulk operations isolation
- ❌ Don't ignore performance impact of isolation
- ❌ Don't skip testing authentication bypass attempts
- ❌ Don't forget to test cache isolation
- ❌ Don't ignore background job context isolation
- ❌ Don't skip testing compliance data exports

This comprehensive cross-farm data isolation testing ensures ClarosFarm maintains absolute data separation while providing optimal performance and maintaining compliance with data protection regulations.