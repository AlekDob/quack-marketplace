# Kestra Plugins Catalog

Complete reference of available plugins and their configuration options.

## Core Plugins

### io.kestra.plugin.core.log.Log

Log messages during workflow execution.

```yaml
- id: log_task
  type: io.kestra.plugin.core.log.Log
  message: "Your message here"
  level: INFO  # Optional: DEBUG, INFO, WARN, ERROR (default: INFO)
```

**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| message | String | Yes | Message to log (supports Pebble templates) |
| level | String | No | Log level (default: INFO) |

---

### io.kestra.plugin.core.http.Request

Make HTTP requests to external APIs.

```yaml
- id: http_request
  type: io.kestra.plugin.core.http.Request
  uri: "https://api.example.com/endpoint"
  method: GET
  headers:
    Authorization: "Bearer {{ inputs.token }}"
    Content-Type: "application/json"
  body: '{"key": "value"}'
  options:
    connectTimeout: PT10S
    readTimeout: PT30S
    followRedirects: true
```

**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| uri | String | Yes | Request URL |
| method | String | No | HTTP method (default: GET) |
| headers | Map | No | Request headers |
| body | String | No | Request body |
| options.connectTimeout | Duration | No | Connection timeout |
| options.readTimeout | Duration | No | Read timeout |
| options.followRedirects | Boolean | No | Follow redirects (default: true) |

**Outputs:**
| Output | Type | Description |
|--------|------|-------------|
| code | Integer | HTTP status code |
| body | String | Response body |
| headers | Map | Response headers |
| uri | String | Final URI (after redirects) |

---

### io.kestra.plugin.core.http.Download

Download a file from URL.

```yaml
- id: download
  type: io.kestra.plugin.core.http.Download
  uri: "https://example.com/file.csv"
```

**Outputs:**
| Output | Type | Description |
|--------|------|-------------|
| uri | String | Internal storage URI of downloaded file |

---

## Control Flow Plugins

### io.kestra.plugin.core.flow.If

Conditional execution based on expression.

```yaml
- id: conditional
  type: io.kestra.plugin.core.flow.If
  condition: "{{ outputs.check.code == 200 }}"
  then:
    - id: success
      type: io.kestra.plugin.core.log.Log
      message: "Success!"
  else:
    - id: failure
      type: io.kestra.plugin.core.log.Log
      message: "Failed!"
```

---

### io.kestra.plugin.core.flow.Switch

Branch execution based on value.

```yaml
- id: switch
  type: io.kestra.plugin.core.flow.Switch
  value: "{{ inputs.action }}"
  cases:
    create:
      - id: create_task
        type: io.kestra.plugin.core.log.Log
        message: "Creating..."
    delete:
      - id: delete_task
        type: io.kestra.plugin.core.log.Log
        message: "Deleting..."
  defaults:
    - id: default_task
      type: io.kestra.plugin.core.log.Log
      message: "Unknown action"
```

---

### io.kestra.plugin.core.flow.Parallel

Execute tasks in parallel.

```yaml
- id: parallel
  type: io.kestra.plugin.core.flow.Parallel
  tasks:
    - id: task_a
      type: io.kestra.plugin.core.log.Log
      message: "A"
    - id: task_b
      type: io.kestra.plugin.core.log.Log
      message: "B"
  concurrent: 5  # Max concurrent tasks (optional)
```

---

### io.kestra.plugin.core.flow.Sequential

Execute tasks sequentially (useful inside Parallel).

```yaml
- id: sequential
  type: io.kestra.plugin.core.flow.Sequential
  tasks:
    - id: step1
      type: io.kestra.plugin.core.log.Log
      message: "Step 1"
    - id: step2
      type: io.kestra.plugin.core.log.Log
      message: "Step 2"
```

---

### io.kestra.plugin.core.flow.ForEach

Loop over items.

```yaml
- id: loop
  type: io.kestra.plugin.core.flow.ForEach
  values: ["a", "b", "c"]
  # Or from output: values: "{{ outputs.get_items.list }}"
  tasks:
    - id: process
      type: io.kestra.plugin.core.log.Log
      message: "Processing {{ taskrun.value }}"
```

**Special Variables in Loop:**
- `{{ taskrun.value }}` - Current item
- `{{ taskrun.iteration }}` - Current index (0-based)

---

### io.kestra.plugin.core.flow.Pause

Pause execution and wait for manual approval or timeout.

```yaml
- id: wait_approval
  type: io.kestra.plugin.core.flow.Pause
  timeout: PT1H  # Optional: auto-resume after timeout
  onResume:
    - id: approved
      type: io.kestra.plugin.core.log.Log
      message: "Approved!"
```

