#!/usr/bin/env python3
"""WhatsApp CLI - Direct interface to WhatsApp Bridge REST API."""

import argparse
import json
import sqlite3
import sys
from datetime import datetime
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError

# Configuration
BRIDGE_URL = "http://localhost:8080"
STORE_PATH = Path.home() / "Desktop/Dev/Personal/whatsapp-mcp/whatsapp-bridge/store"
MESSAGES_DB = STORE_PATH / "messages.db"


def api_request(endpoint: str, data: dict = None) -> dict:
    """Make a request to the WhatsApp bridge API."""
    url = f"{BRIDGE_URL}{endpoint}"
    try:
        if data:
            req = Request(url, data=json.dumps(data).encode(),
                         headers={"Content-Type": "application/json"})
        else:
            req = Request(url)
        with urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode())
    except URLError as e:
        return {"success": False, "message": f"Bridge not running: {e}"}


def query_db(sql: str, params: tuple = ()) -> list:
    """Query the messages database."""
    if not MESSAGES_DB.exists():
        print(f"Database not found: {MESSAGES_DB}", file=sys.stderr)
        return []
    conn = sqlite3.connect(str(MESSAGES_DB))
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute(sql, params)
    rows = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return rows


def cmd_status(args):
    """Check if WhatsApp bridge is running."""
    try:
        urlopen(f"{BRIDGE_URL}/api/send", timeout=2)
    except URLError as e:
        if "405" in str(e):  # Method not allowed = server is up
            print("WhatsApp bridge is RUNNING")
            return
        print(f"WhatsApp bridge is NOT RUNNING")
        print(f"\nTo start it:")
        print(f"  cd {STORE_PATH.parent}")
        print(f"  go run main.go")
        return
    print("WhatsApp bridge is RUNNING")


def cmd_chats(args):
    """List recent chats."""
    limit = args.limit or 20
    rows = query_db("""
        SELECT jid, name, last_message_time
        FROM chats
        ORDER BY last_message_time DESC
        LIMIT ?
    """, (limit,))

    if not rows:
        print("No chats found")
        return

    print(f"{'Name':<30} {'JID':<40} {'Last Active'}")
    print("-" * 90)
    for row in rows:
        name = (row['name'] or 'Unknown')[:28]
        jid = row['jid'][:38]
        last = row['last_message_time'][:19] if row['last_message_time'] else 'Never'
        print(f"{name:<30} {jid:<40} {last}")


def cmd_messages(args):
    """List messages from a chat or search all."""
    limit = args.limit or 20

    if args.chat:
        # Messages from specific chat
        rows = query_db("""
            SELECT sender, content, timestamp, is_from_me, media_type
            FROM messages
            WHERE chat_jid LIKE ?
            ORDER BY timestamp DESC
            LIMIT ?
        """, (f"%{args.chat}%", limit))
    elif args.search:
        # Search in all messages
        rows = query_db("""
            SELECT m.sender, m.content, m.timestamp, m.is_from_me, m.media_type, c.name as chat_name
            FROM messages m
            LEFT JOIN chats c ON m.chat_jid = c.jid
            WHERE m.content LIKE ?
            ORDER BY m.timestamp DESC
            LIMIT ?
        """, (f"%{args.search}%", limit))
    else:
        # Recent messages from all chats
        rows = query_db("""
            SELECT m.sender, m.content, m.timestamp, m.is_from_me, m.media_type, c.name as chat_name
            FROM messages m
            LEFT JOIN chats c ON m.chat_jid = c.jid
            ORDER BY m.timestamp DESC
            LIMIT ?
        """, (limit,))

    if not rows:
        print("No messages found")
        return

    for row in rows:
        direction = "→" if row['is_from_me'] else "←"
        sender = row['sender'][:15] if row['sender'] else 'Me'
        content = row['content'][:60] if row['content'] else f"[{row['media_type']}]"
        ts = row['timestamp'][:16] if row['timestamp'] else ''
        chat = row.get('chat_name', '')[:20] if row.get('chat_name') else ''

        if chat:
            print(f"[{ts}] {chat}: {direction} {sender}: {content}")
        else:
            print(f"[{ts}] {direction} {sender}: {content}")


