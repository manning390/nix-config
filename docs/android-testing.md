# Android testing

Enter the Android development shell:

```sh
nix develop path:.#android
```

The shell includes a pinned Android SDK, Android 15 (API 35) system image,
emulator, ADB, AVD manager, and Java. Its Nixpkgs configuration accepts the
[Android SDK license](https://developer.android.com/studio/terms) and allows
the required unfree packages. Expect a large initial download.

`path:.` includes newly created, untracked module files. Once the new files are
tracked in Git, the usual `nix develop .#android` works too.

## Architecture limitations

The shell is available on `x86_64-linux`, `x86_64-darwin`, and
`aarch64-darwin`, matching the emulator binaries in the pinned SDK.
It selects an x86_64 guest on Intel/AMD hosts and an ARM64 guest on Apple Silicon.
There is no `aarch64-linux` emulator binary in this SDK.

**Nix-on-Droid primarily supports ARM64. The x86_64 emulator is for general
Android testing, not a supported environment for testing Nix-on-Droid activation.**
Docker or ARM app translation does not remove that limitation. On an Intel/AMD
machine, use the shell's ADB tools with a real ARM64 phone for those tests.
The repository also defines an `android` host type and a `phone` host; see
[the phone configuration guide](android-host.md).

### Explicit ARM64 mode

On a supported ARM64 emulator host (currently Apple Silicon with this SDK):

```sh
nix develop path:.#android
android-emulator --arm64
```

`--arm64` must be the first argument; further emulator options can follow it.
On Intel/AMD hosts this mode exits with an explanation instead of starting an
x86 device. It is an architecture check, not software CPU translation. This
shell does not provide ARM64 Android emulation on x86_64 Linux; use the phone
workflow below on those machines.

## Start an emulator

```sh
android-emulator
```

The launcher creates its own named virtual device on first use, then reuses it.
State lives under `${XDG_DATA_HOME:-$HOME/.local/share}/nix-android` by default,
separate from normal Android Studio state. `ANDROID_USER_HOME` and
`ANDROID_AVD_HOME` can override the locations. Exiting the shell does not erase
the device or its installed applications.

Additional emulator options are forwarded, for example:

```sh
android-emulator -no-window -no-audio
```

On Linux, hardware acceleration requires working KVM and read/write access to
`/dev/kvm` (usually membership in the `kvm` group; log in again after changing
groups). A dev shell cannot grant these host permissions. No host settings are
changed by this shell.

In another Android dev shell:

```sh
adb devices
adb -e shell getprop ro.product.cpu.abi
adb -e install /absolute/path/to/app.apk
```

`-e` selects an emulator. If multiple emulators are running, use
`adb -s emulator-5554 ...` with the serial shown by `adb devices` instead.
Keep test devices free of production keys, VPN credentials, and private files.

## Test Nix-on-Droid on a phone

1. Enable Android developer options and USB debugging temporarily.
2. Connect the phone over USB and approve the computer's debugging key.
3. Download the Nix-on-Droid APK from
   [F-Droid](https://f-droid.org/packages/com.termux.nix/).
4. From the development shell:

   ```sh
   adb devices
   adb -d shell getprop ro.product.cpu.abi
   adb -d install /absolute/path/to/nix-on-droid.apk
   ```

   The ABI should be `arm64-v8a`. `-d` selects a USB-connected physical device;
   use `-s SERIAL` if more than one is connected.

5. Open Nix-on-Droid on the phone and complete its bootstrap.
6. Once a phone flake exists, transfer only the intended configuration files,
   not your whole home directory or credentials. For example, with a deliberately
   prepared local `phone-config` directory and storage permission granted to
   Nix-on-Droid:

   ```sh
   adb -d push ./phone-config /sdcard/Download/phone-config
   ```

   Then **inside Nix-on-Droid**, copy it into the app's private home and apply it:

   ```sh
   cp -r /sdcard/Download/phone-config ~/phone-config
   nix-on-droid switch --flake ~/phone-config#phone
   ```

   Shared storage is a transfer location, not a place to keep private keys.
   The directory must contain a complete flake and any referenced local files.

ADB runs as Android's shell user, not the Nix-on-Droid app user; do not expect
`adb shell nix-on-droid ...` to work. Access to shared storage also requires
the app's storage permission. A private flake input may need authentication:
avoid copying broad GitHub or deployment credentials to the test device.

Disable USB debugging and revoke debugging authorizations afterward if no
longer needed. An emulator does not validate a physical phone's security or
battery-management behavior.
