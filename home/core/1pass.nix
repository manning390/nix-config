{
  vars,
  lib,
  pkgs,
  ...
}: {
  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "1password-gui"
  #     "1password-cli"
  #   ];
  # home.packages = with pkgs; [
  #   _1password-cli
  #   _1password-gui
  # ];

  programs = {
    jq.enable = true;
    # _1password.enable = true;
    # _1password-gui = {
    #   enable = true;
    #   polkitPolicyOwners = [ vars.username ];
    # };
  };

  # (pkgs.writeShellScriptBin "1pass" ''
  #     # Uses 1password-cli and jq
  #
  #     # Create helpers functions
  #     function opon() {
  #         if [[ -z $OP_SESSION ]]; then
  #             export OP_SESSION="$(op signin --account my --raw)"
  #         fi
  #     }
  #     function opoff() {
  #         op signout --account my
  #         unset OP_SESSION
  #     }
  #     function opp() {
  #         opon
  #         i=$1
  #         op item get $i --session $OP_SESSION --fields password | xclip -selection clipboard
  #     }
  #     function opw() {
  #         opon
  #         i=$1
  #         op item get $i --session $OP_SESSION --fields username | xclip -selection clipboard
  #     }
  #     function opt() {
  #         opon
  #         i=$1
  #         op item get $i --session $OP_SESSION --otp | xclip -selection clipboard
  #     }
  #     function ops() {
  #         echo "Shit is broken m8, hello future me, fuck you"
  #         # opon
  #         # if [[ -n $OP_SESSION_my ]]; then
  #         #     t=$(op item list --categories Login --session $OP_SESSION --format=json | jq -c '.[]|.overview.title' |tr -d '\042'| fzf --preview 'op get item {} | jq "{title: .overview.title, url: .overview.url, uuid: .uuid}"')
  #         #     export OP_CACHED_UUID=$(op item get $t --cache --session $OP_SESSION | jq -r '.uuid' | tr -d '\042')
  #         #     echo "Cached Search, Password in clipboard"
  #         #     opp
  #         # fi
  #     }
  # '');
}
