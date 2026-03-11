# ---------- colors ----------
if [ -n "$ZSH_VERSION" ]; then
  RESET="%f"
  BLUE="%F{blue}"
  GREEN="%F{green}"
  RED="%F{red}"
  YELLOW="%F{yellow}"
  CYAN="%F{cyan}"
  GRAY="%F{white}"
else
  RESET="\[\033[0m\]"
  BLUE="\[\033[1;34m\]"
  GREEN="\[\033[1;32m\]"
  RED="\[\033[1;31m\]"
  YELLOW="\[\033[1;33m\]"
  CYAN="\[\033[1;36m\]"
  GRAY="\[\033[0;37m\]"
fi

# ---------- git branch ----------
git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_dirty() {
  if ! git diff --quiet 2>/dev/null; then
    echo "*"
  fi
}

git_prompt() {
  local branch=$(git_branch)
  if [ -n "$branch" ]; then
    echo "(${branch}$(git_dirty)) "
  fi
}

# ---------- python venv ----------
venv_prompt() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "[venv:$(basename "$VIRTUAL_ENV")] "
  fi
}

# ---------- exit code ----------
exit_status() {
  if [ $? -eq 0 ]; then
    echo "${GREEN}✔${RESET}"
  else
    echo "${RED}✗${RESET}"
  fi
}

# ---------- prompt ----------
if [ -n "$ZSH_VERSION" ]; then
  setopt prompt_subst
  export PROMPT='${CYAN}%~${RESET}'$'\n''${YELLOW}$(git_prompt)${RESET}${CYAN}$(venv_prompt)${RESET}${GRAY}%*${RESET} $(exit_status) $ '
else
  export PS1='${CYAN}\w${RESET}\n${YELLOW}\$(git_prompt)${RESET}${CYAN}\$(venv_prompt)${RESET}${GRAY}\t${RESET} \$(exit_status) \$ '
fi
