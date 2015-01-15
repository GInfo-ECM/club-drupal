#!/bin/sh

# You must define a 'usage' function before to use that script.
# Never import it if you are using another getopts in your script.

while getopts "h" opt; do
    case "${opt}" in
	h)
	    usage
	    exit 0
	    ;;
    esac
done
shift $((OPTIND-1))
