export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="bira"
plugins=(git zsh-history-substring-search zsh-syntax-highlighting zsh-autosuggestions azure kubectl terraform gh)
source $ZSH/oh-my-zsh.sh

export PATH=/opt/homebrew/bin:$PATH
export EDITOR='nvim'
export PATH=$PATH:/opt/homebrew/Cellar/tfenv/3.0.0/bin
export PATH="$PATH:/opt/homebrew/opt/dotnet@6/bin"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

alias c='clear'
source ~/.az_helpers.sh
source <(zellij setup --generate-auto-start zsh)

