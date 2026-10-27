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
        content =
          /*
          yaml
          */
          ''
            jira_api_username: "${config.sops.placeholder.workemail}"
            jira_api_token: "${config.sops.placeholder."jira/pat"}"
            jira_api_base_url: "${config.sops.placeholder."jira/url"}"
            jira_api_version: 2
            cloud: false
            # Jira Server/Data Center personal access tokens use Bearer auth.
            use_bearer_authentication: true

            theme: "nord"
            pre_defined_jql_expressions:
              me:
                label: "Assigned to me"
                expression: "assignee = currentUser() ORDER BY updated DESC"
          '';
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = [
        (pkgs.jiratui.overrideAttrs (old: {
          # Textual 8 renamed the empty selection sentinel from BLANK to NULL.
          postPatch = (old.postPatch or "") + ''
            substituteInPlace \
              src/jiratui/utils/create_work_item.py \
              src/jiratui/widgets/jql.py \
              src/jiratui/widgets/work_item_details/details.py \
              --replace-fail 'Select.BLANK' 'Select.NULL'

            # Keep Alt+arrows, with plain bracket keys for terminal-friendly paging.
            substituteInPlace src/jiratui/widgets/search.py \
              --replace-fail "key='alt+left'," "key='alt+left,left_square_bracket'," \
              --replace-fail "key_display='alt+left'," "key_display='['," \
              --replace-fail "key='alt+right'," "key='alt+right,right_square_bracket'," \
              --replace-fail "key_display='alt+right'," "key_display=']',"
          '';
        }))
      ];
      home.shellAliases.jira = "jiratui ui";
    };
  };
}
