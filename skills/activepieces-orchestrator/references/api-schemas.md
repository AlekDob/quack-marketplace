# ActivePieces API Schemas

Reference for API request/response formats.

## Authentication

### Sign In

```http
POST /api/v1/authentication/sign-in
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password"
}
```

**Response:**
```json
{
  "id": "user-id",
  "email": "user@example.com",
  "firstName": "User",
  "lastName": "Name",
  "token": "jwt-token",
  "projectId": "project-id",
  "platformRole": "ADMIN"
}
```

## Flows

### Create Flow

```http
POST /api/v1/flows
Authorization: Bearer {token}
Content-Type: application/json

{
  "displayName": "My Flow",
  "projectId": "project-id"
}
```

### Flow Operations

All operations use:
```http
POST /api/v1/flows/{flowId}
Authorization: Bearer {token}
Content-Type: application/json
```

#### UPDATE_TRIGGER

```json
{
  "type": "UPDATE_TRIGGER",
  "request": {
    "displayName": "Trigger Name",
    "name": "trigger",
    "type": "PIECE_TRIGGER",
    "valid": true,
    "settings": {
      "pieceName": "@activepieces/piece-schedule",
      "pieceVersion": "0.1.14",
      "triggerName": "every_x_minutes",
      "input": {
        "minutes": 5
      },
      "inputUiInfo": {},
      "propertySettings": {}
    }
  }
}
```

#### ADD_ACTION

```json
{
  "type": "ADD_ACTION",
  "request": {
    "parentStep": "trigger",
    "action": {
      "name": "step_1",
      "type": "PIECE",
      "displayName": "HTTP Request",
      "valid": true,
      "settings": {
        "pieceName": "@activepieces/piece-http",
        "pieceVersion": "0.11.2",
        "actionName": "send_request",
        "input": {
          "method": "GET",
          "url": "https://api.example.com",
          "headers": {},
          "queryParams": {},
          "authType": "NONE",
          "body_type": "none"
        },
        "inputUiInfo": {},
        "propertySettings": {}
      }
    }
  }
}
```

#### DELETE_ACTION

```json
{
  "type": "DELETE_ACTION",
  "request": {
    "names": ["step_name"]
  }
}
```

#### LOCK_AND_PUBLISH

```json
{
  "type": "LOCK_AND_PUBLISH",
  "request": {}
}
```

#### CHANGE_STATUS

```json
{
  "type": "CHANGE_STATUS",
  "request": {
    "status": "ENABLED"
  }
}
```

Status values: `ENABLED`, `DISABLED`

### List Flows

```http
GET /api/v1/flows?projectId={projectId}&limit=50
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": "flow-id",
      "status": "ENABLED",
      "version": {
        "displayName": "Flow Name",
        "trigger": {...},
        "valid": true,
        "state": "LOCKED"
      },
      "publishedVersionId": "version-id"
    }
  ],
  "next": "cursor",
  "previous": null
}
```

### Get Flow

```http
GET /api/v1/flows/{flowId}
Authorization: Bearer {token}
```

### Delete Flow

```http
DELETE /api/v1/flows/{flowId}
Authorization: Bearer {token}
```

## Flow Runs

### List Runs

```http
GET /api/v1/flow-runs?projectId={projectId}&flowId={flowId}&limit=20
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": "run-id",
      "flowId": "flow-id",
      "status": "SUCCEEDED",
      "created": "2024-01-01T00:00:00.000Z",
      "finished": "2024-01-01T00:00:05.000Z",
      "logsFileId": "logs-id"
    }
  ]
}
```

Run statuses: `RUNNING`, `SUCCEEDED`, `FAILED`, `PAUSED`

### Get Run

```http
GET /api/v1/flow-runs/{runId}
Authorization: Bearer {token}
```

## Pieces

### List Pieces

```http
GET /api/v1/pieces?searchQuery={query}
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "id": "piece-id",
    "name": "@activepieces/piece-http",
    "displayName": "HTTP",
    "description": "Send HTTP requests",
    "version": "0.11.2",
    "actions": 1,
    "triggers": 0,
    "auth": null,
    "categories": ["CORE"]
  }
]
```

### Get Piece Details

```http
GET /api/v1/pieces/{pieceName}
Authorization: Bearer {token}
```

**Response includes full action/trigger schemas.**

## Common Schemas

### Piece Settings

```json
{
  "pieceName": "@activepieces/piece-name",
  "pieceVersion": "x.y.z",
  "actionName": "action_name",
  "triggerName": "trigger_name",
  "input": {},
  "inputUiInfo": {},
  "propertySettings": {}
}
```

### HTTP Action Input

```json
{
  "method": "GET|POST|PUT|DELETE|PATCH|HEAD",
  "url": "string",
  "headers": {"key": "value"},
  "queryParams": {"key": "value"},
  "authType": "NONE|BASIC|BEARER_TOKEN",
  "authFields": {},
  "body_type": "none|json|form_data|raw",
  "body": {},
  "timeout": 30,
  "followRedirects": true,
  "response_is_binary": false,
  "use_proxy": false,
  "failureMode": "retry_none|retry_all|retry_5xx|continue_all|continue_none"
}
```

### Schedule Trigger Input

```json
{
  "minutes": 5,
  "timezone": "UTC",
  "run_on_weekends": true
}
```

### Code Action Input

```json
{
  "code": "export const code = async (inputs) => { return { result: 'ok' }; }",
  "inputs": {
    "key": "{{previous_step.value}}"
  }
}
```

## Data References

Use Liquid-style syntax to reference previous step outputs:

```
{{trigger.body}}           - Trigger output
{{step_1.body}}            - HTTP response body
{{step_1.body.data[0]}}    - Array access
{{step_1.headers.content-type}} - Header value
{{step_1.status}}          - HTTP status code
```

## Error Response

```json
{
  "statusCode": 400,
  "code": "FST_ERR_VALIDATION",
  "error": "Bad Request",
  "message": "Validation error details"
}
```

## Pagination

List endpoints support cursor-based pagination:

```http
GET /api/v1/flows?projectId={id}&limit=50&cursor={next}
```

Response includes:
- `data`: Array of items
- `next`: Cursor for next page (null if last)
- `previous`: Cursor for previous page (null if first)
