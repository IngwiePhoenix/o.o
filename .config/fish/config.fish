set fish_greeting ""
if status is-interactive
    # Commands to run in interactive sessions can go here
    lnk pull >/dev/null || echo "[init] lnk is not installed."
end

setenv PATH "$PATH:/usr/local/go/bin"
setenv PATH "$PATH:/root/.local/bin"
setenv PATH "$PATH:$HOME/go/bin"
