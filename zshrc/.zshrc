### ── Prompt ──────────────────────────────────────────────────────────────────
# same look; add async-safe prompt escape if you ever enable RPROMPT/git info
PS1="%1~ → "

### ── Platform detection (fast & POSIXy) ──────────────────────────────────────
IS_MACOS=false
IS_LINUX=false
case "$OSTYPE" in
  darwin*) IS_MACOS=true ;;
  linux*)  IS_LINUX=true ;;
esac

### ── Environment Variables ────────────────────────────────────────────────────
# Set default editor (prefer nvim, fallback to vim)
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
  export VISUAL="vim"
fi

### ── macOS-only: Homebrew, MongoDB, LLVM, Xcode SDK ─────────────────────────
if $IS_MACOS; then
  # Prefer Homebrew in PATH
  for p in /opt/homebrew/bin /usr/local/bin; do
    case ":$PATH:" in *":$p:"*) ;; *) PATH="$p:$PATH" ;; esac
  done
  export PATH

  if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix 2>/dev/null)"

    # zsh plugins via brew (if installed)
    [ -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
      && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
      && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # LLVM (clang/clangd) via brew
    if [ -d "$BREW_PREFIX/opt/llvm" ]; then
      export LIBCLANG_PATH="$BREW_PREFIX/opt/llvm/lib"
      case ":$PATH:" in
        *":$BREW_PREFIX/opt/llvm/bin:"*) ;;
        *) PATH="$BREW_PREFIX/opt/llvm/bin:$PATH" ;;
      esac
    fi
  fi

  # zsh plugins via nix (check after brew so nix takes precedence if both present)
  for nix_profile in "$HOME/.local/state/nix/profiles/home-manager" "$HOME/.local/state/home-manager/gcroots/current-home" "/etc/profiles/per-user/$USER" "$HOME/.nix-profile"; do
    [ -r "$nix_profile/home-path/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
      && source "$nix_profile/home-path/share/zsh-autosuggestions/zsh-autosuggestions.zsh" && break
  done
  for nix_profile in "$HOME/.local/state/nix/profiles/home-manager" "$HOME/.local/state/home-manager/gcroots/current-home" "/etc/profiles/per-user/$USER" "$HOME/.nix-profile"; do
    [ -r "$nix_profile/home-path/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
      && source "$nix_profile/home-path/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && break
  done

  # MongoDB (if installed via brew tap)
  for p in /opt/homebrew/opt/mongodb-community@4.4/bin; do
    [ -d "$p" ] && case ":$PATH:" in *":$p:"*) ;; *) PATH="$p:$PATH" ;; esac
  done

  # Xcode SDK (for bindgen, etc.)
  if command -v xcrun >/dev/null 2>&1; then
    SDK="$(xcrun --show-sdk-path 2>/dev/null)"
    if [ -n "$SDK" ]; then
      export SDKROOT="$SDK"
      export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=$SDK"
    fi
  fi
fi

### ── Linux-only tweaks ───────────────────────────────────────────────────────
if $IS_LINUX; then
  # user-local bin
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac

  # optional: distro-provided zsh plugins
  [ -r "/etc/zsh/zsh-autosuggestions.zsh" ] && source "/etc/zsh/zsh-autosuggestions.zsh"
  [ -r "/etc/zsh/zsh-syntax-highlighting.zsh" ] && source "/etc/zsh/zsh-syntax-highlighting.zsh"
fi

export PATH

### ── Shared keybindings (only if widgets exist) ──────────────────────────────
# Define helpers to safely bind only when the target widget exists.
_bind_if_present() {
  local key="$1" widget="$2"
  zle -l | grep -qx -- "$widget" && bindkey "$key" "$widget"
}

# These widgets come from zsh-autosuggestions; bind only if loaded
_bind_if_present '^w' autosuggest-execute
_bind_if_present '^e' autosuggest-accept
_bind_if_present '^u' autosuggest-toggle

