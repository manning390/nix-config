"""Search mapped Hyprland windows without recording history."""

import html
import json
import subprocess
import sys


def notify(title, body):
    subprocess.run(
        ["notify-send", "--app-name=window-picker", title, body],
        check=False,
    )


def clean_label(value):
    return " ".join(str(value).split())


def pick(labels):
    if not labels:
        notify("Windows", "No results.")
        return None
    # Index output handles identical titles and labels containing newlines.
    result = subprocess.run(
        ["fuzzel", "--dmenu", "--index", "--prompt", "Windows> "],
        input="\n".join(labels) + "\n", capture_output=True, text=True,
    )
    if result.returncode != 0:
        return None
    try:
        index = int(result.stdout.strip())
        return index if 0 <= index < len(labels) else None
    except ValueError:
        return None


def main():
    # Hyprland installs hyprctl on the graphical hosts.
    result = subprocess.run(
        ["hyprctl", "-j", "clients"],
        check=True, capture_output=True, text=True,
    )
    clients = json.loads(result.stdout)
    clients = [
        client for client in clients
        if client.get("mapped") and not client.get("hidden")
    ]
    labels = [
        f"[{clean_label(client['workspace']['name'])}] "
        f"{clean_label(client['class'])}: {clean_label(client['title'])}"
        for client in clients
    ]
    index = pick(labels)
    if index is not None:
        # Focus by exact address, never by an editable menu label.
        subprocess.run(
            ["hyprctl", "dispatch", "focuswindow",
             f"address:{clients[index]['address']}"],
            check=True,
        )


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError, ValueError) as error:
        notify("Window picker failed", html.escape(str(error)))
        sys.exit(1)
