# The first params is for passing scope, the second is the actual module
{user,...}: {config,...}: {
  sops = let
    sopsFile = ./secrets/sage.yaml;
    owner = user;
    group = "users";
    mode = "0600";
  in {
    secrets = {
      "npm/npmrc" = {
        inherit sopsFile owner group mode;
        path = "/home/${user}/.npmrc";
      };
      "workemail" = {inherit sopsFile owner group mode;};
      "userProfile" = {
        inherit sopsFile owner group mode;
        path = "/home/${user}/.profile";
      };
      "jira/pat" = {inherit owner group mode sopsFile;};
      "jira/url" = {inherit owner group mode sopsFile;};
    };
    templates."gitconfig" = {
      inherit owner group mode;
      content = ''
        [user]
            email = ${config.sops.placeholder.workemail}
      '';
    };
  };
}
