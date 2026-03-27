func claude() {
  local env_name=""
  local remaining_args=()
  local skip_next=0
  local env_dir="$HOME/tools/bash-autorun/private/claude"
  local managed_vars=(
    ANTHROPIC_BASE_URL
    ANTHROPIC_AUTH_TOKEN
    API_TIMEOUT_MS
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
ANTHROPIC_DEFAULT_HAIKU_MODEL
    ANTHROPIC_DEFAULT_SONNET_MODEL
    ANTHROPIC_DEFAULT_OPUS_MODEL
  )

  # 解析参数，提取 --env 和 --teams 参数
  for arg in "$@"; do
    if [[ $skip_next -eq 1 ]]; then
      env_name="$arg"
      skip_next=0
    elif [[ "$arg" == "--env" ]]; then
      skip_next=1
    elif [[ "$arg" == --env=* ]]; then
      env_name="${arg#--env=}"
    elif [[ "$arg" == "--teams" ]]; then
      enable_teams=1
    else
      remaining_args+=("$arg")
    fi
  done

  # 如果未指定环境，用 fzf 让用户选择
  if [[ -z "$env_name" ]]; then
    local env_entries=()

    for f in "$env_dir"/*.env; do
      [[ -f "$f" ]] || continue
      local name="$(basename "$f" .env)"
      local desc="$(grep -m1 '^# description:' "$f" 2>/dev/null | sed 's/^# description: *//')"
      if [[ -n "$desc" ]]; then
        env_entries+=("${name} - ${desc}")
      else
        env_entries+=("$name")
      fi
    done

    if [[ ${#env_entries[@]} -eq 0 ]]; then
      echo "错误: $env_dir 目录中没有找到任何 .env 文件"
      return 1
    fi

    local selected
    selected=$(printf '%s\n' "${env_entries[@]}" | fzf --prompt="选择 Claude 环境: " --height=~10 --layout=reverse --border)

    if [[ -z "$selected" ]]; then
      echo "已取消。"
      return 1
    fi

    env_name="${selected%% - *}"

    # 未指定 --teams 时，提示是否启用 teams
    if [[ $enable_teams -ne 1 ]]; then
      echo "是否启用 Agent Teams? [y/N]"
      local answer
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        enable_teams=1
      fi
    fi
  fi

  # 检查环境文件是否存在
  local env_file="$env_dir/${env_name}.env"
  if [[ ! -f "$env_file" ]]; then
    echo "未找到环境配置文件: $env_file"
    echo "可用环境："
    for f in "$env_dir"/*.env; do
      [[ -f "$f" ]] && echo "  - $(basename "$f" .env)"
    done
    return 1
  fi

  # 清除所有管理的环境变量
  for var in "${managed_vars[@]}"; do
    unset "$var"
  done

  # 从文件中加载环境变量
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    if [[ "$line" == *=* ]]; then
      local key="${line%%=*}"
      local val="${line#*=}"
      export "$key"="$val"
    fi
  done < "$env_file"

  # 将环境变量文件名赋值给 CLAUDE_PROFILE
  if [[ $enable_teams -eq 1 ]]; then
    export CLAUDE_PROFILE="$env_name (with agent teams)"
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
  else
    export CLAUDE_PROFILE="$env_name"
  fi

  # 漂亮的格式输出配置信息
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Claude API 配置信息 [环境: $env_name]"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [[ -n "$ANTHROPIC_BASE_URL" ]]; then
    echo "📡 Base URL:  $ANTHROPIC_BASE_URL"
  else
    echo "📡 Base URL:  (默认)"
  fi

  if [[ -n "$ANTHROPIC_AUTH_TOKEN" ]]; then
    # Token 掩码处理：显示前6位和后4位
    local token_length=${#ANTHROPIC_AUTH_TOKEN}
    local masked_token=""
    if [ $token_length -gt 10 ]; then
      local prefix="${ANTHROPIC_AUTH_TOKEN:0:6}"
      local suffix="${ANTHROPIC_AUTH_TOKEN: -4}"
      local mask_length=$((token_length - 10))
      local mask=$(printf '*%.0s' $(seq 1 $mask_length))
      masked_token="${prefix}${mask}${suffix}"
    else
      masked_token="$ANTHROPIC_AUTH_TOKEN"
    fi
    echo "🔑 Auth Token: $masked_token"
  else
    echo "🔑 Auth Token: (默认)"
  fi

  if [[ -n "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ]]; then
    echo "👥 Agent Teams: 已启用"
  fi

  if [[ -n "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ]]; then
    echo "🤖 Haiku  -> $ANTHROPIC_DEFAULT_HAIKU_MODEL"
    echo "🤖 Sonnet -> $ANTHROPIC_DEFAULT_SONNET_MODEL"
    echo "🤖 Opus   -> $ANTHROPIC_DEFAULT_OPUS_MODEL"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  $HOME/.local/bin/claude "${remaining_args[@]}"
}