def cmd_contacts(args):
    """Search contacts."""
    query = args.query
    rows = query_db("""
        SELECT DISTINCT
            CASE WHEN jid LIKE '%@g.us' THEN 'Group' ELSE 'Contact' END as type,
            name,
            jid
        FROM chats
        WHERE name LIKE ? OR jid LIKE ?
        ORDER BY name
        LIMIT 20
    """, (f"%{query}%", f"%{query}%"))

    if not rows:
        print(f"No contacts found matching '{query}'")
        return

    print(f"{'Type':<10} {'Name':<30} {'JID'}")
    print("-" * 80)
    for row in rows:
        print(f"{row['type']:<10} {(row['name'] or 'Unknown'):<30} {row['jid']}")


def cmd_send(args):
    """Send a message."""
    recipient = args.recipient
    message = args.message

    # If recipient doesn't look like a JID, search for it
    if "@" not in recipient:
        rows = query_db("""
            SELECT jid, name FROM chats
            WHERE name LIKE ? OR jid LIKE ?
            LIMIT 5
        """, (f"%{recipient}%", f"%{recipient}%"))

        if not rows:
            print(f"No contact found matching '{recipient}'")
            return

        if len(rows) > 1:
            print(f"Multiple matches for '{recipient}':")
            for i, row in enumerate(rows, 1):
                print(f"  {i}. {row['name']} ({row['jid']})")
            print("\nUse the full JID to send, e.g.:")
            print(f"  python whatsapp.py send '{rows[0]['jid']}' '{message}'")
            return

        recipient = rows[0]['jid']
        print(f"Sending to: {rows[0]['name']} ({recipient})")

    result = api_request("/api/send", {
        "recipient": recipient,
        "message": message
    })

    if result.get("success"):
        print(f"Message sent!")
    else:
        print(f"Failed: {result.get('message', 'Unknown error')}")


def cmd_send_file(args):
    """Send a file."""
    recipient = args.recipient
    file_path = args.file

    if not Path(file_path).exists():
        print(f"File not found: {file_path}")
        return

    result = api_request("/api/send", {
        "recipient": recipient,
        "message": "",
        "media_path": str(Path(file_path).absolute())
    })

    if result.get("success"):
        print(f"File sent!")
    else:
        print(f"Failed: {result.get('message', 'Unknown error')}")


def main():
    parser = argparse.ArgumentParser(description="WhatsApp CLI")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # status
    subparsers.add_parser("status", help="Check if bridge is running")

    # chats
    p = subparsers.add_parser("chats", help="List recent chats")
    p.add_argument("-l", "--limit", type=int, help="Number of chats")

    # messages
    p = subparsers.add_parser("messages", help="List messages")
    p.add_argument("-c", "--chat", help="Filter by chat (name or JID)")
    p.add_argument("-s", "--search", help="Search message content")
    p.add_argument("-l", "--limit", type=int, help="Number of messages")

    # contacts
    p = subparsers.add_parser("contacts", help="Search contacts")
    p.add_argument("query", help="Search query")

    # send
    p = subparsers.add_parser("send", help="Send a message")
    p.add_argument("recipient", help="Phone number, name, or JID")
    p.add_argument("message", help="Message text")

    # send-file
    p = subparsers.add_parser("send-file", help="Send a file")
    p.add_argument("recipient", help="Phone number, name, or JID")
    p.add_argument("file", help="Path to file")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    commands = {
        "status": cmd_status,
        "chats": cmd_chats,
        "messages": cmd_messages,
        "contacts": cmd_contacts,
        "send": cmd_send,
        "send-file": cmd_send_file,
    }

    commands[args.command](args)


if __name__ == "__main__":
    main()
