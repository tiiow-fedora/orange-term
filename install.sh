#!/usr/bin/env bash
# orange-term: orange hacker terminal (starship powerline, fastfetch, eza/bat, Claude Code statusline)
# usage: bash install.sh      (needs a Nerd Font in your terminal)
set -euo pipefail
bak() { [ -e "$1" ] && cp "$1" "$1.bak.$(date +%s)" || true; }

echo "==> packages"
PKGS="starship fastfetch eza bat jq"
if command -v pacman >/dev/null; then sudo pacman -S --needed --noconfirm $PKGS
elif command -v apt-get >/dev/null; then sudo apt-get install -y $PKGS || echo "some packages missing; install starship/fastfetch/eza/bat/jq manually"
elif command -v dnf >/dev/null; then sudo dnf install -y $PKGS || echo "some packages missing; install manually"
else echo "unknown package manager; install: $PKGS"; fi

mkdir -p ~/.config/fastfetch ~/.claude

bak ~/.config/starship.toml
cat > ~/.config/starship.toml <<'ORANGE_STARSHIP'
add_newline = true
command_timeout = 200
format = """
[](#ff3b2f)$os$username[](bg:#ff5a1f fg:#ff3b2f)$directory[](fg:#ff5a1f bg:#ff8547)$git_branch$git_status[](fg:#ff8547 bg:#ffc233)$cmd_duration[](fg:#ffc233)
[└─](bold #7a5a4e)$character"""

[os]
disabled = false
style = "bg:#ff3b2f fg:#160c09"
format = "[ $symbol ]($style)"
[os.symbols]
Arch = ""

[username]
show_always = true
style_user = "bg:#ff3b2f fg:#160c09 bold"
style_root = "bg:#ff3b2f fg:#160c09 bold"
format = "[$user ]($style)"

[directory]
style = "bg:#ff5a1f fg:#160c09 bold"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#ff8547 fg:#160c09"
format = "[ $symbol $branch ]($style)"

[git_status]
style = "bg:#ff8547 fg:#160c09"
format = "[$all_status$ahead_behind ]($style)"

[cmd_duration]
min_time = 0
show_milliseconds = false
style = "bg:#ffc233 fg:#160c09"
format = "[ 󱑂 $duration ]($style)"

[character]
success_symbol = "[❯❯](bold #ff5a1f)"
error_symbol = "[❯❯](bold #ff3b2f)"
ORANGE_STARSHIP

bak ~/.config/fastfetch/config.jsonc
cat > ~/.config/fastfetch/config.jsonc <<'ORANGE_FETCH'
{
  "logo": { "type": "file", "source": "~/.config/fastfetch/logo.txt", "position": "top", "color": { "1": "38;2;255;90;31" }, "padding": { "top": 1, "left": 1, "bottom": 1 } },
  "display": { "separator": "  ", "color": { "keys": "38;2;255;90;31", "title": "38;2;255;194;51" } },
  "modules": [
    "title", { "type": "custom", "format": "\u001b[38;2;122;90;78m────────────────────────" },
    { "type": "os", "key": " os    " }, { "type": "kernel", "key": " kern  " },
    { "type": "uptime", "key": "󰔟 up    " }, { "type": "packages", "key": "󰏖 pkgs  " },
    { "type": "shell", "key": " sh    " }, { "type": "wm", "key": " wm    " },
    { "type": "terminal", "key": " term  " }, { "type": "cpu", "key": " cpu   " },
    { "type": "gpu", "key": "󰢮 gpu   " }, { "type": "memory", "key": "󰍛 mem   " },
    "break", "colors"
  ]
}
ORANGE_FETCH

bak ~/.config/fastfetch/logo.txt
cat > ~/.config/fastfetch/logo.txt <<'ORANGE_LOGO'
$1                 ▄▄▄
$1 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄
$1███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
$1███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
$1███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
$1███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
$1███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
$1███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
$1 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀
$1                                       ███   █▀
ORANGE_LOGO

bak ~/.claude/statusline.sh
cat > ~/.claude/statusline.sh <<'ORANGE_STATUS'
#!/bin/bash
j=$(cat)
m=$(jq -r '.model.display_name // "claude"' <<<"$j")
d=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$j"); d=${d/#$HOME/\~}
c=$(jq -r '.cost.total_cost_usd // 0' <<<"$j")
b=$(git -C "$(jq -r '.workspace.current_dir // .cwd' <<<"$j")" branch --show-current 2>/dev/null)
o=$'\e[38;2;22;12;9m'; r=$'\e[0m'
printf '\e[38;2;255;59;47m\e[0m\e[48;2;255;59;47m%s  %s \e[38;2;255;59;47;48;2;255;90;31m\e[0m\e[48;2;255;90;31m%s %s' "$o" "$m" "$o" "$d"
if [ -n "$b" ]; then printf ' \e[38;2;255;90;31;48;2;255;133;71m\e[0m\e[48;2;255;133;71m%s  %s ' "$o" "$b"; printf '\e[0m\e[38;2;255;133;71m\e[0m'; else printf ' \e[0m\e[38;2;255;90;31m\e[0m'; fi
printf ' \e[38;2;255;194;51m$%.2f%s\n' "$c" "$r"
ORANGE_STATUS
chmod +x ~/.claude/statusline.sh

echo "==> claude settings"
python3 - <<'PY'
import json,os
p=os.path.expanduser('~/.claude/settings.json')
s=json.load(open(p)) if os.path.exists(p) else {}
s['statusLine']={'type':'command','command':'~/.claude/statusline.sh'}
s['theme']='dark'
json.dump(s,open(p,'w'),indent=2)
PY

echo "==> bashrc"
if ! grep -q 'orange hacker terminal' ~/.bashrc 2>/dev/null; then
cat >> ~/.bashrc <<'ORANGE_RC'

# --- orange hacker terminal ---
alias ls='eza --icons --group-directories-first --color=always'
alias ll='eza -lah --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never --theme=ansi'
export BAT_THEME=ansi
export EZA_COLORS='di=38;2;255;90;31:ex=38;2;255;194;51:ur=38;2;255;194;51:uw=38;2;255;59;47:ux=38;2;255;133;71:da=38;2;122;90;78:sn=38;2;255;194;51:sb=38;2;255;133;71'
command -v starship >/dev/null && eval "$(starship init bash)"
if [[ $- == *i* && -z "$NOFETCH" && -z "$TMUX" ]]; then fastfetch; fi
ORANGE_RC
fi
echo "done. open a new terminal (set a Nerd Font, e.g. JetBrainsMono Nerd Font)."
