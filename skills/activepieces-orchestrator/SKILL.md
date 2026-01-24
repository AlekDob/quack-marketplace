# ActivePieces Orchestrator Skill

Orchestrate workflows with ActivePieces - create, execute, monitor, and manage automation pipelines via API.

## When to Use

Use this skill when the user wants to:
- Create automated workflows (schedules, webhooks, integrations)
- Execute and monitor flow runs
- Manage pieces (integrations) and connections
- Build data pipelines or ETL processes
- Set up notifications and alerts
- Integrate external APIs

## Prerequisites

- ActivePieces running on `http://localhost:8082`
- Valid user credentials for API authentication
- Docker environment (for self-hosted setup)

## Authentication

ActivePieces uses JWT tokens. Get a token by signing in:

```bash
~/.claude/skills/activepieces-orchestrator/scripts/activepieces-api.sh login
```

**Default credentials** (change in production):
- Email: `alekdobrohotov@gmail.com`
- Password: `0000Oliver!`

## API Reference

### Base URL
```
http://localhost:8082/api/v1
```

### Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/authentication/sign-in` | POST | Get JWT token |
| `/flows` | GET | List all flows |
| `/flows` | POST | Create new flow |
| `/flows/{id}` | GET | Get flow details |
| `/flows/{id}` | POST | Apply operation to flow |
| `/flow-runs` | GET | List flow runs |
| `/pieces` | GET | List available pieces |

### Flow Operations

Apply operations to flows using POST to `/flows/{id}`:

| Operation | Purpose |
|-----------|---------|
| `UPDATE_TRIGGER` | Set/modify flow trigger |
| `ADD_ACTION` | Add action step after another |
| `DELETE_ACTION` | Remove an action step |
| `LOCK_AND_PUBLISH` | Publish flow version |
| `CHANGE_STATUS` | Enable/disable flow |

## CLI Commands

Use the wrapper script for common operations:

```bash
# Authentication
activepieces-api.sh login                    # Get new token
activepieces-api.sh whoami                   # Check current user

# Flows
activepieces-api.sh list-flows               # List all flows
activepieces-api.sh get-flow <id>            # Get flow details
activepieces-api.sh create-flow <name>       # Create empty flow
activepieces-api.sh delete-flow <id>         # Delete flow
activepieces-api.sh enable-flow <id>         # Enable flow
activepieces-api.sh disable-flow <id>        # Disable flow

# Flow Runs
activepieces-api.sh list-runs [flow-id]      # List runs
activepieces-api.sh get-run <run-id>         # Get run details

# Pieces
activepieces-api.sh list-pieces [search]     # List available pieces
activepieces-api.sh get-piece <name>         # Get piece details

# Health
activepieces-api.sh health                   # Check API health
```

## Creating Flows Programmatically

### Step 1: Create Empty Flow

```bash
curl -X POST "http://localhost:8082/api/v1/flows" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"displayName": "My Flow", "projectId": "'$PROJECT_ID'"}'
```

### Step 2: Add Trigger

```bash
curl -X POST "http://localhost:8082/api/v1/flows/$FLOW_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "UPDATE_TRIGGER",
    "request": {
      "displayName": "Every 5 Minutes",
      "name": "trigger",
      "type": "PIECE_TRIGGER",
      "valid": true,
      "settings": {
        "pieceName": "@activepieces/piece-schedule",
        "pieceVersion": "0.1.14",
        "triggerName": "every_x_minutes",
        "input": { "minutes": 5 },
        "inputUiInfo": {},
        "propertySettings": {}
      }
    }
  }'
```

### Step 3: Add Actions

```bash
curl -X POST "http://localhost:8082/api/v1/flows/$FLOW_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "ADD_ACTION",
    "request": {
      "parentStep": "trigger",
      "action": {
        "name": "http_request",
        "type": "PIECE",
        "displayName": "HTTP Request",
        "valid": true,
        "settings": {
          "pieceName": "@activepieces/piece-http",
          "pieceVersion": "0.11.2",
          "actionName": "send_request",
          "input": {
            "method": "GET",
            "url": "https://api.example.com/data",
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
  }'
```

### Step 4: Publish and Enable

