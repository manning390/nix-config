{inputs, ...}: {
  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
    lib = pkgs.lib;
    # Google's emulator in this pinned SDK has no aarch64-linux binary.
    supported = builtins.elem system ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
    abi =
      if system == "aarch64-darwin"
      then "arm64-v8a"
      else "x86_64";
    api = "35";
    imageType = "google_apis";
    avd = "nix-android-${api}-${abi}";
    sdk =
      (pkgs.androidenv.composeAndroidPackages {
        platformVersions = [api];
        buildToolsVersions = ["35.0.0"];
        includeEmulator = true;
        includeSystemImages = true;
        systemImageTypes = [imageType];
        abiVersions = [abi];
        includeCmake = false;
        includeNDK = false;
      }).androidsdk;
    environment = ''
      export ANDROID_HOME="${sdk}/libexec/android-sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export JAVA_HOME="${pkgs.jdk17.home}"
      export ANDROID_USER_HOME="''${ANDROID_USER_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/nix-android}"
      export ANDROID_AVD_HOME="''${ANDROID_AVD_HOME:-$ANDROID_USER_HOME/avd}"
    '';
    runEmulator = pkgs.writeShellApplication {
      name = "android-emulator";
      runtimeInputs = [sdk pkgs.jdk17 pkgs.coreutils];
      text = ''
        if [[ "''${1:-}" == "--arm64" ]]; then
          shift
          ${
          if abi == "arm64-v8a"
          then ''
            echo "Starting the ARM64 Android guest." >&2
          ''
          else ''
            echo "ARM64 guests are not supported by this packaged emulator on ${system}." >&2
            echo "Use an Apple Silicon host with this shell, or connect an ARM64 phone over USB." >&2
            echo "See docs/android-testing.md for the phone testing workflow." >&2
            exit 1
          ''
        }
        fi
        ${environment}
        mkdir -p "$ANDROID_USER_HOME" "$ANDROID_AVD_HOME"

        if [[ ! -e "$ANDROID_AVD_HOME/${avd}.ini" ]]; then
          avdmanager create avd \
            --name "${avd}" \
            --package "system-images;android-${api};${imageType};${abi}" \
            --path "$ANDROID_AVD_HOME/${avd}.avd" <<< "no"
          printf '\nhw.keyboard=yes\n' >> "$ANDROID_AVD_HOME/${avd}.avd/config.ini"
        fi

        ${lib.optionalString (abi == "x86_64") ''
          echo "Note: this x86_64 guest is for general Android testing, not supported ARM64 Nix-on-Droid activation." >&2
        ''}
        ${lib.optionalString (system == "x86_64-linux") ''
          if [[ ! -r /dev/kvm || ! -w /dev/kvm ]]; then
            echo "Warning: /dev/kvm is not accessible; check KVM support and group membership." >&2
          fi
        ''}
        exec emulator -avd "${avd}" -no-boot-anim "$@"
      '';
    };
  in {
    devShells = lib.optionalAttrs supported {
      android = pkgs.mkShell {
        name = "android";
        packages = [sdk pkgs.jdk17 runEmulator];
        shellHook = ''
          ${environment}
          echo "Android tools ready: android-emulator [emulator options], adb, avdmanager"
          echo "AVD: ${avd}; state: $ANDROID_AVD_HOME"
          ${lib.optionalString (abi == "x86_64") ''
            echo "Nix-on-Droid requires ARM64; use adb with a real ARM64 phone for activation testing."
          ''}
        '';
      };
    };
  };
}
