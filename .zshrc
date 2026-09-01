# Created by newuser for 5.8

# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY

# nav & correction
setopt AUTO_CD INTERACTIVE_COMMENTS

# completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# prompt: user@host cwd + git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f%F{magenta}${vcs_info_msg_0_}%f %# '

# emacs keybindings + history search
bindkey -e
bindkey '^R' history-incremental-search-backward

# fish-like gray preview of the most likely next command (from history).
# Accept with Right Arrow or Ctrl-E. Not part of kphoen — that's just a prompt.
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# color the command as you type (green = found, red = unknown). source last.
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
