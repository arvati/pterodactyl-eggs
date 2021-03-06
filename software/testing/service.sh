#!/bin/sh -e
##############################################################
#  Copyright (c) 2021 Ademar Arvati Filho                    #
#                 All rights reserved.                       #
#                                                            #
#  This work is licensed under the terms of the MIT license. #
#  For a copy, see <https://opensource.org/licenses/MIT>.    #
##############################################################
#

USAGE="Usage: ${0} -i int [-htf] [-v enum] [-s string] [-l string]... [file...]"

show_help() {
cat >&2 <<EOT
${USAGE}
Example script parsing common command line argument syntax patterns.
Prints parsed arg values and exits.
Options:
  -h             Help. Show this help message and exit
  -f             False. Set 'f' off (1). Default = 0.
  -i integer     Integer. Any integer. Required.
  -l string      List, [0..n], of non-blank strings.
                 Multiple occurrences add to the list. Default = none.
  -s string      String. Any non-blank string.
  -t             Set 't' on (0). Default = 1.
  -v enum        Verbosity, one of 'debug info warn error'. Default = debug.
                 Use as first option to change for remaining script.
  file           An unordered list of [0..n] existing files. Default = none.
Syntax notes:
  -i int         : Required option-arg pair.
  [-htf]         : Optional options.
  [-v enum]      : Optional option-arg pair.
  [-s string]    : Optional option-arg pair.
  [-l string]... : Zero or more '-f arg' pairs.
  [file...]      : Zero or more operands.
NOTE: if an option is repeated, the last instance is used - unless [-l string]...
      is specified.
Other common patterns not shown in this example:
  -f arg [-f arg]...    One or more option-arg pairs
  operand [operand...]  One or more operands
Calling conventions supported
  Given this usage:
    cmd [-ab] -c arg file [file...]
  The following syntax is accepted
  cmd -abcarg file
  cmd -a -c arg file file
  cmd -carg -a file file
  cmd -a -carg -- file file
Examples:
  Minimal call, showing only the single required arg
    ${0} -i 1
EOT
}

# getopts manipulates global vars like ${@}. Save initial state for error reporting.
CMD_ARGS="${@}"
CMD_LINE="${0} ${@}"

# Return the number of words in ${1} (a string)
word_count() {
    # Alternatively: echo "${1}" | wc -w
    # Note: do not doublequote ${1} for proper expansion
    set -- ${1}
    echo "${#}"
}

