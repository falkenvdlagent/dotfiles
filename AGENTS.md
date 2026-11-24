# Project notes for agents

Linux (AlmaLinux, non-NixOS) dotfiles managed by Nix + standalone Home Manager, forked from kunchenguid/dotfiles (which targets macOS via nix-darwin).

- Entry point is `flake.nix` (`homeConfigurations.<user>`); user config is `home.nix`; apply with `./rebuild.sh`.
- Files under `home/` are symlinked live via `mkOutOfStoreSymlink` through `~/.dotfiles`; editing them needs no rebuild.
- GUI apps (WezTerm, herdr, Claude Code) are installed outside Nix on purpose: Nix-built GPU apps need nixGL on non-NixOS.
- Only `~/.config/herdr/config.toml` is linked, never the whole directory (it holds sockets, logs and sessions).
