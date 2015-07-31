# Bin, Bash, Ganesh!
# A Sinatra-like CGI framework for Bash.

# private global variables
# ---------------------------------------------------------------------------------

declare ganesh_tmpfile=/tmp/ganesh_tmp.$RANDOM$$
declare REQUEST_URI_PARAM=${REQUEST_URI#$SCRIPT_NAME}
declare REQUEST_URI_PATH=${REQUEST_URI_PARAM%%\?*}
declare routing_matched

declare RESPONSE_CONTENT_TYPE='text/plain'
declare RESPONSE_CHARSET='utf-8'
declare RESPONSE_STATUS='200 OK'
declare RESPONSE_DATE="$(date -u '+%a, %d %b %Y %R:%S GMT')"

declare -a uvi
declare CR='\r'
declare LF='\n'
declare CRLF="$CR$LF"

# public functions
# ---------------------------------------------------------------------------------

   get() { ganesh_route GET "$1"; }
  post() { ganesh_route POST "$1"; }
delete() { ganesh_route DELETE "$1"; }
status() { RESPONSE_STATUS=$*; }
header() { head="$1: $2"
    if [ "$response_headers" ]
    then response_headers="$response_headers$LF$head"
    else response_headers="$head"
    fi
}

# private functions
# ---------------------------------------------------------------------------------

ganesh_route() {
    [ -n "$routing_matched" ] && return -1

    local verb=$1
    local path=$2
    local re=$(ganesh_compile_path "$path")
    local -i i

    uvi=()
    if [ "$REQUEST_METHOD" = "$verb" ] && [[ "$REQUEST_URI_PATH" =~ $re ]]; then
		for ((i = 1; i < ${#BASH_REMATCH[@]}; i++)) {
		    uvi[i - 1]=$(ganesh_unescape "${BASH_REMATCH[i]}")
		}
		routing_matched=true
		return 0
    fi
    return -1
}

ganesh_compile_path() {
    local path=$1

    # escape special chars
    path=${path//./\\.}
    path=${path//+/\\+}
    path=${path//\(/\\(}
    path=${path//)/\\)}

    # wildcard
    path=${path//\*/(.*?)}

    echo "^$path\$"
}

ganesh_extract_params() {
    local query=${REQUEST_URI_PARAM#*\?}
    if [ "$REQUEST_METHOD" = POST ] && [[ -n "$CONTENT_LENGTH" ]]; then
		read -n $CONTENT_LENGTH POST_DATA
		if [ -n "$query" ]
		then query="$query&$POST_DATA"
		else query=$POST_DATA
		fi
    fi

    local p var val IFS
    IFS='&'
    for p in $query; do
	if [[ "$p" == *=* ]]; then
	    var=${p%%=*}
	    val=${p#*=}
	    eval "params_${var#:}='$(ganesh_unescape $val)'"
	fi
    done
}

ganesh_unescape() {
    local str=$1
    str=${str//+/ }
    str=${str//%/\\x}
    echo -e "$str"
}

ganesh_not_found() {
	header "Status" "404 Not Found"
	header "Content-Type" "text/plain"
	header "Date" "$RESPONSE_DATE"
	echo -e "$response_headers$CRLF"
	echo -e "404 Not Found"
}

ganesh_send_response() {
if [ -n "$routing_matched" ]; then
	header "Status" "$RESPONSE_STATUS"
	header "Date" "$RESPONSE_DATE"
	echo -e "$response_headers$CRLF"
	while read -r line
	do echo "$line"
	done < $ganesh_tmpfile
else ganesh_not_found
fi >&5 # 5 is a copy of stdout
}

# main
# ---------------------------------------------------------------------------------

ganesh_extract_params
trap 'ganesh_send_response; rm -f $ganesh_tmpfile' EXIT
: > $ganesh_tmpfile
exec 5>&1
exec > $ganesh_tmpfile
