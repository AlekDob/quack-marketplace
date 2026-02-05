---
name: fastapi-patterns
description: FastAPI patterns for building robust REST APIs with dependency injection, validation, and async.
---

# FastAPI Patterns

Best practices for building production-ready FastAPI applications.

## Project Structure

```
app/
├── main.py              # FastAPI app instance
├── config.py            # Settings
├── dependencies.py      # Shared dependencies
├── routers/
│   ├── users.py
│   └── items.py
├── models/              # SQLAlchemy models
│   └── user.py
├── schemas/             # Pydantic schemas
│   └── user.py
├── services/            # Business logic
│   └── user_service.py
└── utils/
    └── security.py
```

## Application Setup

```python
# main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await database.connect()
    yield
    # Shutdown
    await database.disconnect()

app = FastAPI(
    title="My API",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(items.router, prefix="/items", tags=["items"])
```

## Pydantic Schemas

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    id: int
    created_at: datetime
    is_active: bool = True

    model_config = {"from_attributes": True}

class UserUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
```

## Dependency Injection

```python
from fastapi import Depends, HTTPException, status
from typing import Annotated

# Database session
async def get_db():
    async with async_session() as session:
        yield session

# Current user
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await db.get(User, user_id)
    if user is None:
        raise credentials_exception
    return user

# Type alias for cleaner signatures
CurrentUser = Annotated[User, Depends(get_current_user)]
DbSession = Annotated[AsyncSession, Depends(get_db)]
```

## Route Handlers

```python
from fastapi import APIRouter, HTTPException, status, Query, Path

router = APIRouter()

@router.get("/", response_model=list[UserResponse])
async def list_users(
    db: DbSession,
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
):
    users = await user_service.get_users(db, skip=skip, limit=limit)
    return users

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int = Path(..., gt=0),
    db: DbSession = None,
):
    user = await user_service.get_user(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    db: DbSession,
):
    existing = await user_service.get_by_email(db, user_in.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    return await user_service.create_user(db, user_in)

@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_in: UserUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    if current_user.id != user_id and not current_user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    user = await user_service.update_user(db, user_id, user_in)
    return user
```

## Error Handling

```python
from fastapi import Request
from fastapi.responses import JSONResponse

class AppException(Exception):
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )
```

## Background Tasks

```python
from fastapi import BackgroundTasks

@router.post("/users/")
async def create_user(
    user: UserCreate,
    background_tasks: BackgroundTasks,
    db: DbSession,
):
    new_user = await user_service.create_user(db, user)
    background_tasks.add_task(send_welcome_email, new_user.email)
    return new_user
```

## Middleware

```python
from fastapi.middleware.cors import CORSMiddleware
import time

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Custom middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response
```

## Best Practices

- Use Pydantic for all request/response validation
- Leverage dependency injection for cross-cutting concerns
- Keep route handlers thin, move logic to services
- Use async for I/O-bound operations
- Handle errors with proper HTTP status codes
- Add request ID middleware for tracing
- Use background tasks for non-blocking operations