```bash
# Publish
curl -X POST "http://localhost:8082/api/v1/flows/$FLOW_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "LOCK_AND_PUBLISH", "request": {}}'

# Enable
curl -X POST "http://localhost:8082/api/v1/flows/$FLOW_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "CHANGE_STATUS", "request": {"status": "ENABLED"}}'
```

## Common Pieces

### Schedule Triggers

| Trigger | Description |
|---------|-------------|
| `every_x_minutes` | Run every N minutes (1-59) |
| `every_hour` | Run every hour |
| `every_day` | Run daily at specific hour |
| `every_week` | Run weekly |
| `cron_expression` | Custom cron schedule |

### HTTP Piece

```json
{
  "pieceName": "@activepieces/piece-http",
  "actionName": "send_request",
  "input": {
    "method": "GET|POST|PUT|DELETE",
    "url": "https://...",
    "headers": {"Content-Type": "application/json"},
    "queryParams": {},
    "authType": "NONE|BASIC|BEARER_TOKEN",
    "body_type": "none|json|form_data|raw",
    "body": {}
  }
}
```

### Code Piece (JavaScript)

```json
{
  "pieceName": "@activepieces/piece-code",
  "actionName": "run_javascript",
  "input": {
    "code": "export const code = async (inputs) => { return { result: inputs.data * 2 }; }",
    "inputs": { "data": "{{trigger.body}}" }
  }
}
```

### Popular Integrations

| Category | Pieces |
|----------|--------|
| **Communication** | Gmail, Slack, Discord, Telegram, SendGrid |
| **CRM** | HubSpot, Salesforce, Pipedrive |
| **Database** | PostgreSQL, MySQL, MongoDB, Supabase |
| **AI** | OpenAI, Anthropic, Google AI |
| **Storage** | Google Drive, Dropbox, S3 |
| **Dev Tools** | GitHub, GitLab, Linear, Notion |

## Data References

Use `{{step_name.property}}` to reference data from previous steps:

```
{{trigger.body}}           - Trigger output body
{{step_1.body}}            - HTTP response body
{{step_1.body.data[0]}}    - First item in array
{{step_1.headers}}         - Response headers
```

## Error Handling

### Failure Modes

| Mode | Description |
|------|-------------|
| `retry_all` | Retry on any error |
| `retry_5xx` | Retry only on server errors |
| `retry_none` | No retry |
| `continue_all` | Continue flow on any error |
| `continue_none` | Stop flow on error |

## Local Webhook Integration

For macOS notifications or local scripts, use a webhook server:

```bash
# Start local webhook server (port 9999)
python3 ~/.claude/skills/activepieces-orchestrator/scripts/webhook-server.py &

# In ActivePieces, call: http://host.docker.internal:9999
# (host.docker.internal resolves to host machine from Docker)
```

## Templates

Pre-built templates are available in `assets/templates/`:

- `weather-notification.json` - Weather check with notification
- `api-health-monitor.json` - API endpoint monitoring
- `rss-to-discord.json` - RSS feed to Discord
- `github-activity.json` - GitHub webhook handler
- `scheduled-report.json` - Scheduled data aggregation

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Token expired, run `activepieces-api.sh login` |
| 502 Bad Gateway | Container starting, wait 30s |
| Flow not running | Check if published AND enabled |
| Docker host access | Use `host.docker.internal` for localhost |

### Logs

```bash
# ActivePieces logs
docker compose logs -f activepieces

# Specific flow run logs
activepieces-api.sh get-run <run-id>
```

## Best Practices

1. **Always publish before enabling** - Flow must be LOCKED state
2. **Use descriptive names** - Both for flows and steps
3. **Test incrementally** - Add one step at a time
4. **Handle errors** - Set appropriate failure modes
5. **Use variables** - Reference data from previous steps
6. **Monitor runs** - Check for failures regularly

## Integration with Quack

ActivePieces can trigger Quack agents via local webhook:

```javascript
// In ActivePieces Code step
const response = await fetch('http://host.docker.internal:9999', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'notify',
    message: 'Flow completed!'
  })
});
```

## Resources

- [ActivePieces Docs](https://www.activepieces.com/docs)
- [Pieces Directory](https://www.activepieces.com/pieces)
- [GitHub](https://github.com/activepieces/activepieces)
- [Community Discord](https://discord.gg/activepieces)