---

### io.kestra.plugin.core.flow.Fail

Explicitly fail the workflow.

```yaml
- id: fail
  type: io.kestra.plugin.core.flow.Fail
  errorMessage: "Validation failed: {{ outputs.validate.errors }}"
```

---

### io.kestra.plugin.core.flow.Subflow

Execute another flow as a subflow.

```yaml
- id: run_subflow
  type: io.kestra.plugin.core.flow.Subflow
  namespace: other-namespace
  flowId: other-flow
  inputs:
    param1: "value1"
  wait: true  # Wait for completion
```

---

## Script Plugins

### io.kestra.plugin.scripts.shell.Commands

Execute shell/bash commands.

```yaml
- id: shell
  type: io.kestra.plugin.scripts.shell.Commands
  commands:
    - echo "Hello"
    - ls -la
    - curl -s https://api.example.com
  runner: PROCESS  # PROCESS or DOCKER
  env:
    MY_VAR: "value"
```

**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| commands | List<String> | Yes | Commands to execute |
| runner | String | No | PROCESS (local) or DOCKER |
| env | Map | No | Environment variables |
| workingDirectory | String | No | Working directory |

---

### io.kestra.plugin.scripts.python.Commands

Execute Python code.

```yaml
- id: python
  type: io.kestra.plugin.scripts.python.Commands
  commands:
    - pip install requests
    - python main.py
  inputFiles:
    main.py: |
      import requests
      response = requests.get('https://api.example.com')
      print(response.json())
  beforeCommands:
    - pip install --upgrade pip
```

**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| commands | List<String> | Yes | Commands to execute |
| inputFiles | Map | No | Files to create before execution |
| beforeCommands | List<String> | No | Setup commands |
| pythonPath | String | No | Path to Python executable |

---

### io.kestra.plugin.scripts.node.Commands

Execute Node.js code.

```yaml
- id: node
  type: io.kestra.plugin.scripts.node.Commands
  commands:
    - npm install axios
    - node main.js
  inputFiles:
    main.js: |
      const axios = require('axios');
      axios.get('https://api.example.com')
        .then(res => console.log(res.data));
```

---

## Serialization Plugins

### io.kestra.plugin.serdes.csv.IonToCsv

Convert Ion data to CSV.

```yaml
- id: to_csv
  type: io.kestra.plugin.serdes.csv.IonToCsv
  from: "{{ outputs.query.uri }}"
  header: true
  delimiter: ","
```

---

### io.kestra.plugin.serdes.json.IonToJson

Convert Ion data to JSON.

```yaml
- id: to_json
  type: io.kestra.plugin.serdes.json.IonToJson
  from: "{{ outputs.query.uri }}"
```

---

### io.kestra.plugin.serdes.excel.IonToExcel

Convert Ion data to Excel.

```yaml
- id: to_excel
  type: io.kestra.plugin.serdes.excel.IonToExcel
  from: "{{ outputs.query.uri }}"
  sheetName: "Data"
```

---

## Trigger Plugins

### io.kestra.plugin.core.trigger.Schedule

Cron-based scheduling.

```yaml
triggers:
  - id: daily
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 9 * * *"
    timezone: "Europe/Rome"
    inputs:
      source: "scheduled"
```

---

### io.kestra.plugin.core.trigger.Webhook

HTTP webhook trigger.

```yaml
triggers:
  - id: webhook
    type: io.kestra.plugin.core.trigger.Webhook
    key: "my-secret-key"
```

**Webhook URL:** `POST {kestra-url}/api/v1/executions/webhook/{namespace}/{flowId}/{key}`

---

### io.kestra.plugin.core.trigger.Flow

Trigger on another flow completion.

```yaml
triggers:
  - id: on_complete
    type: io.kestra.plugin.core.trigger.Flow
    conditions:
      - type: io.kestra.plugin.core.condition.ExecutionStatus
        in: [SUCCESS]
      - type: io.kestra.plugin.core.condition.ExecutionFlow
        namespace: upstream-namespace
        flowId: upstream-flow
```

---

## Duration Format (ISO 8601)

Use ISO 8601 duration format for timeouts and intervals:

| Format | Meaning |
|--------|---------|
| PT30S | 30 seconds |
| PT5M | 5 minutes |
| PT1H | 1 hour |
| PT1H30M | 1 hour 30 minutes |
| P1D | 1 day |
| P1DT12H | 1 day 12 hours |
