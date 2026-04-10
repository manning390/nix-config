{
  flake.modules.nixos.mediawiki = {pkgs,...}: {
    services.httpd.enable = true;
    services.mediawiki = {
      enable = true;
      name = " Test Abidan";
      url = "http://localhost";
      passwordFile = pkgs.writeText "password" "password";
      uploadsDir = "/var/lib/mediawiki/uploads";
      httpd.virtualHost = {
        hostName = "localhost";
        adminAddr = "admin@example.com";
      };
      database = {
        type = "mysql";
        createLocally = true;
      };
      poolConfig = {
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
      extraConfig = ''
        wfLoadExtension("Scribunto");
        $wgScribuntoDefaultEngine = 'luastandalone';
        $wgScribuntoEngineConf['luastandalone']['memoryLimit'] = "50M";
      '';
    };
  };
}
