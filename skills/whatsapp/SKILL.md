---
name: whatsapp
description: Send and read WhatsApp messages. Use when the user wants to send WhatsApp messages, search contacts, list chats, or read message history. Works standalone without MCP.
allowed-tools: Bash
---

# WhatsApp Integration

Send and read WhatsApp messages using the bundled Python script.

## Before Any Operation

**ALWAYS check bridge status first:**

```bash
python3 ~/.claude/skills/whatsapp/scripts/whatsapp.py status
```

If bridge is not running and you need to SEND messages:

```bash
cd ~/Desktop/Dev/Personal/whatsapp-mcp/whatsapp-bridge && go run main.go &
```

Wait 2-3 seconds, then check status again.

**Note:** Reading messages/chats/contacts works WITHOUT the bridge (uses SQLite directly).

## First Time Setup (QR Code)

If the user has never authenticated or session expired (~20 days):

```bash
cd ~/Desktop/Dev/Personal/whatsapp-mcp/whatsapp-bridge && go run main.go
```

This shows a QR code in terminal - user must scan with WhatsApp mobile (Settings > Linked Devices).

## Commands

Use the bundled script for all operations:

```bash
python ~/.claude/skills/whatsapp/scripts/whatsapp.py <command>
```

### Check Status

```bash
python ~/.claude/skills/whatsapp/scripts/whatsapp.py status
```

### List Chats

```bash
python ~/.claude/skills/whatsapp/scripts/whatsapp.py chats
python ~/.claude/skills/whatsapp/scripts/whatsapp.py chats --limit 50
```

### List Messages

```bash
# Recent messages from all chats
python ~/.claude/skills/whatsapp/scripts/whatsapp.py messages

# Messages from specific chat
python ~/.claude/skills/whatsapp/scripts/whatsapp.py messages --chat "Mario"

# Search messages
python ~/.claude/skills/whatsapp/scripts/whatsapp.py messages --search "meeting"
```

### Search Contacts

```bash
python ~/.claude/skills/whatsapp/scripts/whatsapp.py contacts "Mario"
```

### Send Message

```bash
# By name (auto-resolves to JID)
python ~/.claude/skills/whatsapp/scripts/whatsapp.py send "Mario Rossi" "Hello!"

# By phone number
python ~/.claude/skills/whatsapp/scripts/whatsapp.py send "391234567890" "Hello!"

# By JID (for groups use @g.us)
python ~/.claude/skills/whatsapp/scripts/whatsapp.py send "391234567890@s.whatsapp.net" "Hello!"
```

### Send File

```bash
python ~/.claude/skills/whatsapp/scripts/whatsapp.py send-file "Mario" "/path/to/image.jpg"
```

## Workflow Examples

### Send message to a contact

1. Search for contact: `python whatsapp.py contacts "Mario"`
2. Send message: `python whatsapp.py send "Mario Rossi" "Ciao!"`

### Check recent conversations

1. List chats: `python whatsapp.py chats`
2. Read messages: `python whatsapp.py messages --chat "Family Group"`

### Find a specific conversation

1. Search: `python whatsapp.py messages --search "dinner tomorrow"`

## Important Notes

- Bridge must be running for sending messages (reading works offline via SQLite)
- Session expires every ~20 days, requiring new QR scan
- Always verify recipient before sending
- Groups have JIDs ending in `@g.us`
