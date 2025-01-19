## Oh-My-Zsh

#### Install Oh-My-Zsh

#### Copy the Config
```
cp ./zshrc ~/.zshrc
```

#### Install the plugins
```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

## Alacritty

#### Install Alacritty
```sh
brew install --cask alacritty
```

#### Copy the Config
```sh
mkdir -p ~/.config/alacritty
cp ./alacritty.toml ~/.config/alacritty/alacritty.toml
```

## Zellij

#### Install
```sh
brew install zellij
```

## Nvim

#### Install
```sh
brew install neovim
```

#### Copy the Config
```sh
mkdir -p ~/.config/nvim
cp -a ./nvim ~/.config/nvim
```

## Az CLI Shortcuts
```sh
brew install azure-cli
cp ./az_helpers.sh ~/.az_helpers.sh
```
