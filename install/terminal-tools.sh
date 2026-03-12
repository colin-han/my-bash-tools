#!/usr/bin/env bash

set -e

echo "Installing fzf + zoxide..."

# detect shell config
if [[ "$SHELL" == *"zsh" ]]; then
  SHELL_RC="$HOME/.zshrc"
else
  SHELL_RC="$HOME/.bashrc"
fi

echo "Shell config: $SHELL_RC"

# -------------------------
# install packages
# -------------------------

if command -v brew >/dev/null 2>&1; then
  echo "Using Homebrew..."
  brew install fzf zoxide
elif command -v apt >/dev/null 2>&1; then
  echo "Using apt..."
  sudo apt update
  sudo apt install -y fzf zoxide
else
  echo "Package manager not supported. Install manually."
  exit 1
fi

# -------------------------
# install fzf shell integration
# -------------------------

if command -v brew >/dev/null 2>&1; then
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
fi

# -------------------------
# update shell config
# -------------------------

echo "Configuring shell..."

if ! grep -q "zoxide init" "$SHELL_RC"; then
  echo "" >> "$SHELL_RC"
  echo "# zoxide" >> "$SHELL_RC"
  echo 'eval "$(zoxide init '"${SHELL##*/}"')" ' >> "$SHELL_RC"
fi

if ! grep -q "fzf keybindings" "$SHELL_RC"; then
  cat >> "$SHELL_RC" <<'EOF'

# fzf keybindings
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

EOF
fi

echo ""
echo "Installation complete!"
echo ""
echo "Restart terminal or run:"
echo ""
echo "source $SHELL_RC"
echo ""
echo "Useful commands:"
echo ""
echo "Ctrl-R    search command history"
echo "Ctrl-T    search files"
echo "Alt-C     search directories"
echo "z <dir>   jump directory"
echo "zi        interactive directory jump"

