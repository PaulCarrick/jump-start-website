#!/bin/sh

case "$1" in
    stderr)
        shift
        echo "$@" >&2
        ;;
    tty)
        shift
        echo "$@" > /dev/tty
        ;;
    *)
        shift
        echo "$@"
        ;;
esac

exit 0
