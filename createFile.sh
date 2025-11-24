#!/usr/bin/env bash

# =========================
# name: ejiwumi
# date: 15th
# version: 2.0.0
# about: DevOps helper to create files from templates,
#        set permissions/owner and optionally open in editor.
# Usage: ./createFile.sh -n name [-t type] [-d dir] [-p perms] [-o owner] [--open] [--force]
# Types: bash, py, md, docker, tf, service, txt
# =====================================


#!/usr/bin/env bash

# =========================
# name: ejiwumi
# date: 15th
# version: 2.0.0
# about: DevOps helper to create files from templates,
#        set permissions/owner and optionally open in editor.
# Usage: ./createFile.sh -n name [-t type] [-d dir] [-p perms] [-o owner] [--open] [--force]
# Types: bash, py, md, docker, tf, service, txt
# =====================================

set -euo pipefail

PROGNAME=$(basename "$0")

usage() {
	cat <<EOF
Usage: $PROGNAME [-n name] [-t type] [-d dir] [-p perms] [-o owner] [--open] [--force] [--help]

Options:
	-n NAME     File name (required in non-interactive mode)
	-t TYPE     Template type: bash, py, md, docker, tf, service, txt (default: txt)
	-d DIR      Directory to create file in (default: current dir)
	-p PERMS    File permissions (e.g. 644, 755). Defaults: bash->755, others->644
	-o OWNER    chown to OWNER (user[:group]) if running as root
	--open      Open the created file in $EDITOR (or vim)
	--force     Overwrite existing file
	--help      Show this help

If no options are provided the script will prompt interactively.
EOF
}

TEMPLATE_TYPE="txt"
DIR="."
PERMS="" # empty means auto
OWNER=""
OPEN=false
FORCE=false
NAME=""

LONG_OPTS=$(cat <<'L'
--open
--force
--help
L
)

# parse args (basic long opts handling)
while [[ $# -gt 0 ]]; do
	case "$1" in
		-n) NAME="$2"; shift 2 ;;
		-t) TEMPLATE_TYPE="$2"; shift 2 ;;
		-d) DIR="$2"; shift 2 ;;
		-p) PERMS="$2"; shift 2 ;;
		-o) OWNER="$2"; shift 2 ;;
		--open) OPEN=true; shift ;;
		--force) FORCE=true; shift ;;
		--help) usage; exit 0 ;;
		--*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
		-*) echo "Unknown short option: $1" >&2; usage; exit 2 ;;
		*)
			if [ -z "$NAME" ]; then
				NAME="$1"
				shift
			else
				echo "Unexpected argument: $1" >&2; usage; exit 2
			fi
			;;
	esac
done

# Interactive fallback if name not provided
if [ -z "$NAME" ]; then
	read -rp "Input the file name: " NAME
fi

if [ -z "$NAME" ]; then
	echo "No file name provided." >&2
	usage
	exit 2
fi

TARGET_DIR="$DIR"
mkdir -p "$TARGET_DIR"

TARGET_PATH="$TARGET_DIR/$NAME"

if [ -e "$TARGET_PATH" ] && [ "$FORCE" != true ]; then
	echo "File '$TARGET_PATH' already exists. Use --force to overwrite." >&2
	exit 3
fi

create_from_template() {
	local path="$1" type="$2"
	case "$type" in
		bash)
			cat > "$path" <<'BASH_TMPL'
#!/usr/bin/env bash
set -euo pipefail
# Author: 
# Description: 

main() {
	echo "Hello from $0"
}

main "$@"
BASH_TMPL
			;;
		py)
			cat > "$path" <<'PY_TMPL'
#!/usr/bin/env python3
"""Simple script."""
import sys

def main(argv):
		print('Hello')

if __name__ == '__main__':
		main(sys.argv[1:])
PY_TMPL
			;;
		md)
			cat > "$path" <<'MD_TMPL'
# $NAME

Description here.
MD_TMPL
			;;
		docker)
			cat > "$path" <<'DOCKER_TMPL'
FROM alpine:latest
RUN apk add --no-cache bash
CMD ["/bin/sh"]
DOCKER_TMPL
			;;
		tf)
			cat > "$path" <<'TF_TMPL'
terraform {
	required_version = ">= 1.0"
}

provider "aws" {
	region = var.region
}
TF_TMPL
			;;
		service)
			cat > "$path" <<'SERVICE_TMPL'
[Unit]
Description=My Service

[Service]
ExecStart=/usr/bin/env bash /path/to/script.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE_TMPL
			;;
		txt|*)
			: > "$path"
			;;
	esac
}

# create the file (overwrite if force)
if [ "$FORCE" = true ] && [ -e "$TARGET_PATH" ]; then
	rm -f "$TARGET_PATH"
fi

create_from_template "$TARGET_PATH" "$TEMPLATE_TYPE"

# decide permissions
if [ -z "$PERMS" ]; then
	if [ "$TEMPLATE_TYPE" = "bash" ]; then
		PERMS=755
	else
		PERMS=644
	fi
fi

chmod "$PERMS" "$TARGET_PATH"

# try chown if requested
if [ -n "$OWNER" ]; then
	if [ "$(id -u)" -eq 0 ]; then
		chown "$OWNER" "$TARGET_PATH"
	else
		echo "Warning: not root - cannot chown. Run as root to change owner." >&2
	fi
fi

echo "Created: $TARGET_PATH (mode: $PERMS)"

if [ "$OPEN" = true ]; then
	: ${EDITOR:=vim}
	"$EDITOR" "$TARGET_PATH"
fi

exit 0
