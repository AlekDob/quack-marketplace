#!/bin/bash
# Kestra API Wrapper Script
# Provides a simple interface to interact with Kestra via REST API
#
# Usage:
#   kestra-api.sh <command> [arguments]
#
# Commands:
#   list-flows                          List all workflows
#   list-flows <namespace>              List workflows in namespace
#   get-flow <namespace> <flow-id>      Get flow details
#   create-flow <yaml-file>             Create workflow from YAML file
#   update-flow <ns> <id> <yaml-file>   Update existing workflow
#   delete-flow <namespace> <flow-id>   Delete a workflow
#   execute <namespace> <flow-id>       Execute a workflow
#   execute <ns> <id> --input key=val   Execute with inputs
#   status <execution-id>               Get execution status
#   logs <execution-id>                 Get execution logs
#   health                              Check Kestra health

set -e

# Configuration
KESTRA_URL="${KESTRA_URL:-http://localhost:8081}"
KESTRA_API="${KESTRA_URL}/api/v1/main"
KESTRA_USER="${KESTRA_USER:-alekdobrohotov@gmail.com}"
KESTRA_PASS="${KESTRA_PASS:-0000Oliver!}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# API request helper
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local content_type="${4:-application/json}"

    local url="${KESTRA_API}${endpoint}"
    local auth="-u ${KESTRA_USER}:${KESTRA_PASS}"

    if [ -n "$data" ]; then
        curl -s -X "$method" $auth \
            -H "Content-Type: ${content_type}" \
            -d "$data" \
            "$url"
    else
        curl -s -X "$method" $auth "$url"
    fi
}

# Commands

cmd_health() {
    log_info "Checking Kestra health..."
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" -u "${KESTRA_USER}:${KESTRA_PASS}" "${KESTRA_URL}/api/v1/flows")

    if [ "$response" = "200" ] || [ "$response" = "404" ]; then
        log_success "Kestra is healthy (HTTP $response)"
        return 0
    else
        log_error "Kestra returned HTTP $response"
        return 1
    fi
}

cmd_list_flows() {
    local namespace="$1"
    local endpoint="/flows/search?size=100"

    if [ -n "$namespace" ]; then
        endpoint="${endpoint}&namespace=${namespace}"
        log_info "Listing flows in namespace: $namespace"
    else
        log_info "Listing all flows..."
    fi

    local response
    response=$(api_request "GET" "$endpoint")

    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    flows = data.get('results', [])
    if not flows:
        print('No flows found.')
    else:
        print(f'Found {len(flows)} flow(s):\n')
        for f in flows:
            ns = f.get('namespace', 'unknown')
            fid = f.get('id', 'unknown')
            rev = f.get('revision', 0)
            desc = f.get('description', '')[:50]
            print(f'  [{ns}] {fid} (rev {rev})')
            if desc:
                print(f'         {desc}...')
except json.JSONDecodeError:
    print('Error parsing response')
    sys.exit(1)
"
}

cmd_get_flow() {
    local namespace="$1"
    local flow_id="$2"

    if [ -z "$namespace" ] || [ -z "$flow_id" ]; then
        log_error "Usage: kestra-api.sh get-flow <namespace> <flow-id>"
        exit 1
    fi

    log_info "Getting flow: $namespace/$flow_id"
    api_request "GET" "/flows/${namespace}/${flow_id}" | python3 -m json.tool
}

cmd_create_flow() {
    local yaml_file="$1"

    if [ -z "$yaml_file" ]; then
        log_error "Usage: kestra-api.sh create-flow <yaml-file>"
        exit 1
    fi

    if [ ! -f "$yaml_file" ]; then
        log_error "File not found: $yaml_file"
        exit 1
    fi

    log_info "Creating flow from: $yaml_file"

    local response
    response=$(curl -s -X POST -u "${KESTRA_USER}:${KESTRA_PASS}" \
        -H "Content-Type: application/x-yaml" \
        --data-binary "@${yaml_file}" \
        "${KESTRA_API}/flows")

    # Check if response contains an error
    if echo "$response" | grep -q '"message".*"error"' 2>/dev/null; then
        log_error "Failed to create flow:"
        echo "$response" | python3 -m json.tool
        exit 1
    fi

    local flow_id namespace revision
    flow_id=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id','unknown'))" 2>/dev/null)
    namespace=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('namespace','unknown'))" 2>/dev/null)
    revision=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('revision',0))" 2>/dev/null)

    log_success "Flow created: ${namespace}/${flow_id} (revision ${revision})"
}

cmd_update_flow() {
    local namespace="$1"
    local flow_id="$2"
    local yaml_file="$3"

    if [ -z "$namespace" ] || [ -z "$flow_id" ] || [ -z "$yaml_file" ]; then
        log_error "Usage: kestra-api.sh update-flow <namespace> <flow-id> <yaml-file>"
        exit 1
    fi

    if [ ! -f "$yaml_file" ]; then
        log_error "File not found: $yaml_file"
        exit 1
    fi

    log_info "Updating flow: $namespace/$flow_id"

    local response
    response=$(curl -s -X PUT -u "${KESTRA_USER}:${KESTRA_PASS}" \
        -H "Content-Type: application/x-yaml" \
        --data-binary "@${yaml_file}" \
        "${KESTRA_API}/flows/${namespace}/${flow_id}")

    local revision
    revision=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('revision',0))" 2>/dev/null)

    log_success "Flow updated: ${namespace}/${flow_id} (revision ${revision})"
}

