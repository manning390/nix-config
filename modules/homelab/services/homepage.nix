{
  config,
  lib,
  ...
}: let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
  homelab = config.homelab;
in {
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption "Enable ${service}";
    misc = lib.mkOption {
      default = [];
      type = lib.types.listOf (
        lib.types.attrsOf (
          lib.types.submodule {
            options = {
              description = lib.mkOption {
                type = lib.types.str;
              };
              href = lib.mkOption {
                type = lib.types.str;
              };
              siteMonitor = lib.mkOption {
                type = lib.types.str;
              };
              icon = lib.mkOption {
                type = lib.types.str;
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances.enable = true;
    services.${service} = {
      enable = true;
      settings = {
        layout = [
          {
            Glances = {
              header = false;
              style = "row";
              columns = 4;
            };
          }
          {
            Arr = {
              header = true;
              style = "column";
            };
          }
          {
            Downloads = {
              header = true;
              sytle = "column";
            };
          }
          {
            Media = {
              header = true;
              sytle = "column";
            };
          }
          {
            Services = {
              header = true;
              style = "column";
            };
          }
        ];
        headerStyles = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };
      services = let
        homepageCategories = ["Arr" "Media" "Downloads" "Services"];
        hl = config.homelab.services;
        homepageServices = x: (lib.attrsets.filterAttrs (name: value: value ? homepage && value.homepage.category == x) homelab.services);
      in
        lib.lists.forEach homepageCategories (cat: {
          "${cat}" =
            lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (homepageServices "${cat}"))
            (x: {
              "${hl.${x}.homepage.name}" = {
                icon = hl.${x}.homepage.icon;
                description = hl.${x}.homepage.description;
                href = "https://${hl.${x}.url}";
                siteMonitor = "https://${hl.${x}.url}";
              };
            });
        })
        ++ [{Misc = cfg.misc;}]
        ++ [
          {
            Glances = let
              port = toString config.services.glances.port;
            in [
              {
                Info = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:${port}";
                    metric = "info";
                    chart = false;
                    version = 4;
                  };
                };
              }
              {
                "CPU Temp" = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:${port}";
                    metric = "sensor:Package id 0";
                    chart = false;
                    version = 4;
                  };
                };
              }
              {
                Processes = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:${port}";
                    metric = "process";
                    chart = false;
                    version = 4;
                  };
                };
              }
              {
                Network = {
                  widget = {
                    type = "glances";
                    url = "http://localhost:${port}";
                    metric = "network:enp10s0";
                    chart = false;
                    version = 4;
                  };
                };
              }
            ];
          }
        ];
    };
  };
}
