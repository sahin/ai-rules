# API Versioning Strategy Rules

## Purpose
Comprehensive API versioning strategy to ensure backward compatibility, smooth feature rollouts, and maintainable API evolution while following ClarosFarm's clean URL design principles (NO /v1/ versioning in URLs).

## 🚨 CRITICAL: ClarosFarm Versioning Philosophy

### Core Principles
- ✅ **Clean URLs**: NO version numbers in URLs (`/api/farms` not `/api/v1/farms`)
- ✅ **Header-Based Versioning**: Version negotiation through headers
- ✅ **Backward Compatibility**: Changes must be non-breaking for 12 months minimum
- ✅ **Gradual Migration**: Support multiple versions simultaneously
- ✅ **Farm Isolation**: Version changes respect multi-tenant boundaries
- ✅ **Consumer-Driven**: API changes driven by actual client needs

## Clean URL Versioning Strategy

### Header-Based Version Negotiation
```typescript
// API version negotiation through headers
interface APIVersionHeaders {
  'API-Version': string;        // Requested version: '2024-08-15'
  'Accept-Version': string;     // Acceptable versions: '2024-08-15,2024-06-01'
  'Content-Type': string;       // Always include for proper parsing
}

// FastAPI implementation
from fastapi import Header, HTTPException
from typing import Optional
from datetime import datetime

@app.middleware("http")
async def version_middleware(request, call_next):
    """Handle API versioning through headers"""
    
    # Get requested version from header
    api_version = request.headers.get('API-Version', DEFAULT_API_VERSION)
    
    # Validate version format (YYYY-MM-DD)
    if not validate_version_format(api_version):
        raise HTTPException(
            status_code=400,
            detail={
                "code": "INVALID_API_VERSION",
                "message": f"Invalid API version format: {api_version}",
                "supported_versions": get_supported_versions()
            }
        )
    
    # Check if version is supported
    if not is_version_supported(api_version):
        raise HTTPException(
            status_code=400,
            detail={
                "code": "UNSUPPORTED_API_VERSION", 
                "message": f"API version {api_version} is not supported",
                "supported_versions": get_supported_versions(),
                "migration_guide": f"/docs/migration/{api_version}"
            }
        )
    
    # Add version context to request
    request.state.api_version = api_version
    
    response = await call_next(request)
    
    # Add version info to response headers
    response.headers["API-Version"] = api_version
    response.headers["Supported-Versions"] = ",".join(get_supported_versions())
    response.headers["Deprecation-Notice"] = get_deprecation_notice(api_version)
    
    return response
```

### Version-Aware Endpoint Design
```python
# Clean endpoint design with internal versioning
from fastapi import APIRouter, Depends, Request
from app.core.versioning import get_api_version, VersionedResponse

router = APIRouter()

@router.get("/farms")  # Clean URL - no /v1/ prefix
async def get_farms(
    request: Request,
    current_user: User = Depends(get_current_user)
):
    """Get user farms with version-aware response"""
    api_version = request.state.api_version
    
    # Fetch data using version-aware service
    farms = await farm_service.get_user_farms(
        current_user.id, 
        api_version=api_version
    )
    
    # Return version-specific response format
    return VersionedResponse(
        data=farms,
        version=api_version,
        transform=FarmResponseTransformer
    )

@router.post("/farms")
async def create_farm(
    request: Request,
    farm_data: FarmCreateRequest,
    current_user: User = Depends(get_current_user)
):
    """Create farm with version-aware validation"""
    api_version = request.state.api_version
    
    # Version-specific validation
    validated_data = await validate_farm_data(farm_data, api_version)
    
    # Create farm with version context
    farm = await farm_service.create_farm(
        validated_data, 
        current_user.id,
        api_version=api_version
    )
    
    return VersionedResponse(
        data=farm,
        version=api_version,
        transform=FarmResponseTransformer,
        status_code=201
    )
```

## Version-Aware Data Models

