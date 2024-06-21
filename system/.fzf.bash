# Setup fzf
# ---------
if [[ ! "$PATH" == */home/berk/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/berk/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/home/berk/.fzf/shell/completion.bash"

# Key bindings
# ------------
source "/home/berk/.fzf/shell/key-bindings.bash"
