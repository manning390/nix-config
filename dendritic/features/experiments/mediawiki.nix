{
  flake.modules.nixos.mediawiki = {pkgs, ...}: {
    services.nginx = {
    };
    services.mediawiki = {
      enable = true;
      name = "Test Abidan";
      url = "http://wiki.localhost";
      passwordFile = pkgs.writeText "password" "cardbotnine";
      webserver = "nginx";
      database = {
        type = "postgres";
        createLocally = true;
      };
      nginx.hostName = "wiki.localhost";
      poolConfig = {
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
      extraConfig =
        /*
        php
        */
        ''
          // Enable Darkmode feature!
          $wgVectorNightMode['beta'] = true;
          $wgVectorNightMode['logged_out'] = true;
          $wgVectorNightMode['logged_in'] = true;
          $wgDefaultUserOptions['vector-theme'] = 'os';

          // Scribunto configs
          $wgScribuntoDefaultEngine = 'luastandalone';
          $wgScribuntoEngineConf['luastandalone']['memoryLimit'] = "50M";

          // Pluggable Auth
          $wgPluggableAuth_Config = [
              'Abidan Archive' => [
                  'plugin' => 'OpenIDConnect',
                  'data' => [
                      'providerURL' => 'http://localhost:8000',
                      'clientID' => 'mediawiki',
                      'clientsecret' => 'secret',
                  ]
              ]
          ];
          // Force OAuth login
          $wgPluggableAuth_EnableAutoLogin = false;
          $wgPluggableAuth_EnableLocalLogin = true; // No mediawiki based accounts
          $wgPluggableAuth_EnableLocalProperties = false; // Email through laravel

          $wgScribuntoDefaultEngine = 'luastandalone';
          $wgScribuntoEngineConf['luastandalone']['memoryLimit'] = "50M";

          $wgDebugLogFile = '/tmp/mediawiki-debug.log';
          $wgDebugLogGroups['PluggableAuth'] = '/tmp/pluggableauth-debug.log';
          $wgShowExceptionDetails = true;
        '';

      # 'email' => 'email',
      # 'realname' => 'name',
      extensions = {
        # Extensions included within the mediawiki install are enabled by setting to null here
        PluggableAuth = pkgs.fetchzip {
          url = "https://extdist.wmflabs.org/dist/extensions/PluggableAuth-REL1_45-2db3fff.tar.gz";
          sha256 = "sha256-G0Vs1QXusok6WS6HMib/FX/sCMuaQd0kJKsMCKI44Kg=";
        };
        OpenIDConnect = pkgs.fetchzip {
          url = "https://extdist.wmflabs.org/dist/extensions/OpenIDConnect-REL1_45-efcadd5.tar.gz";
          sha256 = "sha256-EPKBL4CvlACLrgOPyMfv0onGuSnjilZyx6ci6jh2fuw=";
        };
        Scribunto = null;
        TemplateStyles = null;
      };
    };
  };
}
