{ pkgs, ... }: {
  home.stateVersion = "26.05";
  programs.bash = {
    enable = true;
    sessionVariables = {
      TERM = "xterm-256color";
    };
  };
}
