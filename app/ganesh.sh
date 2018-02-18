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
declare resp_file="$(mktemp)"

# Header
# ---------------------------------------------------------------------------------

status() { resp_status=$1; }
header() { head="$1: $2"

  if [[ "$resp_header" ]]
  then resp_header="$resp_header\n$head"
  else resp_header="$head"
  fi
}

# Verbs
# ---------------------------------------------------------------------------------

   get() { gnsh_route GET $1; }
   put() { gnsh_route PUT $1; }
  post() { gnsh_route POST $1; }
delete() { gnsh_route DELETE $1; }

# Router
# ---------------------------------------------------------------------------------

gnsh_route() {
  [[ -n "$route_match" ]] && return -1

  local verb="$1"
  local path="$2"
  local -i i

  if [[ "$REQUEST_METHOD" = "$verb" ]]; then
    if [[ "$PATH_INFO" =~ $(gnsh_escape "$path") ]]; then
    	route_match='true'
    	gnsh_data
    	return 0
    fi
  fi
  return -1
}

# Post Data / Query String
# ---------------------------------------------------------------------------------

gnsh_data() {
  groups=($(echo $path | grep -o -e ':\w\+' | cut -d: -f2))

  if [[ -n $groups ]]; then
    for ((i = 1; i < ${#BASH_REMATCH[@]}; i++)); do
      export "${groups[i - 1]}=$(gnsh_unescape "${BASH_REMATCH[i]}")"
    done
  fi

  if [[ -n $QUERY_STRING ]]; then
    for var in $(echo $QUERY_STRING | tr '&' '\n'); do
      key=$(echo $var | cut -d= -f1)
      val=$(echo $var | cut -d= -f2)
      export "${key}=${val}"
    done
  fi

  if [[ -n "$CONTENT_LENGTH" ]]; then
    read -n $CONTENT_LENGTH DATA
	fi
}

# Escape path (for regex match)
# ---------------------------------------------------------------------------------

gnsh_escape() {
  local path=$1
  path=$(echo $path \
  | sed 's/\./\\./g' \
  | sed 's/+/\+/g' \
  | sed 's/\*/(.*?)/g' \
  | sed -E 's/:(\w*)/(.*?)/g')
  echo "^$path\$"
}

# Unescape
# ---------------------------------------------------------------------------------

gnsh_unescape() {
  local str=$1
  str=${str//+/ }
  str=${str//%/\\x}
  echo -e "$str"
}

# Headers
# ---------------------------------------------------------------------------------

gnsh_header() {
  [[ ! $(echo $resp_header | grep 'Status') ]] && header 'Status' "$resp_status"
  [[ ! $(echo $resp_header | grep 'Content-Type') ]] && header 'Content-Type' "$resp_type"

  header 'Cache-control' 'no-cache'
  header 'Connection' 'keep-alive'
  header 'Content-Length' "$(cat $resp_file | wc -c)"
  header 'Date' "$(date -u '+%a, %d %b %Y %R:%S GMT')"

  echo -e "$resp_header\r\n"
}

# Auth.
# ---------------------------------------------------------------------------------
gnsh_auth() {
  http_auth=$(echo $HTTP_AUTHORIZATION | cut -d' ' -f2)
  if [[ "$http_auth" != "$token" ]]; then
    gnsh_error '401'
  fi
}

# Error
# ---------------------------------------------------------------------------------

gnsh_error() {
  local code=$1
  case $code in
    401 ) local msg="Unauthorized" ;;
    404 ) local msg="Not Found" ;;
  esac

  status $code
  gnsh_header
  cat <<EOF
{
  "code": $code,
  "message": "$msg"
}
EOF
}

# Reponse
# ---------------------------------------------------------------------------------

gnsh_response() {
  [[ -n "$token" ]] && gnsh_auth
  if [[ -n "$route_match" ]]; then
    gnsh_header
    cat $resp_file
  else
    gnsh_error '404'
  fi >&5
}

# Send Response!
# ---------------------------------------------------------------------------------

trap 'gnsh_response; rm -f $resp_file' EXIT
: > $resp_file
exec 5>&1
exec > $resp_file
