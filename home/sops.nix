# {
#   config,
#   inputs,
#   lib,
#   vars,
#   ...
# }: {
#   imports = [
#     inputs.sops-nix.homeManagerModules.sops
#   ];
#
#   config = lib.mkIf config.local.sops.enable {
#     sops = {
#       age.keyFile = "/home/${vars.username}/.config/sops/age/keys.txt";
#       defaultSopsFile = lib.custom.relativeToRoot "secrets/secrets.yaml";
#       validateSopsFiles = false;
#
#       secrets = {
#         # "private_keys/${vars.username}@${vars.hostname}" = {
#         #   path = "/home/${vars.username}/.ssh/user_${vars.username}_${vars.hostname}_ed25519_key";
#         # };
#         # "smba/client-credentials" = {};
#       };
#     };
#   };
# }
