---
name: kestra-orchestrator
description: |
  Orchestrate workflows with Kestra - create, execute, monitor, and manage automation pipelines.
  This skill should be used when the user wants to automate tasks, create scheduled jobs,
  build data pipelines, or orchestrate multi-step workflows. Handles HTTP requests, scripts,
  database operations, file processing, notifications, and integrations with external services.
  Supports creating workflows from natural language descriptions, executing them, monitoring
  status, and iterating on failures. Use this skill for any automation or orchestration needs.
---

# Kestra Orchestrator

Manage Kestra workflow orchestration through API interactions. Create, execute, and monitor automation pipelines without manual UI intervention.

## Configuration

Kestra deployment details:

| Setting | Value |
|---------|-------|
| **URL** | `http://localhost:8081` |
| **API Base** | `http://localhost:8081/api/v1/main` |
| **Project Path** | `/Users/alekdob/Desktop/Dev/Personal/kestra/` |
| **Flows Directory** | `/Users/alekdob/Desktop/Dev/Personal/kestra/flows/` |

Authentication is handled automatically by the scripts using stored credentials.

## Quick Start

### Execute Common Operations

```bash
# List all workflows
scripts/kestra-api.sh list-flows

# Create a new workflow
scripts/kestra-api.sh create-flow /path/to/workflow.yml

# Execute a workflow
scripts/kestra-api.sh execute <namespace> <flow-id>

# Check execution status
scripts/kestra-api.sh status <execution-id>

# Get execution logs
scripts/kestra-api.sh logs <execution-id>

# Update existing workflow
scripts/kestra-api.sh update-flow <namespace> <flow-id> /path/to/workflow.yml

# Delete a workflow
scripts/kestra-api.sh delete-flow <namespace> <flow-id>
```

### Create Workflow from Description

To create a workflow from a natural language description:

1. Understand the user's automation need
2. Design the workflow YAML using available task types (see below)
3. Save to flows directory and upload via API
4. Execute and verify success
5. Iterate if needed based on execution results

## Workflow YAML Structure

Every Kestra workflow follows this structure:

```yaml
id: workflow-id           # Unique identifier (kebab-case, required)
namespace: namespace-name # Logical grouping (required)
description: |            # Human-readable description
  What this workflow does and why.

inputs:                   # Optional: User-provided inputs at execution time
  - id: input_name
    type: STRING          # STRING, INT, FLOAT, BOOLEAN, DATETIME, FILE, JSON
    defaults: "default"   # Default value if not provided
    description: Input description

tasks:                    # Required: Sequential list of tasks
  - id: task_id           # Unique within workflow
    type: io.kestra.plugin.xxx.TaskType
    # Task-specific properties...

triggers:                 # Optional: Automatic execution triggers
  - id: daily_schedule
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 * * *"     # Cron expression

outputs:                  # Optional: Expose values for downstream use
  - id: output_name
    type: STRING
    value: "{{ outputs.task_id.result }}"

errors:                   # Optional: Error handler tasks
  - id: on_failure
    type: io.kestra.plugin.core.log.Log
    message: "Workflow failed!"
```

## Available Task Types

### Logging & Debug

```yaml
- id: log_message
  type: io.kestra.plugin.core.log.Log
  message: "Processing {{ inputs.name }}..."
  level: INFO  # DEBUG, INFO, WARN, ERROR
```

### HTTP Requests

```yaml
- id: api_call
  type: io.kestra.plugin.core.http.Request
  uri: "https://api.example.com/data"
  method: GET  # GET, POST, PUT, DELETE, PATCH
  headers:
    Authorization: "Bearer {{ inputs.token }}"
    Content-Type: "application/json"
  body: '{"key": "value"}'
  options:
    connectTimeout: PT10S
    readTimeout: PT30S
```

### Shell Commands

```yaml
- id: shell_script
  type: io.kestra.plugin.scripts.shell.Commands
  commands:
    - echo "Starting process..."
    - curl -s https://api.example.com
    - date +%Y-%m-%d
  runner: PROCESS  # PROCESS or DOCKER
```

### Python Scripts

```yaml
- id: python_task
  type: io.kestra.plugin.scripts.python.Commands
  commands:
    - pip install requests
    - python script.py
  inputFiles:
    script.py: |
      import requests
      response = requests.get('https://api.example.com')
      print(response.json())
```

### Control Flow

```yaml
# Conditional execution
- id: check_condition
  type: io.kestra.plugin.core.flow.If
  condition: "{{ outputs.api_call.code == 200 }}"
  then:
    - id: success_task
      type: io.kestra.plugin.core.log.Log
      message: "Success!"
  else:
    - id: failure_task
      type: io.kestra.plugin.core.log.Log
      message: "Failed!"

# Parallel execution
- id: parallel_tasks
  type: io.kestra.plugin.core.flow.Parallel
  tasks:
    - id: task_a
      type: io.kestra.plugin.core.log.Log
      message: "Running A"
    - id: task_b
      type: io.kestra.plugin.core.log.Log
      message: "Running B"

# Loop over items
- id: process_items
  type: io.kestra.plugin.core.flow.ForEach
  values: ["item1", "item2", "item3"]
  tasks:
    - id: process_item
      type: io.kestra.plugin.core.log.Log
      message: "Processing {{ taskrun.value }}"
```

### File Operations

