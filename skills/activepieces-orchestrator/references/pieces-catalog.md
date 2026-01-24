# ActivePieces Pieces Catalog

Quick reference for the most useful pieces (integrations) in ActivePieces.

## Core Pieces

### Schedule (`@activepieces/piece-schedule`)

| Trigger | Description |
|---------|-------------|
| `every_x_minutes` | Run every N minutes (1-59) |
| `every_hour` | Run every hour |
| `every_day` | Run daily at specific hour |
| `every_week` | Run weekly on specific day |
| `cron_expression` | Custom cron schedule |

### HTTP (`@activepieces/piece-http`)

| Action | Description |
|--------|-------------|
| `send_request` | Make HTTP request (GET, POST, PUT, DELETE, PATCH) |

**Input Schema:**
```json
{
  "method": "GET|POST|PUT|DELETE|PATCH|HEAD",
  "url": "https://...",
  "headers": {},
  "queryParams": {},
  "authType": "NONE|BASIC|BEARER_TOKEN",
  "body_type": "none|json|form_data|raw",
  "body": {},
  "timeout": 30,
  "followRedirects": true,
  "failureMode": "retry_none|retry_all|retry_5xx|continue_all"
}
```

### Webhook (`@activepieces/piece-webhook`)

| Trigger | Description |
|---------|-------------|
| `catch_request` | Catch incoming HTTP requests |

### Code (`@activepieces/piece-code`)

| Action | Description |
|--------|-------------|
| `run_javascript` | Execute JavaScript code |
| `run_typescript` | Execute TypeScript code |

**Example:**
```javascript
export const code = async (inputs) => {
  const { data } = inputs;
  return {
    processed: data.map(item => item.toUpperCase()),
    count: data.length
  };
};
```

## Communication

### Gmail (`@activepieces/piece-gmail`)

| Trigger | Description |
|---------|-------------|
| `new_email` | Trigger on new email |

| Action | Description |
|--------|-------------|
| `send_email` | Send an email |
| `get_thread` | Get email thread |

### Slack (`@activepieces/piece-slack`)

| Trigger | Description |
|---------|-------------|
| `new_message` | New message in channel |

| Action | Description |
|--------|-------------|
| `send_message` | Send message to channel |
| `send_direct_message` | Send DM to user |

### Discord (`@activepieces/piece-discord`)

| Action | Description |
|--------|-------------|
| `send_message_webhook` | Send via webhook |
| `send_approval_request` | Interactive approval |

### Telegram (`@activepieces/piece-telegram-bot`)

| Trigger | Description |
|---------|-------------|
| `new_message` | New message to bot |

| Action | Description |
|--------|-------------|
| `send_text_message` | Send text message |
| `send_photo` | Send photo |

## AI & ML

### OpenAI (`@activepieces/piece-openai`)

| Action | Description |
|--------|-------------|
| `ask_chatgpt` | Chat completion |
| `text_to_image` | Generate image (DALL-E) |
| `transcribe_audio` | Whisper transcription |
| `generate_embeddings` | Text embeddings |

### Anthropic (`@activepieces/piece-anthropic`)

| Action | Description |
|--------|-------------|
| `ask_claude` | Chat with Claude |

### Google AI (`@activepieces/piece-google-gemini`)

| Action | Description |
|--------|-------------|
| `generate_content` | Gemini chat |
| `generate_image` | Image generation |

## Databases

### PostgreSQL (`@activepieces/piece-postgres`)

| Action | Description |
|--------|-------------|
| `run_query` | Execute SQL query |
| `insert_row` | Insert single row |
| `update_row` | Update rows |
| `delete_row` | Delete rows |

### MySQL (`@activepieces/piece-mysql`)

Similar to PostgreSQL actions.

### MongoDB (`@activepieces/piece-mongodb`)

| Action | Description |
|--------|-------------|
| `find_documents` | Query documents |
| `insert_document` | Insert document |
| `update_document` | Update document |

### Supabase (`@activepieces/piece-supabase`)

| Action | Description |
|--------|-------------|
| `new_row` (trigger) | New row inserted |
| `insert_row` | Insert row |
| `get_rows` | Fetch rows |
| `update_row` | Update row |

## Storage

### Google Drive (`@activepieces/piece-google-drive`)

| Trigger | Description |
|---------|-------------|
| `new_file` | New file in folder |

