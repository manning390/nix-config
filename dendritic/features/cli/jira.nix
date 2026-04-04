{
  flake.aspects.jira = {
    nixos = {config, ...}: let
      user = config.local.identity.username;
    in {
      sops.templates."jiratui" = {
        owner = user;
        group = "users";
        mode = "0600";
        path = "/home/${user}/.config/jiratui/config.yaml";
        content = /*yaml*/''
          jira_api_username: "${config.sops.placeholder.workemail}"
          jira_api_token: "${config.sops.placeholder."jira/pat"}"
          jira_api_base_url: "${config.sops.placeholder."jira/url"}"
          # jira_api_version: 2
          cloud: False

          config.theme: "nord"
        '';
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [jiratui];
    };
  };
}
