{ pkgs }:
let
  font = fonts.hack;
  fonts = {
    hack = {
      name = "Hack";
      package = pkgs.hack-font;
      size = 10;
    };
    cozette = {
      name = "cozette";
      package = pkgs.cozette;
      size = 10;
    };
    dina = {
      name = "Dina";
      package = pkgs.dina-font;
      size = 10;
    };
  };

  colors = themes.tokyoNight;
  themes = {
    oneDark = {
      emacs-theme = "doom-one";
      background = "#1e222a";
      foreground = "#d8dee9";

      black = "#1b1f27";
      lighterBlack = "#252931";
      darkerGrey = "#353b45";
      darkGrey = "#3e4451";
      grey = "#545862";
      lightGrey = "#565c64";
      lighterGrey = "#abb2bf";

      blue = "#61afef";
      cyan = "#a3b8ef";
      green = "#98c379";
      magenta = "#c678dd";
      orange = "#d19a66";
      red = "#e06c75";
      teal = "#56b6c2";
      violet = "#ff75a0";
      yellow = "#e5c07b";
    };
    tokyoNight = {
      emacs-theme = "doom-tokyo-night";
      background = "#1a1b26";
      foreground = "#a9b1d6";

      # TODO: Rename stuff
      # FIXME: Colors are wrong lol
      black = "#13141c";
      lighterBlack = "#414868";
      darkerGrey = "#51587a";
      darkGrey = "#61698b";
      grey = "#8189af";
      lightGrey = "#565c64";
      lighterGrey = "#abb2bf";

      blue = "#7aa2f7";
      cyan = "#b4f9f8";
      green = "#73daca";
      magenta = "#bb9af7";
      orange = "#ff9e64";
      red = "#f7768e";
      teal = "#2ac3de";
      violet = "#9aa5ce";
      yellow = "#e0af68";
    };
  };
in
{
  inherit colors;
  inherit font;
}
