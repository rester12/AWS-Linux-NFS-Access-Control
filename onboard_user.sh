#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: sudo $0 <username> <developer|auditor|app>" >&2
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script with sudo or as root." >&2
  exit 1
fi

username="$1"
role="$2"

if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Invalid Linux username: $username" >&2
  exit 1
fi

case "$role" in
  developer|app)
    group="developers"
    ;;
  auditor)
    group="auditors"
    ;;
  *)
    echo "Invalid role: $role" >&2
    usage
    ;;
esac

getent group "$group" >/dev/null || groupadd "$group"

if id "$username" >/dev/null 2>&1; then
  echo "User already exists: $username" >&2
  exit 1
fi

useradd --create-home --shell /bin/bash "$username"
usermod --append --groups "$group" "$username"

cat >"/home/$username/WELCOME.txt" <<EOF
Account: $username
Role: $role
Primary project group: $group
EOF

chown "$username:$username" "/home/$username/WELCOME.txt"
chmod 0640 "/home/$username/WELCOME.txt"

if [[ "$role" == "auditor" && -d /srv/appdata/logs ]]; then
  setfacl -m "u:$username:rx" /srv/appdata/logs
fi

echo "Created $username with role $role and group $group."

