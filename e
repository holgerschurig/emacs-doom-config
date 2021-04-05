#!/usr/bin/env bash
force_tty=false
force_wait=false
stdin_mode=""

args=()

while :; do
	case "$1" in
		-t | -nw | --tty)
			force_tty=true
			shift ;;
		-w | --wait)
			force_wait=true
			shift ;;
		-m | --mode)
			stdin_mode=" ($2-mode)"
			shift 2 ;;
		-h | --help)
			echo -e "Usage: e [-t] [-m MODE] [OPTIONS] FILE [-]

Emacs client convenience wrapper.

Options:
-h, --help            Show this message
-t, -nw, --tty        Force terminal mode
-w, --wait            Don't supply --no-wait to graphical emacsclient
-                     Take stdin (when last argument)
-m MODE, --mode MODE  Mode to open stdin with

Run \033[0;32memacsclient --help to see help for the emacsclient."
			exit 0 ;;
		--*=*)
			set -- "$@" "${1%%=*}" "${1#*=}"
			shift ;;
		*)
			if [ "$#" = 0 ]; then
				break; fi
			args+=("$1")
			shift ;;
	esac
done

if [ ! "${#args[*]}" = 0 ] && [ "${args[-1]}" = "-" ]; then
	unset 'args[-1]'
	TMP="$(mktemp /tmp/emacsstdin-XXX)"
	cat > "$TMP"
	args+=(--eval "(let ((b (generate-new-buffer \"*stdin*\"))) (switch-to-buffer b) (insert-file-contents \"$TMP\") (delete-file \"$TMP\")${stdin_mode})")
fi

if [ -z "$DISPLAY" ] || $force_tty; then
	# detect terminals with sneaky 24-bit support
	if { [ "$COLORTERM" = truecolor ] || [ "$COLORTERM" = 24bit ]; } \
		&& [ "$(tput colors 2>/dev/null)" -lt 257 ]; then
		if echo "$TERM" | grep -q "^\w\+-[0-9]"; then
			termstub="${TERM%%-*}"; else
			termstub="${TERM#*-}"; fi
		if infocmp "$termstub-direct" >/dev/null 2>&1; then
			TERM="$termstub-direct"; else
			TERM="xterm-direct"; fi # should be fairly safe
	fi
	emacsclient --tty -create-frame --alternate-editor="" "${args[@]}"
else
	if ! $force_wait; then
		args+=(--no-wait); fi
	emacsclient --alternate-editor="" "${args[@]}"
fi
