{
  flake.aspects.nordvpn.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.local.nordvpn = {
      enable = lib.mkEnableOption "Enables nordvpn via wgnord";
    };

    config = lib.mkIf config.local.nordvpn.enable {
      environment.systemPackages = with pkgs; [
        wgnord
        wireguard-tools
        openresolv
      ];
      systemd.tmpfiles.rules = [
        "d /etc/wireguard 0755 root root -"
        "d /var/lib/wgnord 0755 root root -"
        "L+ /var/lib/wgnord/countries.txt - - - - ${pkgs.wgnord}/share/countries.txt"
        "L+ /var/lib/wgnord/countries_iso31662.txt - - - - ${pkgs.wgnord}/share/countries_iso31662.txt"
        "L+ /var/lib/wgnord/template.conf - - - - ${pkgs.writeText "template.conf" ''
          [Interface]
          PrivateKey = PRIVKEY
          Address = 10.5.0.2/32
          MTU = 1350
          DNS = 103.86.96.100 103.86.99.100

          [Peer]
          PublicKey = SERVER_PUBKEY
          AllowedIPs = 0.0.0.0/0, ::/0
          Endpoint = SERVER_IP:51820
          PersistentKeepalive = 25
        ''}"
      ];
    };
  };
}
