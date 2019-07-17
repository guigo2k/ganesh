#!/usr/bin/env bash

readonly response_file=$(mktemp)

GET() { _route GET "$1"; }
PUT() { _route PUT "$1"; }
POST() { _route POST "$1"; }
DELETE() { _route DELETE "$1"; }

function _header {
  local status="${1:-200 OK}"
  local type="${2:-application/json}"

  cat <<EOF
Status: $status
Accept: $type
Content-Type: $type
Cache-Control: no-cache
Connection: close

EOF
}

function _error {
  local code="$1"
  local message="$2"

  _header "$code $message"
  cat <<EOF
{
"code": "$code",
"message": "$message"
}
EOF
}

function _escape {
  local path=$(echo "$1" \
    | sed 's/\./\\./g' \
    | sed 's/+/\+/g' \
    | sed 's/\*/(.*?)/g' \
    | sed -E 's/:(\w*)/(.*?)/g')

  echo "^$path\$"
}

function _unescape {
  local string="$1"
  string="${string//+/ }"
  string="${string//%/\\x}"

  echo -e "$string"
}

function _payload {
  if [[ -n "$CONTENT_LENGTH" ]]; then
    read -n "$CONTENT_LENGTH" payload
  fi
}

function _query {
  if [[ -n "$QUERY_STRING" ]]; then
    for key_val in $(echo "$QUERY_STRING" | tr '&' '\n'); do
      export "$key_val"
    done
  fi
}

function _params {
  local params=(`echo "$path" | grep -o -e ':\w\+' | cut -d: -f2`)
  local -i i

  if [[ -n ${params[@]} ]]; then
    for ((i = 1; i < ${#BASH_REMATCH[@]}; i++)); do
      export "${params[i -1]}=$(_unescape "${BASH_REMATCH[i]}")"
    done
  fi
}

function _route {
  [[ -n "$_match" ]] && return 1

  local verb="$1"
  local path="$2"

  if [[ "$REQUEST_METHOD" == "$verb" ]]; then
    if [[ "$PATH_INFO" =~ $(_escape "$path") ]]; then
      _match='true'
      _header
      _query
      _params
      _payload
      return 0
    fi
  fi
  return 1
}

function _response {
  # Restore stdout and close file descriptor
  exec 1>&5 5>&-

  if [[ -n "$_match" ]]; then
    cat "$response_file"
  else
    _error 404 'Not Found'
  fi
}

function http_auth {
  local secret="$1"
  local token="${HTTP_AUTHORIZATION#* }"

  if [[ "$token" != "$secret" ]]; then
    _match='true'
    _error 401 'Unauthorized'
  fi
}

trap '_response; rm -f $response_file' EXIT
exec 5>&1 # Link file descriptor #5 with stdout
exec > "$response_file" # Replace stdout with "response_file"
