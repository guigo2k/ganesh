#!/usr/bin/env bash

http_version="HTTP/1.1"
ganesh_response="/tmp/ganesh_response"

CR='\r'
LF='\n'
CRLF="$CR$LF"

handle_request () {
    app="$1"

    # read the request line
    read request_line

    # read the header lines until we reach a blank line
    while read header && [ ! "$header" = $'\r' ]; do
        # FIXME: multiline headers
        header_name="HTTP_$(echo $header | cut -d ':' -f 1 | tr 'a-z-' 'A-Z_')"
        export $header_name="$(echo $header | cut -d ':' -f 2 | sed 's/^ //')"
    done

    # extract HTTP method and HTTP version
    export REQUEST_METHOD=$(echo $request_line | cut -d ' ' -f 1)
    export HTTP_VERSION=$(echo $request_line | cut -d ' ' -f 3 | tr -d $'\r')

    # extract the request_path, then PATH_INFO and QUERY_STRING components
    request_path=$(echo $request_line | cut -d ' ' -f 2)
    export PATH_INFO=$(echo $request_path | cut -d '?' -f 1)
    export QUERY_STRING=$(echo $request_path | cut -d '?' -f 2)

    export SCRIPT_NAME=""
    export SERVER_NAME="localhost"
    export SERVER_PORT="$port"

    "$app"
}

handle_response () {
    response_status="200 OK"
    response_headers=""

    while read header && [ ! "$header" = "" ]; do
        header_name="$(echo $header | cut -d ':' -f 1 | tr 'A-Z' 'a-z')"
        if [ "$header_name" = "status" ]; then
            response_status="$(echo $header | cut -d ':' -f 2 | sed 's/^ //')"
        #elif [ "$header_name" = "content-type" ]; then
        #elif [ "$header_name" = "location" ]; then
        else
            if [ "$response_headers" ]; then
                response_headers="$response_headers$CRLF$header"
            else
                response_headers="$header"
            fi
        fi
    done

    # Date
    header="Date: $(date -u '+%a, %d %b %Y %R:%S GMT')"
    response_headers="$response_headers$CRLF$header"

    # echo status line, headers, blank line, body
    echo -e "$http_version $response_status$CRLF$response_headers$CRLF$CR"
    cat
}

routes_method=()
routes_path=()
routes_action=()

route () {
    routes_method=( ${routes_method[@]} "$1" )
    routes_path=( ${routes_path[@]} "$2" )
    routes_action=( ${routes_action[@]} "$3" )
}

get () {
    route "GET" $@
}

post () {
    route "POST" $@
}

delete () {
    route "DELETE" $@
}

status () {
    response_status="$1"
}

header () {
    head="$1: $2"
    if [ "$response_headers" ]; then
        response_headers="$response_headers\n$head"
    else
        response_headers="$head"
    fi
}

not_found () {
    status "404"
    header "Content-type" "text/plain"
    if [ $# -gt 0 ]; then
        echo "$@"
    else
        echo "Not Found: $PATH_INFO"
    fi
}

ganesh_dance () {
    action=""

    for (( i = 0 ; i < ${#routes_method[@]} ; i++ )); do
        method=${routes_method[$i]}
        path=${routes_path[$i]}
        act=${routes_action[$i]}
        if [ "$REQUEST_METHOD" = "$method" ]; then
            if [ "$PATH_INFO" = "$path" ]; then
                action="$act"
                break
            fi
        fi
    done

    [ ! "$action" ] && action="not_found"

    reset_response

    # execute the action, storing output in a temporary file
    "$action" > "$ganesh_response"

    # set status header, echo headers, blank line, then body
    header "Status" "$response_status"
    echo -e "$response_headers"
    echo ""
    cat "$ganesh_response"
}

reset_response () {
    response_status="200 OK"
    response_headers=""
}
