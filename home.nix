{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";

  # Non-NixOS distro (AlmaLinux): wire Nix paths, XDG dirs and fonts into the host.
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    gcc       # nvim-treesitter compiles parsers
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      setopt COMPLETE_IN_WORD
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Lets bare `home-manager` commands (news, generations, switch) find this flake.
  home.file.".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink dotfiles;

  # Edit-in-place: the real file stays in this repo, ~/.config just points at it.
  # WezTerm and herdr themselves are installed outside Nix (AppImage / herdr installer).
  home.file.".config/wezterm".source = link "home/.config/wezterm";
  home.file.".config/nvim".source = link "home/.config/nvim";
  # Only the config file: ~/.config/herdr also holds sockets, logs and sessions.
  home.file.".config/herdr/config.toml".source = link "home/.config/herdr/config.toml";
  home.file.".claude/settings.json".source = link "home/.claude/settings.json";
  home.file.".local/bin/super-workspace".source = link "home/.local/bin/super-workspace";

  # One shared agent policy for Claude, Codex and opencode.
  home.file.".claude/CLAUDE.md".source = link "home/AGENTS.md";
  home.file.".codex/AGENTS.md".source = link "home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = link "home/AGENTS.md";
}
