#!/bin/bash
#
# ActivePieces Flow Builder
# Quick helpers to build common flow patterns
#
# Usage: flow-builder.sh <template> [args]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_SCRIPT="${SCRIPT_DIR}/activepieces-api.sh"

# Source API script functions
source_api() {
    ACTIVEPIECES_URL="${ACTIVEPIECES_URL:-http://localhost:8082}"
    TOKEN_FILE="${HOME}/.activepieces-token"

    get_token() {
        if [[ -f "$TOKEN_FILE" ]]; then
            cat "$TOKEN_FILE"
        else
            "$API_SCRIPT" login > /dev/null
            cat "$TOKEN_FILE"
        fi
    }

    get_project_id() {
        grep -o 'AP_PROJECT_ID=[^[:space:]]*' ~/.activepieces-credentials 2>/dev/null | cut -d= -f2 || \
        curl -s -X POST "${ACTIVEPIECES_URL}/api/v1/authentication/sign-in" \
            -H "Content-Type: application/json" \
            -d '{"email":"alekdobrohotov@gmail.com","password":"0000Oliver!"}' | \
            python3 -c "import json,sys; print(json.load(sys.stdin)['projectId'])"
    }

    api_call() {
        local method="$1" endpoint="$2" data="$3"
        local token=$(get_token)

        if [[ -n "$data" ]]; then
            curl -s -X "$method" "${ACTIVEPIECES_URL}/api/v1${endpoint}" \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json" \
                -d "$data"
        else
            curl -s -X "$method" "${ACTIVEPIECES_URL}/api/v1${endpoint}" \
                -H "Authorization: Bearer $token"
        fi
    }
}

source_api

# Create a scheduled HTTP flow
create_scheduled_http_flow() {
    local name="$1"
    local url="$2"
    local minutes="${3:-5}"
    local method="${4:-GET}"

    echo "Creating scheduled HTTP flow: $name"
    echo "  URL: $url"
    echo "  Every: $minutes minutes"
    echo "  Method: $method"
    echo ""

    local project_id=$(get_project_id)

    # Create flow
    local flow_response=$(api_call POST "/flows" "{\"displayName\":\"$name\",\"projectId\":\"$project_id\"}")
    local flow_id=$(echo "$flow_response" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

    echo "Flow created: $flow_id"

    # Add schedule trigger
    api_call POST "/flows/$flow_id" "{
        \"type\": \"UPDATE_TRIGGER\",
        \"request\": {
            \"displayName\": \"Every $minutes Minutes\",
            \"name\": \"trigger\",
            \"type\": \"PIECE_TRIGGER\",
            \"valid\": true,
            \"settings\": {
                \"pieceName\": \"@activepieces/piece-schedule\",
                \"pieceVersion\": \"0.1.14\",
                \"triggerName\": \"every_x_minutes\",
                \"input\": { \"minutes\": $minutes },
                \"inputUiInfo\": {},
                \"propertySettings\": {}
            }
        }
    }" > /dev/null

    echo "Trigger added"

    # Add HTTP action
    api_call POST "/flows/$flow_id" "{
        \"type\": \"ADD_ACTION\",
        \"request\": {
            \"parentStep\": \"trigger\",
            \"action\": {
                \"name\": \"http_request\",
                \"type\": \"PIECE\",
                \"displayName\": \"HTTP $method\",
                \"valid\": true,
                \"settings\": {
                    \"pieceName\": \"@activepieces/piece-http\",
                    \"pieceVersion\": \"0.11.2\",
                    \"actionName\": \"send_request\",
                    \"input\": {
                        \"method\": \"$method\",
                        \"url\": \"$url\",
                        \"headers\": {},
                        \"queryParams\": {},
                        \"authType\": \"NONE\",
                        \"body_type\": \"none\",
                        \"failureMode\": \"retry_none\",
                        \"followRedirects\": true,
                        \"response_is_binary\": false
                    },
                    \"inputUiInfo\": {},
                    \"propertySettings\": {}
                }
            }
        }
    }" > /dev/null

    echo "HTTP action added"

    # Publish and enable
    api_call POST "/flows/$flow_id" '{"type":"LOCK_AND_PUBLISH","request":{}}' > /dev/null
    sleep 1
    api_call POST "/flows/$flow_id" '{"type":"CHANGE_STATUS","request":{"status":"ENABLED"}}' > /dev/null

    echo ""
    echo "✅ Flow created and enabled!"
    echo "   ID: $flow_id"
    echo "   View: ${ACTIVEPIECES_URL}/flows/$flow_id"
}

