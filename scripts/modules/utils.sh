UTILS_LOGPATH="/tmp/${USER}-scripts.log"

function utils::init() {
    # Usage:
    #     utils::init [-r|--reset]
    #
    # Initialize local environment with default settings.
    #
    # Flags:
    # -r    Clear the default logfile as part of initialization

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -r|--reset)
                rm $UTILS_LOGPATH
                shift
            ;;
            -*|--*)
                >&2 echo "Unknown option $i"
                return 1
            ;;
            *)
                shift
            ;;
        esac
    done

    PATH="."
    PATH="$PATH:$HOME/.nix-profile/bin"
    PATH="$PATH:$HOME/.local/state/nix/profiles/home-manager/home-path/bin"
    PATH="$PATH:$HOME/.local/bin"
    PATH="$PATH:$HOME/.cargo/bin"
    PATH="$PATH:$HOME/go/bin"
    PATH="$PATH:/run/current-system/sw/bin"
    PATH="$PATH:/usr/local/sbin"
    PATH="$PATH:/usr/local/bin"
    PATH="$PATH:/usr/sbin"
    PATH="$PATH:/usr/bin"
    PATH="$PATH:/sbin"
    PATH="$PATH:/bin"
    export PATH
}

function utils::log() {
    # Usage:
    #     utils::log [-o LOGFILE] [-c CONTEXT] [message]
    #     [command-with-output] | utils::log
    #
    # Writes messages to the log file.
    # You can specify a different location with -o
    #
    # E.g. 
    #     utils::log "Hello"
    #     > Writes "Hello" to log
    #
    #     tail -f | utils::log
    #     > Writes output of `tail` to log
    #
    #     tail -f | utils::log "Tail Output:"
    #     > Writes output of `tail` to log, with "Tail Output" as prefix
    #
    #     utils::log "Hello" -c "`whoami`"
    #     > Writes "Hello" to the log, with the current user as context
    #
    # Flags:
    # -o LOGFILE    Specify an output other than the default logfile
    # -c CONTEXT    Specify a context; if omitted, will use the immediate caller, if any

    local context_elements=()
    local message_elements=()
    local output="$UTILS_LOGPATH"
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -o)
                shift
                output=$1
                shift
            ;;
            -c)
                shift
                context_elements+=("$1")
                shift
            ;;
            -*|--*)
                >&2 echo "Unknown option $i"
                return 1
            ;;
            *)
                message_elements+=("$1")
                shift
            ;;
        esac
    done

    local prefix_elements=("[$(date '+%B %d %H:%M')]")
    if [[ "${#context_elements[@]}" -ne 0 ]]; then
        for item in "${context_elements[@]}"; do
            prefix_elements+=("[${item}]")
        done
    elif [[ "${#FUNCNAME[@]}" -gt 1 ]]; then
        prefix_elements+=("[${FUNCNAME[1]}]")
    fi
    local prefix=$(utils::array_join -n prefix_elements)
    local msg=$(utils::array_join -n message_elements)

    if [[ -t 0 ]]; then
        # If stdin isn't connected to a terminal (e.g. a pipe), dump immediately
        echo -e "${prefix} ${msg}" | tee -a "${output}"
    else
        # Otherwise read input from stdin
        local wrote_msg=false
        while read line; do
            echo -e "${prefix} ${msg} >>> ${line}" | tee -a "${output}"
            wrote_msg=true
        done < "/dev/stdin"
        if ! wrote_msg; then
            # Ensure at least one line is written, in case of an empty stdin pipe
            echo -e "${prefix} ${msg}" | tee -a "${output}"
        fi
    fi
}

function utils::err() {
    # Usage:
    #     utils::err [-o LOGFILE] [message]
    #
    # Emit the given message to stderr, but also also to the log

    local context=""
    if [[ "${#FUNCNAME[@]}" -gt 1 ]]; then
        context=" [${FUNCNAME[1]}]"
    fi
    utils::log -c "${context}" "[ERROR]" >/dev/stderr
}

function utils::exists() {
    # Usage:
    #     utils::exists [cmd ...]
    #
    # Returns whether all the given commands are in PATH.
    # E.g.
    #   `utils::exists bash zsh` -> RC 0
    #   `utils::exists not-bash` -> RC 1

    for arg in "$@"; do
        if ! command -v "$arg" >/dev/null 2>&1; then
            return 1
        fi
    done
}

function utils::array_join() {
    # Usage:
    #     utils::array_join -n ARRAYREF [-s SEPARATOR]
    #
    # Returns a string of the elements of ARRAYREF
    # E.g. Given `local my_array=(a b c)`
    #   `utils::array_join -n my_array          -> "a b c"
    #   `utils::array_join -n my_array -s ","   -> "a,b,c"
    #
    # Flags:
    #   -n ARRAYREF     [Mandatory Flag] Specifies the input array by name
    #   -s SEPARATOR    [Default: " "] Specifies the separator to use

    local sep=" "
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -s|--separator)
                shift
                sep="$1"
                shift
            ;;
            -n|--name)
                shift
                local -n arr="$1"
                shift
            ;;
            -*|--*)
                >&2 echo "Unknown option $i"
                return 1
            ;;
            *)
                shift
            ;;
        esac
    done
    if [[ -z "$arr" ]]; then
        >&2 echo "Array ref (\`-n\` flag) must be set"
        return 1
    fi
    IFS="$sep"; echo "${arr[*]}"
}