### Pydantic Schema Versioning
```python
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Union, Literal
from datetime import datetime
from app.core.versioning import APIVersion

# Base models with version awareness
class VersionedBaseModel(BaseModel):
    model_config = ConfigDict(extra="forbid")
    
    def transform_for_version(self, version: APIVersion):
        """Transform model based on API version"""
        if version >= APIVersion.V2024_08_15:
            return self.model_dump()
        else:
            return self.model_dump(exclude={"new_fields"})

# Version-specific sensor models
class SensorResponseV20240815(VersionedBaseModel):
    """Sensor response for API version 2024-08-15"""
    id: int
    name: str
    sensor_type: str
    location: str
    status: Literal["online", "offline", "maintenance"]
    last_reading: Optional[dict] = None
    calibration_date: Optional[datetime] = None  # New field in this version
    accuracy_rating: Optional[float] = None      # New field in this version

class SensorResponseV20240601(VersionedBaseModel):
    """Sensor response for API version 2024-06-01"""
    id: int
    name: str
    sensor_type: str
    location: str
    status: Literal["active", "inactive"]  # Different enum values
    latest_value: Optional[float] = None   # Different field name
    
# Version transformer
class SensorResponseTransformer:
    @staticmethod
    def transform(sensor_data: dict, version: APIVersion) -> dict:
        if version >= APIVersion.V2024_08_15:
            return SensorResponseV20240815(**sensor_data).model_dump()
        elif version >= APIVersion.V2024_06_01:
            # Transform new format to old format
            transformed = {
                "id": sensor_data["id"],
                "name": sensor_data["name"],
                "sensor_type": sensor_data["sensor_type"],
                "location": sensor_data["location"],
                "status": "active" if sensor_data["status"] == "online" else "inactive",
                "latest_value": sensor_data.get("last_reading", {}).get("value")
            }
            return SensorResponseV20240601(**transformed).model_dump()
```

### Database Schema Evolution
```python
# Version-aware database queries
class VersionedSensorService:
    async def get_farm_sensors(
        self, 
        farm_id: int, 
        api_version: APIVersion = None
    ) -> List[dict]:
        """Get sensors with version-specific field selection"""
        
        # Base query always includes core fields
        base_query = (
            select(Sensor)
            .where(Sensor.farm_id == farm_id)
        )
        
        # Version-specific field selection
        if api_version >= APIVersion.V2024_08_15:
            # Include new fields for latest version
            query = base_query.options(
                selectinload(Sensor.calibration_records),
                selectinload(Sensor.accuracy_metrics)
            )
        else:
            # Minimal fields for older versions
            query = base_query.options(
                selectinload(Sensor.latest_reading)
            )
        
        result = await db.execute(query)
        sensors = result.scalars().all()
        
        # Transform data based on version
        return [
            SensorResponseTransformer.transform(
                sensor.to_dict(), 
                api_version
            ) for sensor in sensors
        ]
```

## Backward Compatibility Management

### Breaking Change Detection
```python
# Automated breaking change detection
class APICompatibilityChecker:
    def __init__(self, old_schema: dict, new_schema: dict):
        self.old_schema = old_schema
        self.new_schema = new_schema
        
    def check_breaking_changes(self) -> List[BreakingChange]:
        """Detect potential breaking changes between API versions"""
        changes = []
        
        # Check for removed fields
        changes.extend(self._check_removed_fields())
        
        # Check for type changes
        changes.extend(self._check_type_changes())
        
        # Check for new required fields
        changes.extend(self._check_new_required_fields())
        
        # Check for enum value changes
        changes.extend(self._check_enum_changes())
        
        return changes
    
    def _check_removed_fields(self) -> List[BreakingChange]:
        """Check for fields removed from the API"""
        breaking_changes = []
        
        old_fields = set(self._extract_fields(self.old_schema))
        new_fields = set(self._extract_fields(self.new_schema))
        
        removed_fields = old_fields - new_fields
        
        for field in removed_fields:
            breaking_changes.append(BreakingChange(
                type="field_removed",
                field=field,
                severity="high",
                description=f"Field '{field}' was removed from the response",
                migration_guide=f"Use alternative field or upgrade to newer version"
            ))
        
        return breaking_changes

# Usage in CI/CD pipeline
async def validate_api_compatibility():
    """Run compatibility checks before deployment"""
    current_schema = await extract_api_schema("current")
    new_schema = await extract_api_schema("new")
    
    checker = APICompatibilityChecker(current_schema, new_schema)
    breaking_changes = checker.check_breaking_changes()
    
    if breaking_changes:
        high_severity = [c for c in breaking_changes if c.severity == "high"]
        if high_severity:
            raise Exception(f"Deployment blocked: {len(high_severity)} breaking changes detected")
        else:
            print(f"Warning: {len(breaking_changes)} low-severity changes detected")
    
    return True
```

