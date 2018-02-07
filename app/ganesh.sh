# A simple REST framework for Bash.
# Version 0.3.6

declare gnsh_version=0.3.6
declare route_match
declare res_header
declare res_status='200 OK'
declare res_type='application/json'
declare res_file="$(mktemp)"

# Header
# ---------------------------------------------------------------------------------

status() { res_status=$1; }
header() { head="$1: $2"

  if [[ "$res_header" ]]
  then res_header="$res_header\n$head"
  else res_header="$head"
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
  local regx="$(gnsh_escape "$path")"
  local -i i

  if [[ "$REQUEST_METHOD" = "$verb" ]] && [[ "$PATH_INFO" =~ $regx ]]; then
  	route_match=true
  	gnsh_data
  	return 0
  fi
  return -1
}

# Post Data / Query String
# ---------------------------------------------------------------------------------

gnsh_data() {
  groups=( $(echo $path | grep -o -e ':\w\+' | cut -d: -f2) )

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

  [[ ! $(echo $res_header | grep 'Status') ]] && header 'Status' "$res_status"
  [[ ! $(echo $res_header | grep 'Status') ]] && header 'Status' "$res_status"

  header 'Cache-control' 'no-cache'
  header 'Connection' 'keep-alive'
  header 'Date' "$(date -u '+%a, %d %b %Y %R:%S GMT')"
  # header 'Content-Length' "$(cat $res_file | wc -c)"

  echo -e "$res_header\r\n"
}

# Reponse
# ---------------------------------------------------------------------------------

gnsh_response() {
  if [[ -n "$route_match" ]]; then
    gnsh_header
    cat $res_file
  else
    gnsh_false
  fi >&5
}

# Not found (404)
# ---------------------------------------------------------------------------------

gnsh_false() {
  status 404
  gnsh_header
  cat <<EOF
{
  "code": 404,
  "message": "Not Found"
}
EOF
}

# Send Response!
# ---------------------------------------------------------------------------------

trap 'gnsh_response; rm -f $res_file' EXIT
: > $res_file
exec 5>&1
exec > $res_file
