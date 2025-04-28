{
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
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "FiraMono" "DroidSansMono" "Hack" "Hasklig" "Meslo" "UbuntuMono"];})

      git
      git-lfs
      curl
      dos2unix
      screen

      ffmpegthumbnailer #pictures preview in yazi
      unar #archive preview in yazi

      thefuck
      peco #querying input
      fd #better find
      bat
      eza
      jq
      yq-go
      neovim
      nvimpager
      nil #  nix LSP
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
      poppler_utils #pdf conversions
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
    ];

    home.sessionVariables = {
      GITDIR = "$HOME/git";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.shellAliases = {
      dotfiles = "git --git-dir $GITDIR/dotfiles/ --work-tree=$HOME";
      initDotfiles = "f(){ mkdir -p $GITDIR || true; git clone --bare $1 $GITDIR/dotfiles; dotfiles config status.showUntrackedFiles no; }; f";
      vi = "nvim";
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

      #nvim
      cleanNvim = ''
        rm -Rf ~/.local/share/nvim
        rm -Rf ~/.local/state/nvim
        rm -Rf ~/.cache/nvim
      '';

      #git
      git-release-notes = ''git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%h %s"'';

      retry = ''f(){while true;do "$@" && break;sleep 1;done};f'';

      ns="f(){nix shell --inputs-from github:scarisey/nixos-dotfiles/main nixpkgs#$1};f";
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
      initExtra = ''
        eval $(thefuck --alias)
        export PAGER="nvimpager -p -- -c 'lua nvimpager.maps=false' "
        export MANPAGER="nvimpager -p -- -c 'lua nvimpager.maps=false' "
        source $HOME/.customzsh.rc &> /dev/null|| true
        export PATH=$PATH:$HOME/.local/bin/
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
    };
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      clock24 = true;
      customPaneNavigationAndResize = true;
      escapeTime = 10;
      historyLimit = 100000;
      mouse = true;
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

    home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
    home.activation.lazyvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run test -f ~/.config/nvim/lazyvim.json || cp ~/.config/nvim/lazyvim.orig ~/.config/nvim/lazyvim.json && chmod a+w ~/.config/nvim/lazyvim.json
    '';

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = ../../secrets.yaml;
      secrets."private_git_config/config".path = "${config.home.homeDirectory}/.private.gitconfig";
      secrets."private_git_config/user".path = "${config.home.homeDirectory}/.private.gituser";
      secrets.private_ssh_config.path = "${config.home.homeDirectory}/.ssh/config";
    };
  };
}
