{
  flake.aspects.caddy-local-ca = {
    description = "Trust homelab's Caddy internal certificate authority";
    nixos = {
      security.pki.certificateFiles = [./glaciem-homelab-root-ca.crt];
    };
  };
}
