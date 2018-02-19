# ---------------------------------------------------------------------------------
# A simple REST framework for Bash.
# ---------------------------------------------------------------------------------
# Author: Guigo2k <guigo2k@guigo2k.com>
# Version: 0.3.6
# ---------------------------------------------------------------------------------

declare gnsh_version=0.3.6
declare route_match
declare resp_header
declare resp_status='200 OK'
declare resp_type='application/json'
declare resp_file="$(mktemp /tmp/gnsh.XXXXXXX)"

# http verbs
# ---------------------------------------------------------------------------------

   get() { gnsh_route GET "$1"; }
   put() { gnsh_route PUT "$1"; }
  post() { gnsh_route POST "$1"; }
delete() { gnsh_route DELETE "$1"; }

# http headers
# ---------------------------------------------------------------------------------

status() { resp_status="$1"; }
header() { head="$1: $2"

  if [[ "$resp_header" ]]
  then resp_header="${resp_header}\n${head}"
  else resp_header="$head"
  fi
}

# http header
# ---------------------------------------------------------------------------------

gnsh_header() {
  [[ ! $(echo "$resp_header" | grep 'Status') ]] && header "Status" "$resp_status"
  [[ ! $(echo "$resp_header" | grep 'Content-Type') ]] && header "Content-Type" "$resp_type"
  header "Cache-control" "no-cache"
  header "Connection" "keep-alive"
  header "Date" "$(date -u '+%a, %d %b %Y %R:%S GMT')"
  echo -e "$resp_header\r\n"
}

# http error
# ---------------------------------------------------------------------------------

gnsh_error() {
  local msg
  local code="$1"
  case "$code" in
    401 ) msg="Unauthorized" ;;
    404 ) msg="Not Found" ;;
  esac
  cat <<EOF
{
  "code": $code,
  "message": "$msg"
}
EOF
}

# http auth.
# ---------------------------------------------------------------------------------
gnsh_auth() {
  local http_token="$1"
  local http_auth=$(echo "$HTTP_AUTHORIZATION" | cut -d' ' -f2)
  if [[ "$http_auth" != "$http_token" ]]; then
    route_match="true"
    status 401
    gnsh_error 401
  fi
}

# escape func.
# ---------------------------------------------------------------------------------

gnsh_escape() {
  local path="$1"
  path=$(echo "$path" \
  | sed 's/\./\\./g' \
  | sed 's/+/\+/g' \
  | sed 's/\*/(.*?)/g' \
  | sed -E 's/:(\w*)/(.*?)/g')
  echo "^$path\$"
}

# unescape func.
# ---------------------------------------------------------------------------------

gnsh_unescape() {
  local str="$1"
  str="${str//+/ }"
  str="${str//%/\\x}"
  echo -e "$str"
}

# url params
# ---------------------------------------------------------------------------------

gnsh_params() {
  params=($(echo "$path" | grep -o -e ':\w\+' | cut -d: -f2))
  if [[ -n $params ]]; then
    for ((i = 1; i < ${#BASH_REMATCH[@]}; i++)); do
      export "${params[i - 1]}=$(gnsh_unescape "${BASH_REMATCH[i]}")"
    done
  fi
}

# query string
# ---------------------------------------------------------------------------------

gnsh_query() {
  if [[ -n "$QUERY_STRING" ]]; then
    for var in $(echo "$QUERY_STRING" | tr '&' '\n'); do
      key=$(echo $var | cut -d= -f1)
      val=$(echo $var | cut -d= -f2)
      export "${key}=${val}"
    done
  fi
}

# http data (payload)
# ---------------------------------------------------------------------------------

gnsh_data() {
  if [[ -n "$CONTENT_LENGTH" ]]; then
    read -n "$CONTENT_LENGTH" http_data
	fi
}

# http routes
# ---------------------------------------------------------------------------------

gnsh_route() {
  [[ -n "$route_match" ]] && return -1

  local verb="$1"
  local path="$2"
  local -i i

  if [[ "$REQUEST_METHOD" = "$verb" ]]; then
    if [[ "$PATH_INFO" =~ $(gnsh_escape "$path") ]]; then
    	route_match="true"
      gnsh_params
      gnsh_query
    	gnsh_data
    	return 0
    fi
  fi
  return -1
}

# http reponse
# ---------------------------------------------------------------------------------

gnsh_response() {
  if [[ -n "$route_match" ]]; then
    gnsh_header
    cat "$resp_file"
  else
    status 404
    gnsh_header
    gnsh_error 404
  fi >&5
}

# and... go!
# ---------------------------------------------------------------------------------

trap 'gnsh_response; rm -f $resp_file' EXIT
: > "$resp_file"
exec 5>&1
exec > "$resp_file"
