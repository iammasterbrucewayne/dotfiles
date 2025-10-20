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
