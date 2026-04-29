{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.scarisey.myshell;
in {
  options.scarisey.myshell = {
    enable = mkEnableOption "My shell defaults";
  };
  config = mkIf cfg.enable {
    scarisey.nvim.enable = true;
    services.ssh-agent.enable = true;
    fonts.fontconfig.enable = true;
    home.packages = with pkgs;
      [
        git
        git-lfs
        curl
        dos2unix
        screen

        ffmpegthumbnailer #pictures preview in yazi
        unar #archive preview in yazi

        pay-respects
        peco #querying input
        fd #better find
        bat
        eza
        difftastic #diff highlighting many languages
        jq
        yq-go
        nvimpager
        nurl #give an url, output a fetcher for nix
        nix-init #give an url, output a derivation for nix
        nil #  nix LSP
        statix # nix linter
        ripgrep #recursive search fs for a regex
        neofetch
        pstree
        zip
        unrar
        unzip
        w3m
        lazygit
        ghq
        btop
        powertop
        poppler-utils #pdf conversions
        imagemagick #image to pdf with convert cli
        ttygif
        gifsicle
        rclone
        cryfs
        cht-sh
        cz-cli

        #sops
        sops
        age
        ssh-to-age

        nethogs #network load by process
        nload #network load by interface
        nmap #scan network - nmap -sn 192.168.1.128/24
        #agressive scan - sudo nmap -O --osscan-guess -sS 192.168.1.128/24

        adoc
        basic-secret
        git-prune
      ]
      ++ (with pkgs.nerd-fonts; [fira-code fira-mono droid-sans-mono hack hasklug meslo-lg ubuntu-mono]);

    home.sessionVariables = {
      GITDIR = "$HOME/git";
    };

    home.shellAliases = {
      ranger = "yazi";
      #bat
      cat = "bat";
      #eza
      ll = "eza --long --header";
      la = "eza --long --all --header";
      lt = "eza -T -L=2";

      #tmux
      ta = "tmux attach-session";
      tm = "tmux new-session -t $(basename $(pwd))";

      #sbt
      sbtc = "sbt --client";

      #cheat.sh
      cht = "cht.sh";

      #git
      git-release-notes = ''git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%h %s"'';

      retry = ''fun(){while true;do "$@" && break;sleep 1;done};fun'';

      ns = "fun(){NIXPKGS_ALLOW_UNFREE=1 nix shell --impure --inputs-from github:scarisey/nixos-dotfiles/main nixpkgs#$1};fun";

      cocommit = ''copilot --allow-all-tools -p "git commit with a meaningful message using git conventional commit"'';

      #nix

      nix-gc = ''nix-env --delete-generations 7d && nix-collect-garbage -d'';
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
      #https://rycee.gitlab.io/home-manager/options.html#opt-programs.zsh.enable
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      initContent = ''
        eval "$(pay-respects zsh)"
        export PAGER="nvimpager -p -- -c 'lua nvimpager.maps=false' "
        export MANPAGER="nvimpager -p -- -c 'lua nvimpager.maps=false' "
        source $HOME/.customzsh.rc &> /dev/null|| true
        export PATH=$PATH:$HOME/.local/bin/

        toggle_light_theme() {
          local theme_dir="$HOME/.config/theme"
          local mode_file="$theme_dir/mode"
          mkdir -p "$theme_dir"

          local current_mode="dark"
          [[ -f "$mode_file" ]] && current_mode=$(cat "$mode_file")
          local new_mode
          [[ "$current_mode" == "dark" ]] && new_mode="light" || new_mode="dark"
          echo "$new_mode" > "$mode_file"

          # --- Ghostty (auto-reloads when config-file changes via inotify) ---
          # Run `ghostty +list-themes` to browse available theme names.
          if [[ -d  "$HOME/.config/ghostty" ]];then
              if [[ "$new_mode" == "light" ]]; then
                echo 'theme = GitHub' > "$HOME/.config/ghostty/theme.conf"
              else
                echo 'theme = Arthur' > "$HOME/.config/ghostty/theme.conf"
              fi
              echo "Ghostty theme switched to $new_mode"
          fi

          # --- Vim (new sessions pick this up) ---
          if [[ "$new_mode" == "light" ]]; then
            printf 'set background=light\ncolorscheme everforest\n' > "$theme_dir/vim.vim"
          else
            printf 'set background=dark\ncolorscheme everforest\n' > "$theme_dir/vim.vim"
          fi
          echo "Vim theme switched to $new_mode"

        }
      '';

      history = {
        share = true; # false -> every terminal has it's own history
        size = 9999999; # Number of history lines to keep.
        save = 9999999; # Number of history lines to save.
        ignoreDups = true; # Do not enter command lines into the history list if they are duplicates of the previous event.
        extended = true; # Save timestamp into the history file.
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "docker-compose"
          "kubectl"
          "helm"
          "sbt"
          "bgnotify"
          "fzf"
          "zsh-interactive-cd"
          "z"
        ];
      };
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      config = {
        hide_env_diff = true;
      };
    };
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      clock24 = true;
      customPaneNavigationAndResize = true;
      escapeTime = 10;
      historyLimit = 100000;
      mouse = true;
      shell = "${pkgs.zsh}/bin/zsh";
      extraConfig = ''
        set-option -g default-terminal 'screen-256color'
        set-option -g terminal-overrides ',xterm-256color:RGB'
        source-file "$HOME/.gruvbox.tmuxtheme"
        # vim-like pane resizing
        bind -r C-k resize-pane -U
        bind -r C-j resize-pane -D
        bind -r C-h resize-pane -L
        bind -r C-l resize-pane -R
        # vim-like pane switching
        bind -r k select-pane -U
        bind -r j select-pane -D
        bind -r h select-pane -L
        bind -r l select-pane -R

        #vi selection mode
        setw -g mode-keys vi
        set-option -g status-interval 5
        set-option -g automatic-rename on
        set-option -g automatic-rename-format '#{b:pane_current_path}'
      '';
      plugins = [
        pkgs.tmuxPlugins.tmux-fzf
      ];
    };
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [vim-airline vim-airline-themes everforest vim-surround];
      extraConfig = "${builtins.readFile ./vim/vimrc}";
    };

    home.file.".gruvbox.tmuxtheme" = {
      source = ./tmux/gruvbox.tmuxtheme;
    };

    home.file.".gitmessage".source = ./git/gitmessage;
    home.file.".gitconfig".source = ./git/gitconfig;
    home.file."git/.gitignore".source = ./git/gitignore;

    home.file.".ssh/config".source = ./ssh/config;

    # Create ~/.config/ghostty/theme.conf on first activation (respects current mode).
    # The theme name can be changed by editing the file or running toggle_light_theme.
    home.activation.initGhosttyTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -d  "$HOME/.config/ghostty" ]];then
          if [ ! -f "$HOME/.config/ghostty/theme.conf" ]; then
            _mode=dark
            [ -f "$HOME/.config/theme/mode" ] && _mode=$(cat "$HOME/.config/theme/mode")
            if [ "$_mode" = "light" ]; then
              echo "theme = GitHub Light" > "$HOME/.config/ghostty/theme.conf"
            else
              echo "theme = Arthur" > "$HOME/.config/ghostty/theme.conf"
            fi
          fi
      fi
    '';
  };
}
