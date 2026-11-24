{
  flake.aspects.firefox = {
    nixos = {pkgs, ...}: {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;

        # Applies to existing profiles without replacing extensions or data.
        # Windows Firefox on WSL hosts is outside this module's scope.
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          SearchSuggestEnabled = false;
          PasswordManagerEnabled = false;
          OfferToSaveLogins = false;

          FirefoxHome = {
            SponsoredTopSites = false;
            SponsoredPocket = false;
          };

          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "addon@darkreader.org" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            };
            "{db8ff575-504f-4f3d-a910-07702998d21d}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/json_formatter/latest.xpi";
            };
          };

          # Defaults, not locks: preserve existing choices and allow site/work
          # exceptions. Check effective values in about:config after rebuilding.
          Preferences = {
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "default";
            };
            "dom.security.https_only_mode" = {
              Value = true;
              Status = "default";
            };
            "browser.urlbar.suggest.quicksuggest.sponsored" = {
              Value = false;
              Status = "default";
            };
            "privacy.fingerprintingProtection" = {
              Value = true;
              Status = "default";
            };
            "browser.newtabpage.activity-stream.feeds.telemetry" = {
              Value = false;
              Status = "default";
            };
            "browser.newtabpage.activity-stream.telemetry" = {
              Value = false;
              Status = "default";
            };
          };
        };
      };
    };

    homeManager = {
      programs.firefox = {
        enable = true;
        # Use the policy-wrapped NixOS package, not a second HM installation.
        package = null;
        # Add per-profile settings/extensions here after reviewing exports.
        # Leave profiles.ini and existing profile data unmanaged for now.
      };
    };

    # Opt-in only: the caller must also declare their primary HM profile.
    # Install Lighthouse from AMO in this profile; Firefox manages its updates.
    # Never install it through system policies (those affect all profiles).
    _.developerProfile = {
      name,
      id,
    }: {
      homeManager = {
        programs.firefox.profiles.${name} = {
          inherit id;
          isDefault = false;
          settings."extensions.update.enabled" = true;
        };
      };
    };
  };
}
