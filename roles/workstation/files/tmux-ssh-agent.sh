# Inside tmux, use the fixed SSH agent path that ~/.ssh/rc keeps pointed at the
# current connection's forwarded agent. A shell in a pane otherwise keeps the
# socket from whichever connection started the tmux server, and that socket is
# gone after a reconnect. Outside tmux the per-connection socket is correct, so
# it is left alone.
if [ -n "$TMUX" ] && [ -S "$HOME/.ssh/ssh_auth_sock" ]; then
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"
fi
