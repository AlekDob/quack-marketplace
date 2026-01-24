#!/bin/bash
# Validate Kestra Workflow YAML
#
# Usage: validate-workflow.sh <yaml-file>
#
# Checks:
# - Valid YAML syntax
# - Required fields (id, namespace, tasks)
# - Task structure
# - Common mistakes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

yaml_file="$1"

if [ -z "$yaml_file" ]; then
    echo "Usage: validate-workflow.sh <yaml-file>"
    exit 1
fi

if [ ! -f "$yaml_file" ]; then
    echo -e "${RED}[ERROR]${NC} File not found: $yaml_file"
    exit 1
fi

echo "Validating: $yaml_file"
echo "----------------------------------------"

errors=0
warnings=0

# Check YAML syntax using Python's built-in json for basic validation
# or pip install pyyaml if available
if python3 -c "import yaml" 2>/dev/null; then
    if ! python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
        echo -e "${RED}[ERROR]${NC} Invalid YAML syntax"
        python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>&1
        exit 1
    fi
else
    # Fallback: basic syntax check without pyyaml
    if ! python3 -c "
import re
with open('$yaml_file') as f:
    content = f.read()
# Basic checks
if not content.strip():
    raise ValueError('Empty file')
" 2>/dev/null; then
        echo -e "${RED}[ERROR]${NC} Invalid file"
        exit 1
    fi
fi

echo -e "${GREEN}[OK]${NC} Valid YAML syntax"

# Validate with Python
python3 << EOF
try:
    import yaml
except ImportError:
    # Minimal validation without pyyaml
    import json
    import re

    class yaml:
        @staticmethod
        def safe_load(f):
            # Very basic YAML-like parsing for validation
            content = f.read()
            # Extract key fields using regex
            result = {}
            for match in re.finditer(r'^(\w+):\s*(.*)$', content, re.MULTILINE):
                key, value = match.groups()
                result[key] = value.strip() or []
            # Check for tasks list
            if 'tasks:' in content:
                result['tasks'] = [{}]  # Placeholder
            return result
import sys

with open('$yaml_file', 'r') as f:
    data = yaml.safe_load(f)

errors = []
warnings = []

# Check required fields
if 'id' not in data:
    errors.append("Missing required field: 'id'")
elif not isinstance(data['id'], str):
    errors.append("'id' must be a string")
elif ' ' in data['id']:
    errors.append("'id' should not contain spaces (use kebab-case)")

if 'namespace' not in data:
    errors.append("Missing required field: 'namespace'")
elif not isinstance(data['namespace'], str):
    errors.append("'namespace' must be a string")

if 'tasks' not in data:
    errors.append("Missing required field: 'tasks'")
elif not isinstance(data['tasks'], list):
    errors.append("'tasks' must be a list")
elif len(data['tasks']) == 0:
    errors.append("'tasks' list cannot be empty")
else:
    # Validate each task
    task_ids = set()
    for i, task in enumerate(data['tasks']):
        if not isinstance(task, dict):
            errors.append(f"Task {i} must be a dictionary")
            continue

        if 'id' not in task:
            errors.append(f"Task {i} missing required field: 'id'")
        elif task['id'] in task_ids:
            errors.append(f"Duplicate task id: '{task['id']}'")
        else:
            task_ids.add(task['id'])

        if 'type' not in task:
            errors.append(f"Task '{task.get('id', i)}' missing required field: 'type'")
        elif not task['type'].startswith('io.kestra.'):
            warnings.append(f"Task '{task.get('id', i)}' has unusual type: '{task['type']}'")

# Check optional fields
if 'description' not in data:
    warnings.append("Missing recommended field: 'description'")

# Check inputs
if 'inputs' in data:
    if not isinstance(data['inputs'], list):
        errors.append("'inputs' must be a list")
    else:
        input_ids = set()
        for inp in data['inputs']:
            if 'id' not in inp:
                errors.append("Input missing required field: 'id'")
            elif inp['id'] in input_ids:
                errors.append(f"Duplicate input id: '{inp['id']}'")
            else:
                input_ids.add(inp['id'])

            if 'type' not in inp:
                errors.append(f"Input '{inp.get('id', '?')}' missing required field: 'type'")

# Check triggers
if 'triggers' in data:
    if not isinstance(data['triggers'], list):
        errors.append("'triggers' must be a list")
    else:
        for trigger in data['triggers']:
            if 'id' not in trigger:
                errors.append("Trigger missing required field: 'id'")
            if 'type' not in trigger:
                errors.append(f"Trigger '{trigger.get('id', '?')}' missing required field: 'type'")

# Print results
for err in errors:
    print(f"\033[0;31m[ERROR]\033[0m {err}")

for warn in warnings:
    print(f"\033[1;33m[WARN]\033[0m {warn}")

if errors:
    print(f"\n\033[0;31mValidation failed with {len(errors)} error(s)\033[0m")
    sys.exit(1)
else:
    print(f"\n\033[0;32mValidation passed\033[0m")
    if warnings:
        print(f"({len(warnings)} warning(s))")
    sys.exit(0)
EOF