# Create a webhook-triggered flow
create_webhook_flow() {
    local name="$1"
    local callback_url="${2:-http://host.docker.internal:9999}"

    echo "Creating webhook flow: $name"
    echo "  Callback: $callback_url"
    echo ""

    local project_id=$(get_project_id)

    # Create flow
    local flow_response=$(api_call POST "/flows" "{\"displayName\":\"$name\",\"projectId\":\"$project_id\"}")
    local flow_id=$(echo "$flow_response" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

    # Add webhook trigger
    api_call POST "/flows/$flow_id" '{
        "type": "UPDATE_TRIGGER",
        "request": {
            "displayName": "Webhook Trigger",
            "name": "trigger",
            "type": "PIECE_TRIGGER",
            "valid": true,
            "settings": {
                "pieceName": "@activepieces/piece-webhook",
                "pieceVersion": "0.2.0",
                "triggerName": "catch_request",
                "input": {},
                "inputUiInfo": {},
                "propertySettings": {}
            }
        }
    }' > /dev/null

    # Add callback action
    api_call POST "/flows/$flow_id" "{
        \"type\": \"ADD_ACTION\",
        \"request\": {
            \"parentStep\": \"trigger\",
            \"action\": {
                \"name\": \"callback\",
                \"type\": \"PIECE\",
                \"displayName\": \"Send Callback\",
                \"valid\": true,
                \"settings\": {
                    \"pieceName\": \"@activepieces/piece-http\",
                    \"pieceVersion\": \"0.11.2\",
                    \"actionName\": \"send_request\",
                    \"input\": {
                        \"method\": \"POST\",
                        \"url\": \"$callback_url\",
                        \"headers\": {\"Content-Type\": \"application/json\"},
                        \"queryParams\": {},
                        \"authType\": \"NONE\",
                        \"body_type\": \"json\",
                        \"body\": {\"action\": \"notify\", \"message\": \"{{trigger.body}}\"},
                        \"failureMode\": \"continue_all\",
                        \"followRedirects\": true
                    },
                    \"inputUiInfo\": {},
                    \"propertySettings\": {}
                }
            }
        }
    }" > /dev/null

    # Publish and enable
    api_call POST "/flows/$flow_id" '{"type":"LOCK_AND_PUBLISH","request":{}}' > /dev/null
    sleep 1
    local enabled=$(api_call POST "/flows/$flow_id" '{"type":"CHANGE_STATUS","request":{"status":"ENABLED"}}')

    # Get webhook URL
    local webhook_url=$(echo "$enabled" | python3 -c "
import json,sys
d = json.load(sys.stdin)
ts = d.get('triggerSource', {})
wu = ts.get('webhook', {}).get('url', 'N/A')
print(wu)
" 2>/dev/null || echo "Check ActivePieces UI")

    echo ""
    echo "✅ Webhook flow created!"
    echo "   ID: $flow_id"
    echo "   Webhook URL: $webhook_url"
}

