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
    PATH="$PATH:$HOME/.local/bin"
    PATH="$PATH:$HOME/.cargo/bin"
    PATH="$PATH:$HOME/go/bin"
    PATH="$PATH:/run/current-system/sw/bin"
    PATH="$PATH:/usr/local/sbin"
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
    #     utils::log [-o LOGFILE] [message]
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
    # Flags:
    # -o [LOGFILE]      Specify an output other than the default logfile

    local context=""
    if [[ "${#FUNCNAME[@]}" -gt 1 ]]; then
        context=" [${FUNCNAME[1]}]"
    fi
    local prefix="[$(date '+%B %d %H:%M')]${context}"
    local message=""
    local output="$UTILS_LOGPATH"
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -o)
                shift
                output=$1
                shift
            ;;
            -*|--*)
                >&2 echo "Unknown option $i"
                return 1
            ;;
            *)
                message+=" $1"
                shift
            ;;
        esac
    done

    if [[ -t 0 ]]; then
        # If stdin isn't connected to a terminal (e.g. a pipe), dump immediately
        echo -e "${prefix}${message}" | tee -a "${output}"
    else
        # Otherwise read input from stdin
        while read line; do
            echo -e "${prefix}${message} >>> ${line}" | tee -a "${output}"
        done < "/dev/stdin"
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
    local message="[$(date '+%B %d %H:%M')] [ERROR]${context}"
    local output="$UTILS_LOGPATH"
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -o)
                shift
                output=$1
                shift
            ;;
            -*|--*)
                >&2 echo "Unknown option $i"
                return 1
            ;;
            *)
                message+=" $1"
                shift
            ;;
        esac
    done
    >&2 echo "${message}" 2> >(tee -a "${output}" >&2)
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
