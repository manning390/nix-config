"""Run with python3 test-window-picker.py; no graphical session required."""

import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("window_picker", Path(__file__).with_name("window-picker.py"))
picker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(picker)


class WindowPickerTest(unittest.TestCase):
    def test_cancellation_and_invalid_indices(self):
        for output, status in [("", 1), ("-1", 0), ("9", 0), ("custom text", 0)]:
            with patch.object(picker.subprocess, "run", return_value=subprocess.CompletedProcess([], status, output)):
                self.assertIsNone(picker.pick(["one", "two"]))

    def test_exact_address_and_sanitized_labels(self):
        clients = [{
            "mapped": True, "hidden": False, "workspace": {"name": "2"},
            "class": "kitty", "title": "a\n'$(command)'", "address": "0x123",
        }]
        with patch.object(picker.subprocess, "run") as run:
            run.side_effect = [
                subprocess.CompletedProcess([], 0, json.dumps(clients)),
                subprocess.CompletedProcess([], 0, "0\n"),
                subprocess.CompletedProcess([], 0),
            ]
            picker.main()
        self.assertEqual(run.call_args.args[0], ["hyprctl", "dispatch", "focuswindow", "address:0x123"])
        self.assertEqual(run.call_args_list[1].kwargs["input"].count("\n"), 1)

    def test_empty_results_only_notify(self):
        with patch.object(picker.subprocess, "run") as run, patch.object(picker, "notify") as notify:
            run.return_value = subprocess.CompletedProcess([], 0, "[]")
            picker.main()
        self.assertEqual(run.call_count, 1)
        notify.assert_called_once_with("Windows", "No results.")

    def test_duplicate_titles_and_unmapped_windows(self):
        clients = [
            {
                "mapped": mapped, "hidden": hidden, "workspace": {"name": "1"},
                "class": "kitty", "title": "same", "address": address,
            }
            for mapped, hidden, address in [
                (False, False, "0x000"), (True, True, "0x001"),
                (True, False, "0x123"), (True, False, "0x456"),
            ]
        ]
        with patch.object(picker.subprocess, "run") as run:
            run.side_effect = [
                subprocess.CompletedProcess([], 0, json.dumps(clients)),
                subprocess.CompletedProcess([], 0, "1\n"),
                subprocess.CompletedProcess([], 0),
            ]
            picker.main()
        self.assertEqual(run.call_args.args[0][-1], "address:0x456")
        self.assertEqual(run.call_args_list[1].kwargs["input"].count("\n"), 2)


if __name__ == "__main__":
    unittest.main()