# Create flow with notification
create_notifier_flow() {
    local name="$1"
    local url="$2"
    local minutes="${3:-5}"

    echo "Creating notifier flow: $name"
    echo "  URL: $url"
    echo "  Interval: $minutes minutes"
    echo "  Will send macOS notification with result"
    echo ""

    local project_id=$(get_project_id)

    # Create flow
    local flow_response=$(api_call POST "/flows" "{\"displayName\":\"$name\",\"projectId\":\"$project_id\"}")
    local flow_id=$(echo "$flow_response" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

    # Add schedule trigger
    api_call POST "/flows/$flow_id" "{
        \"type\": \"UPDATE_TRIGGER\",
        \"request\": {
            \"displayName\": \"Every $minutes Minutes\",
            \"name\": \"trigger\",
            \"type\": \"PIECE_TRIGGER\",
            \"valid\": true,
            \"settings\": {
                \"pieceName\": \"@activepieces/piece-schedule\",
                \"pieceVersion\": \"0.1.14\",
                \"triggerName\": \"every_x_minutes\",
                \"input\": { \"minutes\": $minutes },
                \"inputUiInfo\": {},
                \"propertySettings\": {}
            }
        }
    }" > /dev/null

    # Add HTTP action
    api_call POST "/flows/$flow_id" "{
        \"type\": \"ADD_ACTION\",
        \"request\": {
            \"parentStep\": \"trigger\",
            \"action\": {
                \"name\": \"fetch_data\",
                \"type\": \"PIECE\",
                \"displayName\": \"Fetch Data\",
                \"valid\": true,
                \"settings\": {
                    \"pieceName\": \"@activepieces/piece-http\",
                    \"pieceVersion\": \"0.11.2\",
                    \"actionName\": \"send_request\",
                    \"input\": {
                        \"method\": \"GET\",
                        \"url\": \"$url\",
                        \"headers\": {},
                        \"queryParams\": {},
                        \"authType\": \"NONE\",
                        \"body_type\": \"none\",
                        \"failureMode\": \"continue_all\",
                        \"followRedirects\": true
                    },
                    \"inputUiInfo\": {},
                    \"propertySettings\": {}
                }
            }
        }
    }" > /dev/null

    # Add notification action
    api_call POST "/flows/$flow_id" '{
        "type": "ADD_ACTION",
        "request": {
            "parentStep": "fetch_data",
            "action": {
                "name": "notify",
                "type": "PIECE",
                "displayName": "Send Notification",
                "valid": true,
                "settings": {
                    "pieceName": "@activepieces/piece-http",
                    "pieceVersion": "0.11.2",
                    "actionName": "send_request",
                    "input": {
                        "method": "POST",
                        "url": "http://host.docker.internal:9999",
                        "headers": {"Content-Type": "application/json"},
                        "queryParams": {},
                        "authType": "NONE",
                        "body_type": "json",
                        "body": {"action": "notify", "message": "{{fetch_data.body}}", "title": "'"$name"'"},
                        "failureMode": "continue_all",
                        "followRedirects": true
                    },
                    "inputUiInfo": {},
                    "propertySettings": {}
                }
            }
        }
    }' > /dev/null

    # Publish and enable
    api_call POST "/flows/$flow_id" '{"type":"LOCK_AND_PUBLISH","request":{}}' > /dev/null
    sleep 1
    api_call POST "/flows/$flow_id" '{"type":"CHANGE_STATUS","request":{"status":"ENABLED"}}' > /dev/null

    echo ""
    echo "✅ Notifier flow created!"
    echo "   ID: $flow_id"
    echo "   ⚠️  Make sure webhook-server.py is running on port 9999"
}

# Help
show_help() {
    cat << 'EOF'
ActivePieces Flow Builder

Usage: flow-builder.sh <template> [arguments]

Templates:

  scheduled-http <name> <url> [minutes] [method]
    Create a flow that calls a URL on schedule
    Example: flow-builder.sh scheduled-http "Weather Check" "https://wttr.in/Rome?format=3" 5 GET

  webhook <name> [callback_url]
    Create a webhook-triggered flow
    Example: flow-builder.sh webhook "GitHub Handler" "http://host.docker.internal:9999"

  notifier <name> <url> [minutes]
    Create a scheduled flow that fetches data and sends macOS notification
    Example: flow-builder.sh notifier "Stock Alert" "https://api.example.com/stocks" 10

  help
    Show this help message

Note: Webhook server must be running for notifications:
  python3 ~/.claude/skills/activepieces-orchestrator/scripts/webhook-server.py &
EOF
}

# Main
main() {
    local template="${1:-help}"
    shift || true

    case "$template" in
        scheduled-http)
            if [[ -z "$1" ]] || [[ -z "$2" ]]; then
                echo "Usage: flow-builder.sh scheduled-http <name> <url> [minutes] [method]"
                exit 1
            fi
            create_scheduled_http_flow "$@"
            ;;
        webhook)
            if [[ -z "$1" ]]; then
                echo "Usage: flow-builder.sh webhook <name> [callback_url]"
                exit 1
            fi
            create_webhook_flow "$@"
            ;;
        notifier)
            if [[ -z "$1" ]] || [[ -z "$2" ]]; then
                echo "Usage: flow-builder.sh notifier <name> <url> [minutes]"
                exit 1
            fi
            create_notifier_flow "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown template: $template"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
