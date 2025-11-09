set fish_greeting ""
if status is-interactive
    if command -q fastfetch
        fastfetch
    end
    lnk pull >/dev/null || echo "[init] lnk is not installed."
end

setenv EDITOR flow

# define an (initially empty) list of paths
set paths_to_add

# Local binaries
set -a paths_to_add ~/.local/bin

# Krew plugin manager
set -a paths_to_add $HOME/.krew/bin

# Go binaries
set -a paths_to_add $HOME/go/bin

# Go binaries
set -a paths_to_add $HOME/.cargo/bin

# Add each existing dir to PATH
for dir in $paths_to_add
    if test -d $dir
        fish_add_path $dir
    end
end
