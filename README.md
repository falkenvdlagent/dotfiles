# dotfiles

My Linux dev environment, managed with Nix and standalone Home Manager.

This repo is a fork of [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles), which configures a Mac with nix-darwin, Homebrew and Home Manager.
It keeps the same idea - one repo, one command, the same environment every time - but is tailored for Linux.
It currently targets **AlmaLinux 10** (x86_64, not NixOS).

Kun's walkthrough of the original setup: https://youtu.be/5N-okeDdIuI

## Differences from the original

- **No nix-darwin, no Homebrew, no macOS defaults.** Only the Home Manager part is used, as a standalone `homeConfigurations` flake output.
- **GUI apps live outside Nix.** WezTerm (AppImage), herdr and Claude Code are installed normally. Nix-built GPU apps need extra setup (nixGL) on a non-NixOS distro.
- **Pi configuration removed.**
- **My own configs** for WezTerm, herdr and Claude Code, while `home/AGENTS.md` keeps Kun's shared agent policy.

## What you get

- Nix user packages: ripgrep, fd, fzf, jq, lazygit, Neovim, gcc (for treesitter), Hack Nerd Font
- Shell: zsh with autosuggestions, syntax highlighting, aliases and the starship prompt
- Editor: Neovim config with the rose-pine moon theme
- Terminal: WezTerm config with the rose-pine moon theme and dimmed unfocused windows
- herdr: tmux-style keybindings (`ctrl+b` prefix)
- Agent configs: Claude, Codex and opencode all share one `home/AGENTS.md`

## Fresh-machine setup

```sh
git clone https://github.com/falkenvdlagent/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
chsh -s /usr/bin/zsh   # then log out and back in
```

`bootstrap.sh`:

1. Installs Determinate Nix, if it isn't already installed (asks for sudo).
2. Symlinks this repo to `~/.dotfiles`. `home.nix` points at config files through that path.
3. Checks the `user` in `flake.nix` against your Linux username.
4. Runs the first `home-manager switch`. Existing files in the way (such as `~/.zshrc`) are renamed to `*.backup`.

On another machine or user, change the single `user = "..."` line (and `system` if not x86_64) in `flake.nix` first.

### Validate without applying

```sh
nix flake check --no-build
nix build .#homeConfigurations.falkenvdlagent.activationPackage --dry-run
```

## Daily use

Files under `home/` are symlinked live into place, so editing them changes your config immediately.
After changing packages or anything else in `home.nix`, apply with:

```sh
./rebuild.sh
```

## Repo tour

- `flake.nix` - entry point: nixpkgs, Home Manager and the `homeConfigurations.<user>` output.
- `home.nix` - packages, shell, prompt and the config symlinks.
- `bootstrap.sh` / `rebuild.sh` - first-time setup and re-apply.
- `home/` - the real config files (`.config/nvim`, `.config/wezterm`, `.config/herdr/config.toml`, `.claude/settings.json`, `AGENTS.md`).

## Notes

- `home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo.
- Only `~/.config/herdr/config.toml` is linked, not the whole directory, because herdr keeps sockets, logs and sessions there.
- The `cc` and `co` aliases are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
- The first `nvim` launch bootstraps lazy.nvim and clones plugins from GitHub (network needed once).
- Git identity is not managed here. Set it with `git config --global user.name` / `user.email`.

## License

MIT No Attribution, inherited from the original repo. See `LICENSE`.