# Built-ins / vi-mode friendly
bindkey '^L' forward-word    # (vi-forward-word requires vi-mode; this is safer)
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
# "jj" to escape to command mode (if using vi-mode)
zle -l | grep -qx vi-cmd-mode && bindkey -M viins 'jj' vi-cmd-mode

unset -f _bind_if_present

### ── pnpm (cross-platform) ───────────────────────────────────────────────────
# macOS default
if $IS_MACOS; then
  PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
else
  # linux default (matches pnpm docs)
  PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
fi
export PNPM_HOME
case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) PATH="$PNPM_HOME:$PATH" ;; esac

### ── Rust env ────────────────────────────────────────────────────────────────
export RUSTC_WRAPPER="${RUSTC_WRAPPER:-sccache}"
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

### ── fzf init (works with brew, nix, or manual) ──────────────────────────────
# 1) Manual install default location
[ -r "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# 2) Nix profile hook (if present)
if [ -r "$HOME/.nix-profile/etc/profile.d/fzf.zsh" ]; then
  source "$HOME/.nix-profile/etc/profile.d/fzf.zsh"
fi

# 3) System-wide nix profile (less common but safe)
if [ -r "/etc/profile.d/fzf.zsh" ]; then
  source "/etc/profile.d/fzf.zsh"
fi

### ── zoxide ──────────────────────────────────────────────────────────────────
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

### ── Aliases ───────────────────────────────────────────────────────────────────
# lsd (modern ls replacement with icons)
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd -1 --group-dirs=first'                           # Single column
  alias la='lsd -1 -a --group-dirs=first'                        # Single column + hidden files
  alias lg='lsd --group-dirs=first'           # Grid layout, dirs first
  alias ll='lsd -l --group-dirs=first'        # Long format
  alias lla='lsd -la --group-dirs=first'      # Long format + hidden files
  alias lt='lsd --tree'                       # Tree view
fi

# yazi (file manager with cd on exit)
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# Cross-platform clipboard (copy to clipboard)
if command -v pbcopy >/dev/null 2>&1; then
  # macOS
  alias clip='pbcopy'
elif command -v xclip >/dev/null 2>&1; then
  # Linux (X11)
  alias clip='xclip -selection clipboard'
elif command -v wl-copy >/dev/null 2>&1; then
  # Linux (Wayland)
  alias clip='wl-copy'
fi

# YouTube browsing & playback (yt-dlp + fzf + mpv)
if command -v yt-dlp >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1 && command -v mpv >/dev/null 2>&1; then
  # Search and play YouTube video
  function yt() {
    local query="$*"
    if [ -z "$query" ]; then
      echo "Usage: yt <search query>"
      return 1
    fi
    
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    # Create a preview script for fzf
    cat > "$tmp_dir/preview.sh" << 'PREVIEW_EOF'
#!/bin/bash
line="$1"
tmp_dir="$2"

title=$(echo "$line" | cut -f1)
id=$(echo "$line" | cut -f2)
thumb=$(echo "$line" | cut -f3)
thumb_file="$tmp_dir/$id.jpg"

# Download thumbnail if not cached
if [ ! -f "$thumb_file" ]; then
  curl -s "$thumb" -o "$thumb_file" 2>/dev/null
fi

# Display with viu (better quality, uses Kitty protocol when available)
if [ -f "$thumb_file" ] && command -v viu >/dev/null 2>&1; then
  viu -w 60 -h 20 "$thumb_file" 2>/dev/null
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📹 $title"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🆔 $id"
PREVIEW_EOF
    
    chmod +x "$tmp_dir/preview.sh"
    
    # Get results fast with --flat-playlist, construct thumbnail URLs manually
    yt-dlp "ytsearch20:$query" \
      --get-title --get-id --flat-playlist 2>/dev/null | \
      awk 'NR%2==1{title=$0} NR%2==0{id=$0; printf "%s\t%s\thttps://i.ytimg.com/vi/%s/hqdefault.jpg\n", title, id, id}' > "$tmp_dir/results.txt"
    
    local selected=$(cat "$tmp_dir/results.txt" | \
      fzf --ansi \
          --height=100% \
          --layout=reverse \
          --border \
          --delimiter='\t' \
          --with-nth=1 \
          --prompt="📺 Select video: " \
          --preview-window='right:50%' \
          --preview="$tmp_dir/preview.sh {} $tmp_dir" | \
      cut -f2)
    
    if [ -n "$selected" ]; then
      mpv "https://youtube.com/watch?v=$selected"
    fi
  }
  
  # Audio-only version (music, no ads!)
  function yta() {
    local query="$*"
    if [ -z "$query" ]; then
      echo "Usage: yta <search query>"
      return 1
    fi
    
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    yt-dlp "ytsearch20:$query" \
      --get-title --get-id --flat-playlist 2>/dev/null | \
      awk 'NR%2==1{title=$0} NR%2==0{id=$0; printf "%s\t%s\thttps://i.ytimg.com/vi/%s/hqdefault.jpg\n", title, id, id}' > "$tmp_dir/results.txt"
    
    local selected=$(cat "$tmp_dir/results.txt" | \
      fzf --ansi \
          --height=100% \
          --layout=reverse \
          --border \
          --delimiter='\t' \
          --with-nth=1 \
          --prompt="🎵 Select audio: " \
          --preview-window='right:50%' \
          --preview="
            title=\$(echo {} | cut -f1)
            id=\$(echo {} | cut -f2)
            thumb=\$(echo {} | cut -f3)
            thumb_file=\"$tmp_dir/\$id.jpg\"
            
            if [ ! -f \"\$thumb_file\" ]; then
              curl -s \"\$thumb\" -o \"\$thumb_file\" 2>/dev/null
            fi
            
            if [ -f \"\$thumb_file\" ] && [ \"\$TERM\" = \"xterm-ghostty\" ]; then
              printf '\033_Gf=100,a=T,t=f;'
              base64 < \"\$thumb_file\"
              printf '\033\\\\\n'
            fi
            
            echo ''
            echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            echo \"🎵 \$title\"
            echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            echo \"🆔 \$id\"
          " | \
      cut -f2)
    
    if [ -n "$selected" ]; then
      mpv --no-video "https://youtube.com/watch?v=$selected"
    fi
  }
  
  # Download video
  function ytd() {
    local query="$*"
    if [ -z "$query" ]; then
      echo "Usage: ytd <search query>"
      return 1
    fi
    
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    yt-dlp "ytsearch20:$query" \
      --get-title --get-id --flat-playlist 2>/dev/null | \
      awk 'NR%2==1{title=$0} NR%2==0{id=$0; printf "%s\t%s\thttps://i.ytimg.com/vi/%s/hqdefault.jpg\n", title, id, id}' > "$tmp_dir/results.txt"
    
    local selected=$(cat "$tmp_dir/results.txt" | \
      fzf --ansi \
          --height=100% \
          --layout=reverse \
          --border \
          --delimiter='\t' \
          --with-nth=1 \
          --prompt="💾 Select to download: " \
          --preview-window='right:50%' \
          --preview="
            title=\$(echo {} | cut -f1)
            id=\$(echo {} | cut -f2)
            thumb=\$(echo {} | cut -f3)
            thumb_file=\"$tmp_dir/\$id.jpg\"
            
            if [ ! -f \"\$thumb_file\" ]; then
              curl -s \"\$thumb\" -o \"\$thumb_file\" 2>/dev/null
            fi
            
            if [ -f \"\$thumb_file\" ] && [ \"\$TERM\" = \"xterm-ghostty\" ]; then
              printf '\033_Gf=100,a=T,t=f;'
              base64 < \"\$thumb_file\"
              printf '\033\\\\\n'
            fi
            
            echo ''
            echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            echo \"💾 \$title\"
            echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
            echo \"🆔 \$id\"
          " | \
      cut -f2)
    
    if [ -n "$selected" ]; then
      yt-dlp "https://youtube.com/watch?v=$selected"
    fi
  }
fi