# Return true (0) if ${1} (requested log level) >= current log level, false (1) otherwise
is_msg_allowed() {
    # V_ENUM_LIST is in low to high priority order: 'debug info warn error'
    # If we delete everything before the current level, and the current level
    # exists in what remains, we are at a sufficient log level to allow the msg.
    local ALLOWED=${V_ENUM_LIST/*${V_VALUE}/${V_VALUE}}
    printf "%s" "${ALLOWED}" | grep -qE "\b${1}\b"
}

# Print developer diagnostic information - for debugging and because this is a demo.
getopts_info() {
    if is_msg_allowed 'debug' ; then
        stderr "$(green "===> Processing '${1}': OPT = '${OPT}', OPTARG = '${OPTARG}', OPTIND = '${OPTIND}'")"
    fi
}

# Print ${1} in red
error() {
    stderr "$(red '===>' ${1})"
}

# A general handler for syntax related errors
# Print the command line, usage, help option, and exit 2 - the syntax exit error.
syntax_exit() {
    error "You typed: ${CMD_LINE}"
    error "${USAGE}"
    error "For more details, see: ${0} -h"
    exit 2
}

# Print an arg type validation error in red
# ${1} : expected type
arg_type_error() {
    error "Invalid '-${OPT}' arg. Expected type ${1}, got: '-${OPT}' = '${OPTARG}' at index ${OPTIND}"
    syntax_exit
}

# Print a missing required option error in red
# ${1} : option character
missing_required_option_error() {
    error "Missing required option: '-${1}'"
    error "This option is required; this script cannot work without it."
    syntax_exit
}

# Print a duplicate option error in red
# ${1} : option character
duplicate_option_error() {
    error "Duplicate option: '-${1}'"
    error "This option does not support multiple values; this script cannot"
    error "tell which option value you intended."
    syntax_exit
}

# Print a command line syntax error in red
# ${1} : error type
# Note: this can only be used from ?), :)
syntax_error() {
    error "${1} '-${OPTARG}'"
    syntax_exit
}

# Perform the main work of this script. In this case, just print options, args, operands
# Note that this heredoc is sent to stderr a slightly differnet way than above.
perform_work() {
cat <<EOT >&2
Command line:  ${CMD_LINE}
Parsed command line args
  I OPTION    = ${I_OPTION}
    VALUE     = ${I_VALUE}
  F OPTION    = ${F_OPTION}
  L OPTION    = ${L_OPTION}
    VALUE     = ${L_VALUE}
    COUNT     = $(word_count "${L_VALUE}")
  S OPTION    = ${S_OPTION}
    VALUE     = ${S_VALUE}
  T OPTION    = ${T_OPTION}
  V ENUM_LIST = ${V_ENUM_LIST}
    OPTION    = ${V_OPTION}
    VALUE     = ${V_VALUE}
  OPERANDS    = ${OPERANDS}
    COUNT     = $(word_count "${OPERANDS}")
EOT
}

THIS_SCRIPT_DIR=$(dirname $(readlink -f "${0}"))
(
    # Start work in the script dir for to easily locate include scripts
    cd ${THIS_SCRIPT_DIR}
    source ../common/validation.sh
    source ../common/colors.sh

    # Set defaults for all command line arguments: 0=on, 1=off.
    # Command line parsing will update these to match caller's desires.
    I_OPTION=1
    I_VALUE=
    F_OPTION=0
    L_OPTION=1
    L_VALUE=
    S_OPTION=1
    S_VALUE=
    T_OPTION=1
    V_ENUM_LIST='debug info warn error'
    V_OPTION=0
    V_VALUE='debug'
    OPERANDS=

    # getopts ensures that only allowed options are present and required
    # option-arguments exist - according to the getopts option string.
    # We still have to::
    # - ensure required options have been provided
    # - ensure each option-argument is a valid type
    # - assign command line args to variables for further use
    while getopts ":hv:tfi:s:l:" OPT; do
        case ${OPT} in
            h)  ## -h help
                show_help
                exit 0
                ;;
            f)  ## -f boolean option, default = on
                getopts_info '-f'
                F_OPTION=1
                ;;
            i)  ## -i integer, required, default = none
                getopts_info '-i'
                if is_int "${OPTARG}" ; then
                    if [ "${I_OPTION}" = "0" ] ; then
                        duplicate_option_error 'i'
                    else
                        I_OPTION=0
                        I_VALUE="${OPTARG}"
                    fi
                else
                    arg_type_error 'integer'
                fi
                ;;
            l)  ## -l string, [0..n] occurrences
                getopts_info '-l'
                L_OPTION=0
                L_VALUE="${L_VALUE} ${OPTARG}"
                ;;
            s)  ## -s string, optional
                getopts_info '-s'
                if is_not_blank "${OPTARG}" ; then
                    if [ "${S_OPTION}" = "0" ] ; then
                        duplicate_option_error 's'
                    else
                        S_OPTION=0
                        S_VALUE="${OPTARG}"
                    fi
                else
                    arg_type_error 'string'
                fi
                ;;
            t)  ## -t boolean option, default = off
                getopts_info '-t'
                T_OPTION=0
                ;;
            v)  ## -v enum, default = 'debug'
                if is_enum "${OPTARG}" ${V_ENUM_LIST} ; then
                    if [ "${V_OPTION}" = "0" ] ; then
                        duplicate_option_error 'v'
                    else
                        V_OPTION=0
                        V_VALUE=${OPTARG}
                        # Show debug information AFTER we set verbosity - caller may not want it
                        getopts_info '-v'
                    fi
                else
                    arg_type_error "enum, one of: ${V_ENUM_LIST}"
                fi
                ;;
            \?) ## invalid option, set by getopts during intial cmd line parsing
                ## OPTARG = invalid option character
                ## NOTE: in verbose mode, OPTARG is unset
                syntax_error 'Invalid option'
                ;;
            :)  ## missing required option-argument, set by getopts during intial cmd line parsing
                ## OPTARG = option character missing required arg
                ## NOTE: in verbose mode, OPTARG is unset
                syntax_error 'Missing required argument for'
                ;;
            *)  ## Unhandled option
                ## Using getopts, this only happens when a character in the getopts string
                ## does not have a case in this block - it is a code flaw - fix it.
                error 'Congratulations! You have discovered a bug. Please copy this error information'
                error 'and create a GitHub issue so it can be fixed.'
                error "Unhandled option: OPT = '${OPT}', OPTARG = '${OPTARG}', OPTIND = '${OPTIND}'"
                error "Command line: ${CMD_LINE}"
                exit 4
                ;;
        esac
    done

    # Extract operands. Note: prior to this statement, ${@} had not been modified
    # Note: the $(( )) shifts into math mode
    shift $((${OPTIND} - 1))
    OPERANDS="${@}"

    # Post command line processing validation
    # Required option validation
    # -i is the only required option. If I_OPTION set, its arg has already been validated.
    if [ ${I_OPTION} -ne 0 ] ; then missing_required_option_error 'i'; fi

    # Files readable validation
    # TODO: test -r allowing 222 files, works on mac
    for FILE in ${OPERANDS}; do
        echo "testing ${FILE}"
        if ! [ -r ${FILE} ]; then
            error "Each operand is a file that must exist and be readable."
            error "'${FILE}' either does not exist or is not readable."
            syntax_exit
        fi
    done

    # Conflicting arg validation - we don't have any cross-validation, but something to think about...

    # All command line args processed and validated - do the needful
    perform_work

)