### Deprecation Management
```python
# Deprecation notification system
class DeprecationManager:
    def __init__(self):
        self.deprecation_warnings = {}
        
    def add_deprecation_warning(
        self,
        version: APIVersion,
        feature: str,
        removal_date: datetime,
        replacement: str = None
    ):
        """Add deprecation warning for a feature"""
        self.deprecation_warnings[feature] = {
            "deprecated_in": version,
            "removal_date": removal_date,
            "replacement": replacement,
            "migration_guide": f"/docs/migration/{feature}"
        }
    
    def get_deprecation_headers(self, version: APIVersion) -> dict:
        """Get deprecation headers for response"""
        headers = {}
        
        # Check if version itself is deprecated
        if self.is_version_deprecated(version):
            headers["Sunset"] = self.get_version_sunset_date(version).isoformat()
            headers["Link"] = f'</docs/migration/{version}>; rel="sunset"'
        
        return headers

# Usage in endpoints
@router.get("/sensors/{sensor_id}/readings")
async def get_sensor_readings(
    sensor_id: int,
    request: Request,
    limit: int = Query(100, le=1000),
    format: str = Query("json", deprecated=True)  # Mark parameter as deprecated
):
    """Get sensor readings with deprecation handling"""
    api_version = request.state.api_version
    
    # Handle deprecated parameter
    if format != "json":
        warnings.append({
            "code": "DEPRECATED_PARAMETER",
            "message": "Parameter 'format' is deprecated. All responses are JSON.",
            "deprecated_in": "2024-06-01",
            "removal_date": "2025-06-01"
        })
    
    readings = await sensor_service.get_readings(sensor_id, limit)
    
    return VersionedResponse(
        data=readings,
        version=api_version,
        warnings=warnings  # Include deprecation warnings
    )
```

## ClarosFarm Multi-Tenant Versioning

### Farm-Specific Version Support
```python
# Farm-level API version preferences
class FarmVersionManager:
    async def get_farm_api_preferences(self, farm_id: int) -> dict:
        """Get API version preferences for a specific farm"""
        preferences = await db.execute(
            select(FarmAPIPreferences)
            .where(FarmAPIPreferences.farm_id == farm_id)
        ).scalar_one_or_none()
        
        return {
            "preferred_version": preferences.preferred_version if preferences else DEFAULT_API_VERSION,
            "minimum_version": preferences.minimum_version if preferences else MIN_SUPPORTED_VERSION,
            "feature_flags": preferences.feature_flags if preferences else {}
        }
    
    async def update_farm_api_preferences(
        self,
        farm_id: int,
        version: APIVersion,
        feature_flags: dict = None
    ):
        """Update farm API preferences"""
        preferences = FarmAPIPreferences(
            farm_id=farm_id,
            preferred_version=version,
            feature_flags=feature_flags or {},
            updated_at=datetime.utcnow()
        )
        
        await db.merge(preferences)
        await db.commit()

# Farm-aware version middleware
@app.middleware("http")
async def farm_version_middleware(request, call_next):
    """Apply farm-specific version preferences"""
    
    # Get farm context from request
    farm_id = await extract_farm_id_from_request(request)
    
    if farm_id:
        # Get farm API preferences
        farm_prefs = await farm_version_manager.get_farm_api_preferences(farm_id)
        
        # Use farm's preferred version if no version specified in headers
        if not request.headers.get('API-Version'):
            request.state.api_version = farm_prefs["preferred_version"]
        
        # Apply farm-specific feature flags
        request.state.feature_flags = farm_prefs.get("feature_flags", {})
    
    return await call_next(request)
```

### Version-Aware Testing Strategy
```python
# Multi-version API testing
class APIVersionTester:
    def __init__(self, supported_versions: List[APIVersion]):
        self.supported_versions = supported_versions
    
    async def test_endpoint_across_versions(
        self,
        endpoint: str,
        test_data: dict,
        expected_responses: dict  # version -> expected_response
    ):
        """Test endpoint behavior across all supported versions"""
        
        for version in self.supported_versions:
            headers = {"API-Version": version.value}
            
            response = await self.client.get(endpoint, headers=headers)
            
            assert response.status_code == 200
            assert response.headers["API-Version"] == version.value
            
            # Validate version-specific response format
            expected = expected_responses[version]
            self.validate_response_schema(response.json(), expected)
    
    def validate_response_schema(self, response: dict, expected_schema: dict):
        """Validate response matches expected schema for version"""
        # Implementation to validate response structure
        pass

# Usage in tests
@pytest.mark.asyncio
async def test_get_farms_all_versions():
    """Test /farms endpoint across all API versions"""
    
    tester = APIVersionTester([
        APIVersion.V2024_06_01,
        APIVersion.V2024_08_15
    ])
    
    expected_responses = {
        APIVersion.V2024_06_01: {
            "farms": [
                {"id": 1, "name": "Test Farm", "active": True}
            ]
        },
        APIVersion.V2024_08_15: {
            "farms": [
                {"id": 1, "name": "Test Farm", "status": "online", "created_at": "..."}
            ]
        }
    }
    
    await tester.test_endpoint_across_versions(
        "/api/farms",
        {},
        expected_responses
    )
```

