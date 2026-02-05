---
name: python-testing
description: Python testing patterns with pytest, fixtures, mocking, and async testing.
---

# Python Testing Patterns

Comprehensive testing patterns with pytest.

## Pytest Basics

### Test Structure
```python
# test_user.py
import pytest
from myapp.user import User, UserService

class TestUser:
    def test_user_creation(self):
        user = User(name="Alice", email="alice@example.com")
        assert user.name == "Alice"
        assert user.email == "alice@example.com"

    def test_user_validation_fails_for_invalid_email(self):
        with pytest.raises(ValueError, match="Invalid email"):
            User(name="Alice", email="invalid")
```

### Parametrized Tests
```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
    ("", ""),
    ("MiXeD", "MIXED"),
])
def test_uppercase(input, expected):
    assert input.upper() == expected

# Multiple parameters
@pytest.mark.parametrize("x,y,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(x, y, expected):
    assert add(x, y) == expected
```

## Fixtures

### Basic Fixtures
```python
@pytest.fixture
def user():
    return User(name="Test User", email="test@example.com")

@pytest.fixture
def user_service(user):
    return UserService(default_user=user)

def test_user_service_returns_default(user_service, user):
    assert user_service.get_default() == user
```

### Fixture Scopes
```python
@pytest.fixture(scope="module")
def database():
    """Created once per test module."""
    db = create_database()
    yield db
    db.close()

@pytest.fixture(scope="session")
def app():
    """Created once per test session."""
    return create_app(testing=True)
```

### Fixture Factory
```python
@pytest.fixture
def make_user():
    def _make_user(name: str = "Test", email: str = None):
        email = email or f"{name.lower()}@example.com"
        return User(name=name, email=email)
    return _make_user

def test_multiple_users(make_user):
    alice = make_user("Alice")
    bob = make_user("Bob", "bob@test.com")
    assert alice.name != bob.name
```

## Mocking

### Basic Mocking
```python
from unittest.mock import Mock, patch, MagicMock

def test_service_calls_api():
    mock_api = Mock()
    mock_api.fetch.return_value = {"status": "ok"}

    service = MyService(api=mock_api)
    result = service.process()

    mock_api.fetch.assert_called_once()
    assert result["status"] == "ok"
```

### Patching
```python
@patch("myapp.services.external_api")
def test_with_patched_api(mock_api):
    mock_api.get_data.return_value = {"data": [1, 2, 3]}

    result = my_function()

    assert result == [1, 2, 3]

# Context manager
def test_with_context_patch():
    with patch("myapp.services.send_email") as mock_send:
        mock_send.return_value = True
        result = register_user("test@example.com")
        mock_send.assert_called_once_with("test@example.com")
```

### Async Mocking
```python
from unittest.mock import AsyncMock

@pytest.mark.asyncio
async def test_async_service():
    mock_client = AsyncMock()
    mock_client.fetch.return_value = {"data": "test"}

    service = AsyncService(client=mock_client)
    result = await service.get_data()

    assert result == {"data": "test"}
    mock_client.fetch.assert_awaited_once()
```

## Async Testing

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await async_fetch("https://api.example.com")
    assert result is not None

@pytest.fixture
async def async_client():
    async with AsyncClient() as client:
        yield client

@pytest.mark.asyncio
async def test_with_async_fixture(async_client):
    response = await async_client.get("/api/users")
    assert response.status == 200
```

## FastAPI Testing

```python
from fastapi.testclient import TestClient
from httpx import AsyncClient
import pytest

# Sync testing
def test_read_main():
    client = TestClient(app)
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}

# Async testing
@pytest.mark.asyncio
async def test_async_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/users")
    assert response.status_code == 200

# With dependency override
def test_with_overridden_dependency():
    def override_get_db():
        return TestDatabase()

    app.dependency_overrides[get_db] = override_get_db

    client = TestClient(app)
    response = client.get("/items")
    assert response.status_code == 200

    app.dependency_overrides.clear()
```

## Coverage

```bash
# Run with coverage
pytest --cov=myapp --cov-report=html

# Require minimum coverage
pytest --cov=myapp --cov-fail-under=80
```

## Best Practices

- Use descriptive test names: `test_user_creation_fails_with_invalid_email`
- One assertion concept per test
- Use fixtures for setup, not test body
- Mock at boundaries (APIs, databases)
- Test edge cases and error conditions
- Keep tests fast and independent
- Use `pytest.mark.slow` for integration tests