cmd_delete_flow() {
    local namespace="$1"
    local flow_id="$2"

    if [ -z "$namespace" ] || [ -z "$flow_id" ]; then
        log_error "Usage: kestra-api.sh delete-flow <namespace> <flow-id>"
        exit 1
    fi

    log_warn "Deleting flow: $namespace/$flow_id"
    api_request "DELETE" "/flows/${namespace}/${flow_id}"
    log_success "Flow deleted"
}

cmd_execute() {
    local namespace="$1"
    local flow_id="$2"
    shift 2

    if [ -z "$namespace" ] || [ -z "$flow_id" ]; then
        log_error "Usage: kestra-api.sh execute <namespace> <flow-id> [--input key=value ...]"
        exit 1
    fi

    # Parse inputs
    local inputs=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --input)
                if [ -n "$inputs" ]; then
                    inputs="${inputs}&"
                fi
                inputs="${inputs}$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    local endpoint="/executions/${namespace}/${flow_id}"
    if [ -n "$inputs" ]; then
        endpoint="${endpoint}?${inputs}"
    fi

    log_info "Executing flow: $namespace/$flow_id"

    local response
    response=$(api_request "POST" "$endpoint")

    local exec_id
    exec_id=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id','unknown'))" 2>/dev/null)

    log_success "Execution started: $exec_id"
    echo ""
    echo "Monitor with: kestra-api.sh status $exec_id"
    echo "View logs:    kestra-api.sh logs $exec_id"
    echo "UI:           ${KESTRA_URL}/ui/main/executions/${namespace}/${flow_id}/${exec_id}"
}

cmd_status() {
    local exec_id="$1"

    if [ -z "$exec_id" ]; then
        log_error "Usage: kestra-api.sh status <execution-id>"
        exit 1
    fi

    log_info "Getting execution status: $exec_id"

    local response
    response=$(api_request "GET" "/executions/${exec_id}")

    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    state = data.get('state', {}).get('current', 'UNKNOWN')
    flow_id = data.get('flowId', 'unknown')
    namespace = data.get('namespace', 'unknown')
    duration = data.get('state', {}).get('duration', 'N/A')

    # Color coding
    colors = {
        'SUCCESS': '\033[0;32m',
        'FAILED': '\033[0;31m',
        'RUNNING': '\033[0;34m',
        'CREATED': '\033[1;33m',
    }
    nc = '\033[0m'
    color = colors.get(state, nc)

    print(f'Flow: {namespace}/{flow_id}')
    print(f'Status: {color}{state}{nc}')
    print(f'Duration: {duration}')
    print()

    tasks = data.get('taskRunList', [])
    if tasks:
        print('Tasks:')
        for t in tasks:
            tid = t.get('taskId', 'unknown')
            tstate = t.get('state', {}).get('current', 'UNKNOWN')
            tcolor = colors.get(tstate, nc)
            print(f'  - {tid}: {tcolor}{tstate}{nc}')
except json.JSONDecodeError:
    print('Error parsing response')
    sys.exit(1)
"
}

cmd_logs() {
    local exec_id="$1"

    if [ -z "$exec_id" ]; then
        log_error "Usage: kestra-api.sh logs <execution-id>"
        exit 1
    fi

    log_info "Getting logs for: $exec_id"

    local response
    response=$(api_request "GET" "/logs/${exec_id}")

    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        for log in data:
            ts = log.get('timestamp', '')[:19]
            level = log.get('level', 'INFO')
            msg = log.get('message', '')
            task = log.get('taskId', '')

            # Color by level
            colors = {'ERROR': '\033[0;31m', 'WARN': '\033[1;33m', 'INFO': '\033[0;34m', 'DEBUG': '\033[0;37m'}
            nc = '\033[0m'
            color = colors.get(level, nc)

            prefix = f'[{task}] ' if task else ''
            print(f'{ts} {color}{level:5}{nc} {prefix}{msg}')
    else:
        print('No logs found')
except json.JSONDecodeError:
    print('Error parsing response')
    sys.exit(1)
"
}

cmd_help() {
    cat << 'EOF'
Kestra API Wrapper

Usage: kestra-api.sh <command> [arguments]

Commands:
  health                              Check Kestra health
  list-flows [namespace]              List workflows (optionally filter by namespace)
  get-flow <namespace> <flow-id>      Get flow details
  create-flow <yaml-file>             Create workflow from YAML file
  update-flow <ns> <id> <yaml-file>   Update existing workflow
  delete-flow <namespace> <flow-id>   Delete a workflow
  execute <namespace> <flow-id>       Execute a workflow
  status <execution-id>               Get execution status
  logs <execution-id>                 Get execution logs

Environment Variables:
  KESTRA_URL   Base URL (default: http://localhost:8081)
  KESTRA_USER  API username
  KESTRA_PASS  API password

Examples:
  # List all flows
  kestra-api.sh list-flows

  # Create a new flow
  kestra-api.sh create-flow my-workflow.yml

  # Execute and monitor
  kestra-api.sh execute automations my-flow
  kestra-api.sh status <execution-id>
EOF
}

# Main entry point
main() {
    local command="$1"
    shift || true

    case "$command" in
        health)
            cmd_health
            ;;
        list-flows|list)
            cmd_list_flows "$@"
            ;;
        get-flow|get)
            cmd_get_flow "$@"
            ;;
        create-flow|create)
            cmd_create_flow "$@"
            ;;
        update-flow|update)
            cmd_update_flow "$@"
            ;;
        delete-flow|delete)
            cmd_delete_flow "$@"
            ;;
        execute|exec|run)
            cmd_execute "$@"
            ;;
        status)
            cmd_status "$@"
            ;;
        logs)
            cmd_logs "$@"
            ;;
        help|--help|-h|"")
            cmd_help
            ;;
        *)
            log_error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
