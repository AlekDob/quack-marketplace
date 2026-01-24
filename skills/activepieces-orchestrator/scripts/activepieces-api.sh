#!/bin/bash
#
# ActivePieces API CLI Wrapper
# Usage: activepieces-api.sh <command> [args]
#

set -e

# Configuration
ACTIVEPIECES_URL="${ACTIVEPIECES_URL:-http://localhost:8082}"
TOKEN_FILE="${HOME}/.activepieces-token"
CREDENTIALS_FILE="${HOME}/.activepieces-credentials"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Get stored credentials
get_credentials() {
    if [[ -f "$CREDENTIALS_FILE" ]]; then
        source "$CREDENTIALS_FILE"
    else
        # Default credentials (change these!)
        AP_EMAIL="${AP_EMAIL:-alekdobrohotov@gmail.com}"
        AP_PASSWORD="${AP_PASSWORD:-0000Oliver\!}"
    fi
}

# Get or refresh token
get_token() {
    if [[ -f "$TOKEN_FILE" ]]; then
        # Check if token is still valid (less than 6 days old)
        if [[ $(find "$TOKEN_FILE" -mtime -6 2>/dev/null) ]]; then
            cat "$TOKEN_FILE"
            return 0
        fi
    fi

    # Need to login
    login_and_save_token
}

# Login and save token
login_and_save_token() {
    get_credentials

    log_info "Authenticating with ActivePieces..."

    local response
    response=$(curl -s -X POST "${ACTIVEPIECES_URL}/api/v1/authentication/sign-in" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"${AP_EMAIL}\",\"password\":\"${AP_PASSWORD}\"}" 2>/dev/null)

    if echo "$response" | grep -q '"token"'; then
        local token project_id
        token=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])")
        project_id=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin)['projectId'])")

        echo "$token" > "$TOKEN_FILE"
        echo "AP_PROJECT_ID=$project_id" >> "$CREDENTIALS_FILE" 2>/dev/null || true

        log_success "Authenticated! Token saved."
        echo "$token"
    else
        log_error "Authentication failed: $response"
        exit 1
    fi
}

# Get project ID
get_project_id() {
    get_credentials
    if [[ -n "$AP_PROJECT_ID" ]]; then
        echo "$AP_PROJECT_ID"
    else
        # Extract from token response
        local token_response
        token_response=$(curl -s -X POST "${ACTIVEPIECES_URL}/api/v1/authentication/sign-in" \
            -H "Content-Type: application/json" \
            -d "{\"email\":\"${AP_EMAIL}\",\"password\":\"${AP_PASSWORD}\"}" 2>/dev/null)
        echo "$token_response" | python3 -c "import json,sys; print(json.load(sys.stdin)['projectId'])"
    fi
}

# API call helper
api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local token
    token=$(get_token)

    local curl_args=(
        -s
        -X "$method"
        "${ACTIVEPIECES_URL}/api/v1${endpoint}"
        -H "Authorization: Bearer $token"
        -H "Content-Type: application/json"
    )

    if [[ -n "$data" ]]; then
        curl_args+=(-d "$data")
    fi

    curl "${curl_args[@]}" 2>/dev/null
}

# Commands
cmd_login() {
    login_and_save_token > /dev/null
}

cmd_whoami() {
    local response
    response=$(api_call GET "/users/me")
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
}

cmd_health() {
    if curl -s "${ACTIVEPIECES_URL}/api/v1/flags" > /dev/null 2>&1; then
        log_success "ActivePieces is running at ${ACTIVEPIECES_URL}"
    else
        log_error "ActivePieces is not reachable at ${ACTIVEPIECES_URL}"
        exit 1
    fi
}

