# nix-darwin Setup

This repository assumes your flake.nix is in a subdirectory (e.g., `./nix/`).

## 1. Prerequisites (macOS)

1. **Install Homebrew:** (Used for initial package/cask setup)

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Nix with multi-user support:**

   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

3. **Configure Flake:** Replace `username = "batman";` with your actual macOS username.

   ```bash
   sed -i '' "s@batman@$(whoami)@g" flake.nix
   ```

## 2. Initial Configuration and Subsequent Updates

Run the system activation script. Since this involves system-level changes (like installing packages and setting up services), it **MUST** be run with `sudo`.

Navigate to the directory containing your `flake.nix` (e.g., `cd nix`).

```bash
# 1) Install the CLI for your user
nix profile --extra-experimental-features 'nix-command flakes' add nix-darwin#darwin-rebuild

# 2) Try as user; if activation demands root, rerun with sudo
darwin-rebuild switch --flake .#meow
```

If dock is missing icons after the first run, re-run the darwin-rebuild command:

```bash
darwin-rebuild switch --flake .#meow
```

<div class="alert alert-warning">
  <strong>Warning:</strong> If you encounter issues with Neovim after running the above commands with <code>sudo</code>, follow the steps below to fix permissions.

```bash
# 1) Take back ownership
sudo chown -R "$USER":staff ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim

# 2) Make them writable by you
chmod -R u+rwX ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
```
