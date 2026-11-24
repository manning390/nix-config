#!/usr/bin/env python3
"""Read selected Firefox preferences and extension metadata; emit JSON to stdout."""

import argparse
import json
from pathlib import Path
import re
import sys


# Deliberately exclude URLs, account IDs, paths, proxy details, and arbitrary
# extension preferences. Unset entries are not evidence of Firefox defaults.
PREFERENCES = (
    "app.shield.optoutstudies.enabled",
    "browser.contentblocking.category",
    "browser.formfill.enable",
    "browser.newtabpage.activity-stream.feeds.telemetry",
    "browser.newtabpage.activity-stream.showSponsored",
    "browser.newtabpage.activity-stream.showSponsoredTopSites",
    "browser.newtabpage.activity-stream.telemetry",
    "browser.newtabpage.enabled",
    "browser.privatebrowsing.autostart",
    "browser.safebrowsing.downloads.enabled",
    "browser.safebrowsing.malware.enabled",
    "browser.safebrowsing.phishing.enabled",
    "browser.search.suggest.enabled",
    "browser.send_pings",
    "browser.sessionstore.privacy_level",
    "browser.urlbar.quicksuggest.enabled",
    "browser.urlbar.suggest.quicksuggest.nonsponsored",
    "browser.urlbar.suggest.quicksuggest.sponsored",
    "browser.urlbar.suggest.searches",
    "datareporting.healthreport.uploadEnabled",
    "datareporting.policy.dataSubmissionEnabled",
    "dom.security.https_only_mode",
    "dom.security.https_only_mode_pbm",
    "dom.webnotifications.enabled",
    "extensions.pocket.enabled",
    "geo.enabled",
    "media.peerconnection.enabled",
    "network.cookie.cookieBehavior",
    "network.cookie.lifetimePolicy",
    "network.dns.disablePrefetch",
    "network.http.speculative-parallel-limit",
    "network.predictor.enabled",
    "network.prefetch-next",
    "network.trr.mode",
    "permissions.default.camera",
    "permissions.default.desktop-notification",
    "permissions.default.geo",
    "permissions.default.microphone",
    "privacy.clearOnShutdown.cache",
    "privacy.clearOnShutdown.cookies",
    "privacy.clearOnShutdown.history",
    "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads",
    "privacy.clearOnShutdown_v2.cache",
    "privacy.clearOnShutdown_v2.cookiesAndStorage",
    "privacy.donottrackheader.enabled",
    "privacy.fingerprintingProtection",
    "privacy.firstparty.isolate",
    "privacy.globalprivacycontrol.enabled",
    "privacy.resistFingerprinting",
    "privacy.sanitize.sanitizeOnShutdown",
    "privacy.trackingprotection.enabled",
    "privacy.trackingprotection.pbmode.enabled",
    "signon.rememberSignons",
    "toolkit.telemetry.enabled",
    "toolkit.telemetry.unified",
)

PREF_LINE = re.compile(
    r'^\s*user_pref\(("(?:[^"\\]|\\.)*"),\s*(.*?)\s*\);\s*$'
)


def read_preferences(path):
    """Parse literal preference values without evaluating JavaScript."""
    values = {}
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        match = PREF_LINE.match(line)
        if not match:
            continue
        name = json.loads(match[1])
        if name in PREFERENCES:
            value = json.loads(match[2])
            if type(value) in (bool, int, str):
                values[name] = value
    return dict(sorted(values.items()))


def export_profile(profile, label):
    prefs = read_preferences(profile / "prefs.js")
    user_js = profile / "user.js"
    extensions_file = profile / "extensions.json"
    extensions = None
    if extensions_file.exists():
        data = json.loads(extensions_file.read_text(encoding="utf-8-sig"))
        extensions = []
        for addon in data.get("addons", []):
            if addon.get("type") != "extension":
                continue
            extensions.append({
                "id": addon.get("id"),
                "name": (addon.get("defaultLocale") or {}).get("name"),
                "version": addon.get("version"),
                "active": addon.get("active"),
                "userDisabled": addon.get("userDisabled"),
                "appDisabled": addon.get("appDisabled"),
            })
        extensions.sort(key=lambda addon: addon["id"] or "")

    return {
        "schemaVersion": 1,
        "label": label,
        "limitations": [
            "Selected stored preferences only, not effective/default/locked values.",
            "Absent preferences are unknown; defaults vary by Firefox version.",
            "user.js values are separate; they are applied by Firefox at startup.",
            "Windows registry policies and extension settings are not exported.",
            "Review extension names/IDs for organization-sensitive information.",
        ],
        "storedPreferences": prefs,
        "notStored": sorted(set(PREFERENCES) - prefs.keys()),
        "userJsPreferences": read_preferences(user_js) if user_js.exists() else None,
        "extensions": extensions,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", type=Path, help="Firefox profile root directory")
    parser.add_argument("--label", required=True, help="For example: sage/work")
    args = parser.parse_args()
    try:
        result = export_profile(args.profile, args.label)
    except (OSError, ValueError, TypeError, AttributeError) as error:
        print(f"Cannot export profile: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
