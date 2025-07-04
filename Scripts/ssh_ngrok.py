import requests
import subprocess
from datetime import datetime
import argparse
import os
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('--user', help='SSH username', required=False)
parser.add_argument('command', help='Command to execute remotely', nargs='?', default='')
args = parser.parse_args()

def get_ngrok_token():
    config_path = "~/.config/ngrok/ngrok.yml"
    with open(os.path.expanduser(config_path), 'r') as f:
        config = yaml.safe_load(f)
        return config.get("agent").get('authtoken')

API_KEY = get_ngrok_token()

response = requests.get(
    "https://api.ngrok.com/endpoints",
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Ngrok-Version": "2"
    }
)
assert response.status_code == 200
response = response.json()

newest = max(
    response['endpoints'],
    key=lambda x: datetime.fromisoformat(x['created_at'].replace('Z', '+00:00'))
)

host, port = newest['hostport'].split(':')

ssh_cmd = ['ssh']
if args.user:
    ssh_cmd.extend(['-A', f'{args.user}@{host}', '-p', port])
else:
    ssh_cmd.extend(['-A', host, '-p', port])

if args.command:
    ssh_cmd.append(args.command)

subprocess.run(ssh_cmd)
