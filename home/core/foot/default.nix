{
  pkgs,
  lib,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      key-bindings = {
        "Control+m" = "send-text:\x1b\x5b109;133u";
        "Control+i" = "send-text:\x1b\x5b105;133u";
        "Control+Shift+h" = "send-text:\x1b\x5b104;134u";
      };
    };
  };
}
