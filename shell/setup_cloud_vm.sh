#!/bin/bash

# OS: Debian GNU/Linux
set -e  # Exit on error

echo "🔧 Updating packages and installing dependencies..."
sudo apt update && sudo apt install -y \
  zsh git curl wget unzip build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

echo "🎉 Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🎨 Installing Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "🐍 Installing pyenv..."
curl https://pyenv.run | bash

cat >> ~/.zshrc << 'EOF'

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

echo "📦 Installing Python 3.11.10 with pyenv..."
pyenv install 3.11.10
pyenv global 3.11.10

echo "🔑 Setting up SSH key for GitHub..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "sanjeev.it@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    echo "🚀 SSH public key (add this to GitHub):"
    cat ~/.ssh/id_ed25519.pub
else
    echo "SSH key already exists."
fi

echo "✅ Setup complete! You can now use zsh, Python 3.11.10, and connect to GitHub."

exec zsh