cmd_list_flows() {
    local project_id
    project_id=$(get_project_id)
    local response
    response=$(api_call GET "/flows?projectId=${project_id}&limit=50")

    if [[ "$1" == "--json" ]]; then
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    else
        echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
flows = data.get('data', [])
if not flows:
    print('No flows found.')
else:
    print(f'Found {len(flows)} flow(s):\n')
    for f in flows:
        status = f.get('status', 'UNKNOWN')
        status_icon = '✅' if status == 'ENABLED' else '⏸️'
        name = f.get('version', {}).get('displayName', 'Unnamed')
        print(f'{status_icon} [{status:8}] {name}')
        print(f'   ID: {f[\"id\"]}')
        print()
" 2>/dev/null || echo "$response"
    fi
}

cmd_get_flow() {
    local flow_id="$1"
    if [[ -z "$flow_id" ]]; then
        log_error "Usage: activepieces-api.sh get-flow <flow-id>"
        exit 1
    fi

    local response
    response=$(api_call GET "/flows/${flow_id}")
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
}

cmd_create_flow() {
    local name="${1:-New Flow}"
    local project_id
    project_id=$(get_project_id)

    local response
    response=$(api_call POST "/flows" "{\"displayName\":\"${name}\",\"projectId\":\"${project_id}\"}")

    local flow_id
    flow_id=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null)

    if [[ -n "$flow_id" ]]; then
        log_success "Created flow: $name"
        echo "Flow ID: $flow_id"
    else
        log_error "Failed to create flow"
        echo "$response"
    fi
}

cmd_delete_flow() {
    local flow_id="$1"
    if [[ -z "$flow_id" ]]; then
        log_error "Usage: activepieces-api.sh delete-flow <flow-id>"
        exit 1
    fi

    local response
    response=$(api_call DELETE "/flows/${flow_id}")

    if [[ -z "$response" ]] || echo "$response" | grep -q "null"; then
        log_success "Flow deleted: $flow_id"
    else
        log_error "Failed to delete flow"
        echo "$response"
    fi
}

cmd_enable_flow() {
    local flow_id="$1"
    if [[ -z "$flow_id" ]]; then
        log_error "Usage: activepieces-api.sh enable-flow <flow-id>"
        exit 1
    fi

    # First publish if needed
    api_call POST "/flows/${flow_id}" '{"type":"LOCK_AND_PUBLISH","request":{}}' > /dev/null 2>&1
    sleep 1

    # Then enable
    local response
    response=$(api_call POST "/flows/${flow_id}" '{"type":"CHANGE_STATUS","request":{"status":"ENABLED"}}')

    local status
    status=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)

    if [[ "$status" == "ENABLED" ]]; then
        log_success "Flow enabled: $flow_id"
    else
        log_warn "Flow status: $status"
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    fi
}

cmd_disable_flow() {
    local flow_id="$1"
    if [[ -z "$flow_id" ]]; then
        log_error "Usage: activepieces-api.sh disable-flow <flow-id>"
        exit 1
    fi

    local response
    response=$(api_call POST "/flows/${flow_id}" '{"type":"CHANGE_STATUS","request":{"status":"DISABLED"}}')

    local status
    status=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)

    if [[ "$status" == "DISABLED" ]]; then
        log_success "Flow disabled: $flow_id"
    else
        log_warn "Flow status: $status"
    fi
}

cmd_list_runs() {
    local flow_id="$1"
    local project_id
    project_id=$(get_project_id)

    local endpoint="/flow-runs?projectId=${project_id}&limit=20"
    if [[ -n "$flow_id" ]]; then
        endpoint="${endpoint}&flowId=${flow_id}"
    fi

    local response
    response=$(api_call GET "$endpoint")

    if [[ "$1" == "--json" ]] || [[ "$2" == "--json" ]]; then
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    else
        echo "$response" | python3 -c "
import json, sys
from datetime import datetime

data = json.load(sys.stdin)
runs = data.get('data', [])
if not runs:
    print('No runs found.')
else:
    print(f'Found {len(runs)} run(s):\n')
    for r in runs:
        status = r.get('status', 'UNKNOWN')
        icons = {'SUCCEEDED': '✅', 'FAILED': '❌', 'RUNNING': '🔄', 'PAUSED': '⏸️'}
        icon = icons.get(status, '❓')
        created = r.get('created', '')[:19].replace('T', ' ')
        print(f'{icon} [{status:10}] {created}')
        print(f'   Run ID: {r[\"id\"]}')
        print()
" 2>/dev/null || echo "$response"
    fi
}