```yaml
# Download file
- id: download
  type: io.kestra.plugin.core.http.Download
  uri: "https://example.com/file.csv"

# Convert to CSV
- id: to_csv
  type: io.kestra.plugin.serdes.csv.IonToCsv
  from: "{{ outputs.query.uri }}"

# Convert to Excel
- id: to_excel
  type: io.kestra.plugin.serdes.excel.IonToExcel
  from: "{{ outputs.query.uri }}"
```

### Triggers

```yaml
triggers:
  # Cron schedule
  - id: daily
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 * * *"  # Every day at 9 AM

  # Webhook
  - id: webhook
    type: io.kestra.plugin.core.trigger.Webhook
    key: "my-secret-key"

  # On another flow completion
  - id: on_upstream
    type: io.kestra.plugin.core.trigger.Flow
    conditions:
      - type: io.kestra.plugin.core.condition.ExecutionStatus
        in: [SUCCESS]
      - type: io.kestra.plugin.core.condition.ExecutionFlow
        namespace: other-namespace
        flowId: upstream-flow
```

## Expression Syntax (Pebble Templates)

Access data using double curly braces:

```yaml
# Inputs
"{{ inputs.name }}"

# Task outputs
"{{ outputs.task_id.property }}"
"{{ outputs.http_task.body }}"      # Response body (string)
"{{ outputs.http_task.code }}"      # HTTP status code
"{{ outputs.http_task.headers }}"   # Response headers

# Execution metadata
"{{ execution.id }}"
"{{ execution.startDate }}"
"{{ flow.id }}"
"{{ flow.namespace }}"

# Built-in functions
"{{ now() }}"                        # Current timestamp
"{{ now() | date('yyyy-MM-dd') }}"  # Formatted date

# JSON parsing (when body is a JSON string)
"{{ outputs.api.body | json }}"     # Parse as JSON object
```

## Error Handling

### Retry on Failure

```yaml
- id: flaky_api
  type: io.kestra.plugin.core.http.Request
  uri: "https://sometimes-fails.com"
  retry:
    type: constant        # constant, exponential
    maxAttempt: 3
    interval: PT30S       # Wait 30 seconds between retries
```

### Allow Task to Fail

```yaml
- id: optional_task
  type: io.kestra.plugin.core.http.Request
  uri: "https://optional.com"
  allowFailure: true      # Workflow continues even if this fails
```

### Global Error Handler

```yaml
errors:
  - id: notify_on_failure
    type: io.kestra.plugin.core.http.Request
    uri: "https://hooks.slack.com/..."
    method: POST
    body: '{"text": "Workflow {{ flow.id }} failed!"}'
```

## Common Patterns

### Pattern 1: API Health Check

```yaml
id: api-health-check
namespace: monitoring

triggers:
  - id: every_5_minutes
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "*/5 * * * *"

tasks:
  - id: check_api
    type: io.kestra.plugin.core.http.Request
    uri: "https://api.example.com/health"

  - id: log_status
    type: io.kestra.plugin.core.log.Log
    message: "API status: {{ outputs.check_api.code }}"
```

### Pattern 2: Data Pipeline

```yaml
id: daily-data-sync
namespace: etl

triggers:
  - id: daily
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 2 * * *"

tasks:
  - id: extract
    type: io.kestra.plugin.core.http.Request
    uri: "https://source-api.com/data"

  - id: transform
    type: io.kestra.plugin.scripts.python.Commands
    commands:
      - python transform.py
    inputFiles:
      transform.py: |
        import json
        # Transform data here

  - id: load
    type: io.kestra.plugin.core.http.Request
    uri: "https://destination-api.com/import"
    method: POST
```

### Pattern 3: Notification on Event

```yaml
id: send-notification
namespace: notifications

inputs:
  - id: message
    type: STRING
    defaults: "Hello!"
  - id: channel
    type: STRING
    defaults: "general"

tasks:
  - id: send_discord
    type: io.kestra.plugin.core.http.Request
    uri: "https://discord.com/api/webhooks/..."
    method: POST
    headers:
      Content-Type: "application/json"
    body: '{"content": "{{ inputs.message }}"}'
```

## Troubleshooting

### Execution Failed

1. Get detailed logs:
   ```bash
   scripts/kestra-api.sh logs <execution-id>
   ```

2. Common issues:
   - **HTTP errors**: Verify URL, headers, authentication
   - **Template errors**: Check Pebble syntax (balanced braces, valid property paths)
   - **Timeout**: Increase timeout or add retry logic
   - **Permission denied**: Check Docker socket access

### Container Issues

```bash
# Check status
docker ps -a --filter name=kestra

# View logs
docker logs kestra-kestra-1 --tail 100

# Restart
cd /Users/alekdob/Desktop/Dev/Personal/kestra
docker compose restart

# Full reset (warning: loses data)
docker compose down -v && docker compose up -d
```

### Flow Not Uploading

1. Validate YAML syntax
2. Ensure unique `id` within namespace
3. Check required fields: `id`, `namespace`, `tasks`

## Resources

### Scripts

- `scripts/kestra-api.sh` - Main API wrapper for all Kestra operations
- `scripts/validate-workflow.sh` - Validate workflow YAML before upload

### References

- `references/plugins-catalog.md` - Full list of available plugins and options
- `references/cron-examples.md` - Common cron expressions

### Assets

- `assets/templates/` - Ready-to-use workflow templates for common scenarios
