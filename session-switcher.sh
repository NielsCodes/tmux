#!/usr/bin/env bash

# Custom session switcher that sorts by last accessed time
# Most recently accessed sessions appear at the bottom

# Source tmux-fzf environment
TMUX_FZF_DIR="$HOME/.tmux/plugins/tmux-fzf/scripts"
source "$TMUX_FZF_DIR/.envs"

# Get current session to exclude it
current_session=$(tmux display-message -p '#S')

# Get sessions with timestamp for sorting, then format for display
if [[ -z "$TMUX_FZF_SESSION_FORMAT" ]]; then
    sessions=$(tmux list-sessions -F "#{session_last_attached}|#{session_name}")
else
    sessions=$(tmux list-sessions -F "#{session_last_attached}|#{session_name}: $TMUX_FZF_SESSION_FORMAT")
fi

# Remove current session if configured
if [[ -z "$TMUX_FZF_SWITCH_CURRENT" ]]; then
    sessions=$(echo "$sessions" | grep -v "|$current_session:")
    sessions=$(echo "$sessions" | grep -v "|$current_session$")
fi

# Sort by timestamp (first field) in reverse - most recent at bottom
sessions=$(echo "$sessions" | sort -t'|' -k1 -nr | cut -d'|' -f2-)

# Use fzf to select session
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target session.'"
target_origin=$(printf "%s\n[cancel]" "$sessions" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_SESSION_OPTIONS")

# Exit if cancelled
[[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit

# Extract session name and switch
target=$(echo "$target_origin" | sed -e 's/:.*$//')
tmux switch-client -t "$target"
