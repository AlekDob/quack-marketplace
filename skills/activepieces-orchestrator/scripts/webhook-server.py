#!/usr/bin/env python3
"""
Local Webhook Server for ActivePieces Integration

This server receives HTTP requests from ActivePieces (running in Docker)
and can trigger local actions like macOS notifications.

Usage:
    python3 webhook-server.py [port]

Default port: 9999

ActivePieces URL (from Docker):
    http://host.docker.internal:9999
"""

import json
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime


class WebhookHandler(BaseHTTPRequestHandler):
    """Handle incoming webhook requests"""

    def do_POST(self):
        """Handle POST requests"""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')

        # Debug: log raw body
        print(f"[DEBUG] Raw body received ({len(body)} bytes): {body[:500]}", flush=True)

        try:
            data = json.loads(body) if body else {}
            is_json = True
        except (json.JSONDecodeError, ValueError):
            # Body is plain text, not JSON - treat as notification message
            is_json = False
            data = {}

        if not is_json and body.strip():
            # Plain text body = direct notification with the text content
            message = body.strip()
            action = 'notify'
            data = {'title': 'Email AI Analysis', 'message': message}
        else:
            # JSON body - extract fields
            raw_message = data.get('message', data.get('text', data.get('raw', 'Webhook received')))
            if isinstance(raw_message, dict):
                message = raw_message.get('result', raw_message.get('text', raw_message.get('content', json.dumps(raw_message))))
            elif isinstance(raw_message, str):
                message = raw_message if raw_message.strip() else 'No message content'
            else:
                message = str(raw_message) if raw_message else 'No message content'
            action = data.get('action', 'notify')

        # Log the request
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] {action.upper()}: {message[:100]}")

        # Handle different actions
        result = self.handle_action(action, message, data)

        # Send response
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(result).encode())

    def do_GET(self):
        """Health check endpoint"""
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

        response = {
            'status': 'running',
            'service': 'ActivePieces Webhook Server',
            'timestamp': datetime.now().isoformat()
        }
        self.wfile.write(json.dumps(response).encode())

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def handle_action(self, action: str, message: str, data: dict) -> dict:
        """Handle different webhook actions"""
        actions = {
            'notify': self.action_notify,
            'notification': self.action_notify,
            'sound': self.action_sound,
            'say': self.action_say,
            'log': self.action_log,
            'execute': self.action_execute,
        }

        handler = actions.get(action, self.action_notify)
        return handler(message, data)

    def action_notify(self, message: str, data: dict) -> dict:
        """Send macOS notification"""
        title = data.get('title', 'ActivePieces')
        sound = data.get('sound', 'Glass')

        # Clean message for AppleScript
        clean_msg = message.replace('"', "'").replace('\\', '').replace('\n', ' ')
        clean_title = title.replace('"', "'")

        script = f'display notification "{clean_msg}" with title "{clean_title}" sound name "{sound}"'

        try:
            subprocess.run(['osascript', '-e', script], check=True, capture_output=True)
            return {'success': True, 'action': 'notify', 'message': message}
        except subprocess.CalledProcessError as e:
            return {'success': False, 'error': str(e)}

    def action_sound(self, message: str, data: dict) -> dict:
        """Play a sound"""
        sound = data.get('sound', 'Glass')
        script = f'do shell script "afplay /System/Library/Sounds/{sound}.aiff"'

        try:
            subprocess.run(['osascript', '-e', script], check=True, capture_output=True)
            return {'success': True, 'action': 'sound', 'sound': sound}
        except subprocess.CalledProcessError:
            # Try alternative
            subprocess.run(['afplay', f'/System/Library/Sounds/{sound}.aiff'], capture_output=True)
            return {'success': True, 'action': 'sound', 'sound': sound}

    def action_say(self, message: str, data: dict) -> dict:
        """Speak text using macOS TTS"""
        voice = data.get('voice', 'Samantha')
        clean_msg = message.replace('"', "'")

        try:
            subprocess.run(['say', '-v', voice, clean_msg], check=True, capture_output=True)
            return {'success': True, 'action': 'say', 'message': message}
        except subprocess.CalledProcessError as e:
            return {'success': False, 'error': str(e)}

    def action_log(self, message: str, data: dict) -> dict:
        """Just log the message (for debugging)"""
        print(f"LOG: {json.dumps(data, indent=2)}")
        return {'success': True, 'action': 'log', 'message': message}

    def action_execute(self, message: str, data: dict) -> dict:
        """Execute a shell command (use with caution!)"""
        command = data.get('command', '')
        if not command:
            return {'success': False, 'error': 'No command provided'}

        # Security: Only allow specific commands
        allowed_prefixes = ['open ', 'say ', 'afplay ', 'osascript ']
        if not any(command.startswith(p) for p in allowed_prefixes):
            return {'success': False, 'error': 'Command not allowed'}

        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=30)
            return {
                'success': result.returncode == 0,
                'action': 'execute',
                'stdout': result.stdout,
                'stderr': result.stderr
            }
        except subprocess.TimeoutExpired:
            return {'success': False, 'error': 'Command timed out'}
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def log_message(self, format, *args):
        """Suppress default request logging"""
        pass


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 9999

    server = HTTPServer(('0.0.0.0', port), WebhookHandler)

    print(f"""
╔════════════════════════════════════════════════════════════╗
║  ActivePieces Local Webhook Server                         ║
╠════════════════════════════════════════════════════════════╣
║  Local URL:  http://localhost:{port:<24}       ║
║  Docker URL: http://host.docker.internal:{port:<14}       ║
╠════════════════════════════════════════════════════════════╣
║  Actions:                                                  ║
║    notify  - Send macOS notification                       ║
║    sound   - Play system sound                             ║
║    say     - Text-to-speech                                ║
║    log     - Log to console                                ║
║    execute - Run allowed commands                          ║
╠════════════════════════════════════════════════════════════╣
║  Example POST body:                                        ║
║    {{"action": "notify", "message": "Hello!", "title": "AP"}} ║
╚════════════════════════════════════════════════════════════╝
""")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()


if __name__ == '__main__':
    main()
