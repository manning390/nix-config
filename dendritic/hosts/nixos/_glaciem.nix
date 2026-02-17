{config, pkgs, ...}: let
    machineName = "glaciem";
    user = config.local.identity.username;
in {
    config.local.hosts.${machineName} = {
        type = "nixos";
        aspects = [];
        modules = [{

            networking = {
                hostName = machineName;
                hostId = "9dea9b66";
                networkmanager.enable = false;
                useDHCP = true;
            };

            environment.systemPackages = with pkgs; [
                pciutils
                glances
                hdparm
                hd-idle
                hddtemp
                cpufrequtils
                powertop
            ];
        }];

        stateVersion = "25.05";
    };
}
