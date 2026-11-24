"""Copy a selected area, then optionally save through a notification action."""

import argparse
import contextlib
import datetime
import fcntl
import html
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile


def xdg(variable, fallback):
    return Path(os.environ.get(variable) or Path.home() / fallback)


def screenshots_dir():
    return Path(os.environ.get("CAELESTIA_SCREENSHOTS_DIR") or Path.home() / "Pictures/Screenshots")


def run(args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def notify(title, body, *options):
    result = subprocess.run(
        ["notify-send", "--app-name=area-screenshot", *options, title, body],
        capture_output=True, text=True,
    )
    return result.stdout.strip() if result.returncode == 0 else ""


@contextlib.contextmanager
def lock():
    directory = xdg("XDG_CACHE_HOME", ".cache") / "caelestia/area-screenshot"
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (directory / "capture.lock").open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            yield False
        else:
            try:
                yield True
            finally:
                fcntl.flock(handle, fcntl.LOCK_UN)


def save_capture(source):
    directory = screenshots_dir()
    directory.mkdir(parents=True, exist_ok=True)
    # mkstemp guarantees uniqueness even for captures saved simultaneously.
    stamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    fd, name = tempfile.mkstemp(prefix=f"Screenshot_{stamp}_", suffix=".png", dir=directory)
    destination = Path(name)
    try:
        with os.fdopen(fd, "wb") as output, source.open("rb") as image:
            shutil.copyfileobj(image, output)
    except BaseException:
        destination.unlink(missing_ok=True)
        raise
    notify("Screenshot saved", html.escape(str(destination)))
    return destination


def screenshot(save=False):
    cache = xdg("XDG_CACHE_HOME", ".cache") / "caelestia/area-screenshot"
    cache.mkdir(parents=True, exist_ok=True, mode=0o700)
    # Keep selection/capture serialized, not the notification's lifetime.
    with tempfile.TemporaryDirectory(prefix="capture-", dir=cache) as temporary:
        image = Path(temporary) / "capture.png"
        with lock() as acquired:
            if not acquired:
                return
            selection = subprocess.run(["slurp"], capture_output=True, text=True)
            if selection.returncode != 0 or not selection.stdout.strip():
                return  # Escape/cancel is not a capture failure.
            run(["grim", "-g", selection.stdout.strip(), str(image)])
            with image.open("rb") as source:
                run(["wl-copy", "--type", "image/png"], stdin=source)
        if save:
            save_capture(image)
        else:
            action = notify(
                "Screenshot copied", "Selected area copied to clipboard.",
                f"--icon={image}", "--wait", "--action=save=Save",
            )
            if action == "save":
                save_capture(image)
        # TemporaryDirectory cleans up on dismissal, failed notification, or error.


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--save", action="store_true")
    args = parser.parse_args()
    try:
        screenshot(args.save)
    except (OSError, subprocess.CalledProcessError, ValueError) as error:
        notify("Area screenshot failed", html.escape(str(error)))
        raise SystemExit(1) from error


if __name__ == "__main__":
    for stop_signal in (signal.SIGTERM, signal.SIGHUP):
        signal.signal(stop_signal, lambda number, _frame: sys.exit(128 + number))
    main()
