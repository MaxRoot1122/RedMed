#!/bin/bash
# Shared localhost server for RedMed — GPS needs a secure context (not file://).
# Sourced by RedMed.app and RedMed.command; logs to ~/Library/Logs/RedMed/.

REDMED_PORT="${REDMED_PORT:-8934}"
REDMED_HOST="${REDMED_HOST:-127.0.0.1}"
REDMED_LOG_DIR="${HOME}/Library/Logs/RedMed"
REDMED_LOG_FILE="${REDMED_LOG_DIR}/server.log"
REDMED_PID_FILE="${REDMED_LOG_DIR}/server.pid"
REDMED_URL="http://${REDMED_HOST}:${REDMED_PORT}/index.html"

_redmed_init_log() {
  if mkdir -p "$REDMED_LOG_DIR" 2>/dev/null; then
    return 0
  fi
  # Sandbox or locked home — fall back so errors are still captured somewhere.
  REDMED_LOG_DIR="${TMPDIR:-/tmp}/RedMed"
  REDMED_LOG_FILE="${REDMED_LOG_DIR}/server.log"
  REDMED_PID_FILE="${REDMED_LOG_DIR}/server.pid"
  mkdir -p "$REDMED_LOG_DIR" 2>/dev/null || true
}

_redmed_log() {
  _redmed_init_log
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$REDMED_LOG_FILE" 2>/dev/null || true
}

_redmed_alert() {
  local msg="$1"
  _redmed_log "ALERT: $msg"
  osascript -e "display alert \"RedMed\" message \"${msg}\" as critical" 2>/dev/null || true
}

_redmed_find_python() {
  if command -v python3 >/dev/null 2>&1; then
    command -v python3
    return 0
  fi
  for candidate in /usr/bin/python3 /opt/homebrew/bin/python3 /usr/local/bin/python3; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

_redmed_server_up() {
  curl -s -o /dev/null --max-time 1 "http://${REDMED_HOST}:${REDMED_PORT}/"
}

_redmed_port_blocked() {
  lsof -nP -iTCP:"${REDMED_PORT}" -sTCP:LISTEN >/dev/null 2>&1
}

# Start (or confirm) python http.server serving WWW; exit 0 only when index.html responds.
redmed_ensure_server() {
  local www="$1"

  if [ ! -d "$www" ]; then
    _redmed_alert "Web folder not found: ${www}"
    return 1
  fi
  if [ ! -f "${www}/index.html" ]; then
    _redmed_alert "index.html missing in ${www}"
    return 1
  fi

  if _redmed_server_up; then
    _redmed_log "Server already responding on ${REDMED_HOST}:${REDMED_PORT}"
    return 0
  fi

  if _redmed_port_blocked; then
    _redmed_alert "Port ${REDMED_PORT} is in use by another app. Quit it or change REDMED_PORT."
    return 1
  fi

  local py
  py="$(_redmed_find_python)" || {
    _redmed_alert "Python 3 not found. Install Xcode Command Line Tools (xcode-select --install)."
    return 1
  }

  _redmed_log "Starting server: ${py} -m http.server ${REDMED_PORT} in ${www}"
  (
    cd "$www" || exit 1
    nohup "$py" -m http.server "$REDMED_PORT" --bind "$REDMED_HOST" >> "$REDMED_LOG_FILE" 2>&1 &
    echo $! > "$REDMED_PID_FILE"
  )

  local attempt=0
  while [ "$attempt" -lt 80 ]; do
    if _redmed_server_up; then
      _redmed_log "Server ready on ${REDMED_URL}"
      return 0
    fi
    sleep 0.1
    attempt=$((attempt + 1))
  done

  _redmed_alert "RedMed server did not start. See ${REDMED_LOG_FILE}"
  return 1
}

redmed_open_browser() {
  local url="${1:-$REDMED_URL}"
  if [ -d "/Applications/Google Chrome.app" ]; then
    open -na "Google Chrome" --args --app="$url" --new-window
  elif [ -d "/Applications/Microsoft Edge.app" ]; then
    open -na "Microsoft Edge" --args --app="$url" --new-window
  elif [ -d "/Applications/Safari.app" ]; then
    open -a Safari "$url"
  else
    open "$url"
  fi
}

redmed_launch() {
  local www="$1"
  redmed_ensure_server "$www" || return 1
  redmed_open_browser "$REDMED_URL"
}