| Action | Description |
|--------|-------------|
| `create_file` | Create/upload file |
| `read_file` | Read file content |

### Dropbox (`@activepieces/piece-dropbox`)

| Action | Description |
|--------|-------------|
| `upload_file` | Upload file |
| `download_file` | Download file |
| `create_folder` | Create folder |

### AWS S3 (`@activepieces/piece-aws-s3`)

| Action | Description |
|--------|-------------|
| `upload_file` | Upload to bucket |
| `download_file` | Download from bucket |
| `list_objects` | List bucket objects |

## Dev Tools

### GitHub (`@activepieces/piece-github`)

| Trigger | Description |
|---------|-------------|
| `new_issue` | New issue created |
| `new_pull_request` | New PR created |
| `new_star` | Repository starred |

| Action | Description |
|--------|-------------|
| `create_issue` | Create issue |
| `create_comment` | Comment on issue |

### GitLab (`@activepieces/piece-gitlab`)

Similar to GitHub actions.

### Linear (`@activepieces/piece-linear`)

| Trigger | Description |
|---------|-------------|
| `issue_created` | New issue |
| `issue_updated` | Issue updated |

| Action | Description |
|--------|-------------|
| `create_issue` | Create issue |
| `update_issue` | Update issue |

### Notion (`@activepieces/piece-notion`)

| Trigger | Description |
|---------|-------------|
| `new_database_item` | New database item |
| `updated_database_item` | Item updated |

| Action | Description |
|--------|-------------|
| `create_database_item` | Add to database |
| `update_database_item` | Update item |
| `append_to_page` | Append content |

## CRM & Marketing

### HubSpot (`@activepieces/piece-hubspot`)

| Trigger | Description |
|---------|-------------|
| `new_contact` | New contact created |
| `new_deal` | New deal created |

| Action | Description |
|--------|-------------|
| `create_contact` | Create contact |
| `update_contact` | Update contact |
| `create_deal` | Create deal |

### Mailchimp (`@activepieces/piece-mailchimp`)

| Action | Description |
|--------|-------------|
| `add_subscriber` | Add to list |
| `update_subscriber` | Update subscriber |
| `send_campaign` | Send email campaign |

## Utility

### Data Mapper (`@activepieces/piece-data-mapper`)

| Action | Description |
|--------|-------------|
| `advanced_mapping` | Transform data structure |

### Text Helper (`@activepieces/piece-text-helper`)

| Action | Description |
|--------|-------------|
| `find_and_replace` | Find/replace in text |
| `split` | Split text by delimiter |
| `markdown_to_html` | Convert markdown |

### Date Helper (`@activepieces/piece-date-helper`)

| Action | Description |
|--------|-------------|
| `get_current_date` | Current timestamp |
| `date_difference` | Calculate difference |
| `format_date` | Format date string |

### Loops (`@activepieces/piece-loops`)

| Action | Description |
|--------|-------------|
| `loop_on_items` | Iterate over array |

### Branching (`@activepieces/piece-branching`)

| Action | Description |
|--------|-------------|
| `branch` | Conditional branching |

## RSS & Web

### RSS (`@activepieces/piece-rss`)

| Trigger | Description |
|---------|-------------|
| `new_item_in_feed` | New RSS item |

### Web Scraper (`@activepieces/piece-web-scraper`)

| Action | Description |
|--------|-------------|
| `get_page_content` | Scrape webpage |

## Payment

### Stripe (`@activepieces/piece-stripe`)

| Trigger | Description |
|---------|-------------|
| `new_payment` | New payment received |
| `new_customer` | New customer |

| Action | Description |
|--------|-------------|
| `create_customer` | Create customer |
| `create_invoice` | Create invoice |

## Forms

### Typeform (`@activepieces/piece-typeform`)

| Trigger | Description |
|---------|-------------|
| `new_submission` | Form submitted |

### Google Forms (`@activepieces/piece-google-forms`)

| Trigger | Description |
|---------|-------------|
| `new_response` | New form response |

---

## Finding Pieces

```bash
# Search for pieces
~/.claude/skills/activepieces-orchestrator/scripts/activepieces-api.sh list-pieces gmail

# Get piece details (actions, triggers, auth)
~/.claude/skills/activepieces-orchestrator/scripts/activepieces-api.sh get-piece @activepieces/piece-http
```

## Full Pieces Directory

Browse all 280+ pieces: https://www.activepieces.com/pieces