## Documentation and Migration Guides

### Auto-Generated API Documentation
```python
# Version-aware OpenAPI documentation
def generate_versioned_openapi():
    """Generate OpenAPI docs for each supported version"""
    
    for version in get_supported_versions():
        app_version = FastAPI(
            title=f"ClarosFarm API - {version}",
            version=version,
            description=f"Hydroponic farm management API - Version {version}"
        )
        
        # Add version-specific schemas
        add_version_schemas(app_version, version)
        
        # Generate OpenAPI spec
        openapi_schema = app_version.openapi()
        
        # Save to file
        with open(f"docs/openapi-{version}.json", "w") as f:
            json.dump(openapi_schema, f, indent=2)
        
        # Generate migration guide
        generate_migration_guide(version)

def generate_migration_guide(version: APIVersion):
    """Generate migration guide for version"""
    previous_version = get_previous_version(version)
    
    if not previous_version:
        return
    
    changes = compare_versions(previous_version, version)
    
    migration_guide = f"""
# Migration Guide: {previous_version} → {version}

## Breaking Changes
{format_breaking_changes(changes.breaking)}

## New Features  
{format_new_features(changes.additions)}

## Deprecated Features
{format_deprecated_features(changes.deprecations)}

## Code Examples
{generate_migration_examples(changes)}
"""
    
    with open(f"docs/migration-{version}.md", "w") as f:
        f.write(migration_guide)
```

### Client SDK Versioning
```typescript
// TypeScript client SDK with version support
class ClarosFarmClient {
  constructor(
    private apiKey: string,
    private apiVersion: string = '2024-08-15',
    private baseURL: string = 'https://api.clarosfarm.com'
  ) {}
  
  // Version-aware request method
  private async request<T>(
    endpoint: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const headers = {
      'Authorization': `Bearer ${this.apiKey}`,
      'API-Version': this.apiVersion,
      'Content-Type': 'application/json',
      ...options.headers
    };
    
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers
    });
    
    if (!response.ok) {
      throw new APIError(response);
    }
    
    // Check for deprecation warnings
    const deprecationNotice = response.headers.get('Deprecation-Notice');
    if (deprecationNotice) {
      console.warn(`API Deprecation Notice: ${deprecationNotice}`);
    }
    
    return response.json();
  }
  
  // Version-specific method overloads
  async getFarms(): Promise<Farm[]> {
    const response = await this.request<FarmsResponse>('/api/farms');
    
    // Version-specific response transformation
    if (this.apiVersion >= '2024-08-15') {
      return response.farms.map(farm => ({
        ...farm,
        isOnline: farm.status === 'online'  // Transform for client convenience
      }));
    } else {
      return response.farms.map(farm => ({
        ...farm,
        isOnline: farm.active  // Old field name
      }));
    }
  }
}
```

## Best Practices Summary

### DO's
- ✅ Use clean URLs without version prefixes
- ✅ Implement header-based versioning
- ✅ Maintain backward compatibility for 12+ months
- ✅ Provide clear migration guides
- ✅ Test all supported versions in CI/CD
- ✅ Use date-based version identifiers (2024-08-15)
- ✅ Include deprecation warnings in responses
- ✅ Support gradual client migration

### DON'Ts
- ❌ Don't put version numbers in URLs (/v1/, /v2/)
- ❌ Don't break APIs without deprecation period
- ❌ Don't remove fields without migration path
- ❌ Don't change field types without new version
- ❌ Don't ignore client compatibility needs
- ❌ Don't forget to document breaking changes
- ❌ Don't deploy without compatibility checks
- ❌ Don't mix versioning strategies

This API versioning strategy ensures ClarosFarm maintains clean URLs while providing robust version management, backward compatibility, and smooth migration paths for all clients.