cmd_get_run() {
    local run_id="$1"
    if [[ -z "$run_id" ]]; then
        log_error "Usage: activepieces-api.sh get-run <run-id>"
        exit 1
    fi

    local response
    response=$(api_call GET "/flow-runs/${run_id}")
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
}

cmd_list_pieces() {
    local search="$1"
    local endpoint="/pieces"
    if [[ -n "$search" ]]; then
        endpoint="${endpoint}?searchQuery=${search}"
    fi

    local response
    response=$(api_call GET "$endpoint")

    echo "$response" | python3 -c "
import json, sys
pieces = json.load(sys.stdin)
if not pieces:
    print('No pieces found.')
else:
    print(f'Found {len(pieces)} piece(s):\n')
    for p in pieces[:30]:  # Limit output
        name = p.get('displayName', 'Unknown')
        pkg = p.get('name', '')
        actions = p.get('actions', 0)
        triggers = p.get('triggers', 0)
        print(f'📦 {name}')
        print(f'   Package: {pkg}')
        print(f'   Actions: {actions}, Triggers: {triggers}')
        print()
" 2>/dev/null || echo "$response"
}

cmd_get_piece() {
    local piece_name="$1"
    if [[ -z "$piece_name" ]]; then
        log_error "Usage: activepieces-api.sh get-piece <piece-name>"
        exit 1
    fi

    local response
    response=$(api_call GET "/pieces/${piece_name}")
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
}

cmd_help() {
    cat << 'EOF'
ActivePieces API CLI Wrapper

Usage: activepieces-api.sh <command> [arguments]

Authentication:
  login                     Authenticate and save token
  whoami                    Show current user info

Flows:
  list-flows [--json]       List all flows
  get-flow <id>             Get flow details
  create-flow <name>        Create new empty flow
  delete-flow <id>          Delete a flow
  enable-flow <id>          Publish and enable flow
  disable-flow <id>         Disable flow

Flow Runs:
  list-runs [flow-id]       List flow runs
  get-run <run-id>          Get run details

Pieces:
  list-pieces [search]      List available pieces
  get-piece <name>          Get piece details (actions, triggers)

Health:
  health                    Check if ActivePieces is running

Environment Variables:
  ACTIVEPIECES_URL          Base URL (default: http://localhost:8082)
  AP_EMAIL                  Login email
  AP_PASSWORD               Login password

Examples:
  # Check health
  activepieces-api.sh health

  # List flows
  activepieces-api.sh list-flows

  # Create and enable a flow
  activepieces-api.sh create-flow "My Automation"
  activepieces-api.sh enable-flow <flow-id>

  # Search for pieces
  activepieces-api.sh list-pieces gmail
  activepieces-api.sh get-piece @activepieces/piece-http
EOF
}

# Main
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        login)          cmd_login "$@" ;;
        whoami)         cmd_whoami "$@" ;;
        health)         cmd_health "$@" ;;
        list-flows)     cmd_list_flows "$@" ;;
        get-flow)       cmd_get_flow "$@" ;;
        create-flow)    cmd_create_flow "$@" ;;
        delete-flow)    cmd_delete_flow "$@" ;;
        enable-flow)    cmd_enable_flow "$@" ;;
        disable-flow)   cmd_disable_flow "$@" ;;
        list-runs)      cmd_list_runs "$@" ;;
        get-run)        cmd_get_run "$@" ;;
        list-pieces)    cmd_list_pieces "$@" ;;
        get-piece)      cmd_get_piece "$@" ;;
        help|--help|-h) cmd_help ;;
        *)
            log_error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
